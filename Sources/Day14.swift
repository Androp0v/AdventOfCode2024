import Algorithms

struct Day14: AdventDay {
    
    static let width: Int = 101
    static let height: Int = 103
    
    let positions: [(Int, Int)]
    let velocities: [(Int, Int)]
    
    init(data: String) {
        var positions = [(Int, Int)]()
        var velocities = [(Int, Int)]()
        data.split(separator: "\n").forEach { line in
            let splitLine = line.split(separator: " ")
            let position = splitLine[0].dropFirst(2).split(separator: ",")
            positions.append((Int(position[0])!, Int(position[1])!))
            let velocity = splitLine[1].dropFirst(2).split(separator: ",")
            velocities.append((Int(velocity[0])!, Int(velocity[1])!))
        }
        self.positions = positions
        self.velocities = velocities
    }
    
    func simulationStep(positions: inout [(Int, Int)], velocities: inout [(Int, Int)]) {
        for i in 0..<positions.count {
            var position = positions[i]
            let velocity = velocities[i]
            
            position.0 += velocity.0
            position.1 += velocity.1
            
            if position.0 >= Self.width {
                position.0 -= Self.width
            } else if position.0 < 0 {
                position.0 += Self.width
            }
            if position.1 >= Self.height {
                position.1 -= Self.height
            } else if position.1 < 0 {
                position.1 += Self.height
            }
            positions[i] = position
        }
    }
    
    enum Quadrant {
        case first
        case second
        case third
        case fourth
    }
    
    func checkQuadrant(position: (Int, Int)) -> Quadrant? {
        let middleX = Self.width / 2
        let middleY = Self.height / 2
        if position.0 > middleX {
            if position.1 > middleY {
                return .third
            } else if position.1 < middleY {
                return .second
            }
        } else if position.0 < middleX {
            if position.1 > middleY {
                return .fourth
            } else if position.1 < middleY {
                return .first
            }
        }
        return nil
    }
    
    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var positions = positions
        var velocities = velocities
        for _ in 0..<100 {
            simulationStep(positions: &positions, velocities: &velocities)
        }
        
        var firstCount: Int = 0
        var secondCount: Int = 0
        var thirdCount: Int = 0
        var fourthCount: Int = 0
        for position in positions {
            switch checkQuadrant(position: position) {
            case .first:
                firstCount += 1
            case .second:
                secondCount += 1
            case .third:
                thirdCount += 1
            case .fourth:
                fourthCount += 1
            case .none:
                break
            }
        }
        
        return firstCount * secondCount * thirdCount * fourthCount
    }
    
    func printPositions(positions: [(Int, Int)]) {
        for j in 0..<Self.height {
            for i in 0..<Self.width {
                if positions.contains(where: { position in
                    position.0 == i && position.1 == j
                }) {
                    print("X", terminator: "")
                } else {
                    print(".", terminator: "")
                }
            }
            print("\n", terminator: "")
        }
        print("\n")
    }
    
    func isChristmasTree(positions: [(Int, Int)]) -> Double {
        let modPositions = positions.map({ ($0.0 - Self.width / 2, $0.1) })
        var matching: Double = 0
        for position in modPositions {
            if modPositions.contains(where: { otherPosition in
                (otherPosition.0 == -position.0) && (otherPosition.1 == position.1)
            }) {
                matching += 1
            } else {
                continue
            }
        }
        return matching / Double(modPositions.count)
    }
    
    func isChristmasTree(positions: [(Int, Int)]) -> Bool {
        for j in 0..<Self.height {
            guard positions.contains(where: {
                ($0.0 == Self.width / 2) && ($0.1 == j)
            }) else {
                return false
            }
        }
        return true
    }
    
    func isChristmasTreeLineCount(positions: [(Int, Int)]) -> Double {
        var robotsPerLine = [Int](repeating: 0, count: Self.height)
        for robot in positions {
            robotsPerLine[robot.1] += 1
        }
        var matchingLines: Double = 0
        for lineIndex in 0..<(Self.height - 1) {
            if (2 * robotsPerLine[lineIndex]) == robotsPerLine[lineIndex + 1] {
                matchingLines += 1
            }
        }
        return matchingLines / Double(Self.height - 1)
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var positions = positions
        var velocities = velocities
        var iteration: Int = 0
        // var currentBestMatch: Double = 0
        while true {
            simulationStep(positions: &positions, velocities: &velocities)
            iteration += 1
            
            if iteration == 6876 {
                print("\(iteration) iterations completed...")
                printPositions(positions: positions)
                return 6876
            }
        }
    }
}
