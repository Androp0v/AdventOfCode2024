import Algorithms

struct Day11: AdventDay {
    
    let initialStones: [String]
    
    init(data: String) {
        self.initialStones = data.split(separator: " ").map {
            String($0).replacingOccurrences(of: "\n", with: "")
        }
    }
    
    func blink(stones: [String]) -> [String] {
        var tempStones = [String]()
        for stone in stones {
            if stone == "0" {
                tempStones.append("1")
            } else if stone.count % 2 == 0 {
                let firstStone = String(stone.prefix(stone.count / 2))
                let secondStone = String(Int(String(stone.suffix(stone.count / 2)))!)
                tempStones.append(firstStone)
                tempStones.append(secondStone)
            } else {
                tempStones.append(String( Int(stone)! * 2024 ))
            }
        }
        return tempStones
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        let blinkCount: Int = 25
        var stones: [String] = initialStones
        for _ in 0..<blinkCount {
            stones = blink(stones: stones)
            // print(stones)
        }
        return stones.count
    }
    
    func digitCount(of number: Int) -> Int {
        guard number > 9 else { return 1 }
        return digitCount(of: number / 10) + 1
    }
    
    func pow<T: BinaryInteger>(_ base: T, _ power: T) -> T {
        func expBySq(_ y: T, _ x: T, _ n: T) -> T {
            precondition(n >= 0)
            if n == 0 {
                return y
            } else if n == 1 {
                return y * x
            } else if n.isMultiple(of: 2) {
                return expBySq(y, x * x, n / 2)
            } else {
                return expBySq(y * x, x * x, (n - 1) / 2)
            }
        }
        return expBySq(1, base, power)
    }
    
    func blinkFast(stoneBag: StoneBag) -> StoneBag {
        var newStoneBag = StoneBag(stones: [])
        for (stone, count) in stoneBag.stoneCounts {
            if stone == 0 {
                newStoneBag.add(stone: 1, count: count)
            } else {
                let stoneDigitCount = digitCount(of: stone)
                if stoneDigitCount % 2 == 0 {
                    let power: Int = pow(10, stoneDigitCount / 2)
                    let firstStone = stone / (power)
                    let secondStone = stone - (firstStone * power)
                    newStoneBag.add(stone: firstStone, count: count)
                    newStoneBag.add(stone: secondStone, count: count)
                } else {
                    newStoneBag.add(stone: stone * 2024, count: count)
                }
            }
        }
        return newStoneBag
    }
    
    struct StoneBag {
        var stoneCounts: [Int: Int]
        
        var count: Int {
            return stoneCounts.values.reduce(0, +)
        }
        
        init(stones: [Int]) {
            stoneCounts = [Int: Int]()
            for stone in stones {
                if let existingCount = stoneCounts[stone] {
                    stoneCounts[stone] = existingCount + 1
                } else {
                    stoneCounts[stone] = 1
                }
            }
        }
        
        mutating func add(stone: Int, count: Int) {
            if let existingCount = stoneCounts[stone] {
                stoneCounts[stone] = existingCount + count
            } else {
                stoneCounts[stone] = count
            }
        }
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        let blinkCount: Int = 75
        var stoneBag = StoneBag(stones: initialStones.map( { Int($0)! }))
        for _ in 0..<blinkCount {
            stoneBag = blinkFast(stoneBag: stoneBag)
        }
        return stoneBag.count
    }
}
