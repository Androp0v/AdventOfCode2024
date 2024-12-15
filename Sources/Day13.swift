import Algorithms
import Foundation

struct Day13: AdventDay {
    
    struct GridDelta {
        let x: Int
        let y: Int
        
        var decimal: DecimalGridDelta {
            return DecimalGridDelta(
                x: Decimal(x),
                y: Decimal(y)
            )
        }
    }
    
    struct DecimalGridDelta {
        let x: Decimal
        let y: Decimal
    }
    
    struct Machine {
        let buttonA: GridDelta
        let buttonB: GridDelta
        let prize: GridDelta
        
        var correctedPrize: GridDelta {
            return GridDelta(
                x: prize.x + 10000000000000,
                y: prize.y + 10000000000000
            )
        }
    }
    
    let machines: [Machine]
    static let aCost: Int = 3
    static let bCost: Int = 1
    
    init(data: String) {
        var machines = [Machine]()
        data.split(separator: "\n\n").forEach { machineText in
            let lines = machineText.split(separator: "\n")
            
            var rawButtonA = lines[0].dropFirst(10).split(separator: ", ")
            rawButtonA[0] = rawButtonA[0].replacing("X", with: "")
            rawButtonA[1] = rawButtonA[1].replacing("Y", with: "")
            
            var rawButtonB = lines[1].dropFirst(10).split(separator: ", ")
            rawButtonB[0] = rawButtonB[0].replacing("X", with: "")
            rawButtonB[1] = rawButtonB[1].replacing("Y", with: "")
            
            var rawPrize = lines[2].dropFirst(7).split(separator: ", ")
            rawPrize[0] = rawPrize[0].replacing("X=", with: "")
            rawPrize[1] = rawPrize[1].replacing("Y=", with: "")
            
            machines.append(Machine(
                buttonA: GridDelta(x: Int(rawButtonA[0])!, y: Int(rawButtonA[1])!),
                buttonB: GridDelta(x: Int(rawButtonB[0])!, y: Int(rawButtonB[1])!),
                prize: GridDelta(x: Int(rawPrize[0])!, y: Int(rawPrize[1])!))
            )
        }
        self.machines = machines
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var totalTokens: Int = 0
        for machine in machines {
            var lowestTokens: Int?
            let prizeX = machine.prize.x
            let prizeY = machine.prize.y
            for aPresses in 0..<100 {
                for bPresses in 0..<100 {
                    let resultPositionX = machine.buttonA.x * aPresses + machine.buttonB.x * bPresses
                    let resultPositionY = machine.buttonA.y * aPresses + machine.buttonB.y * bPresses
                    guard resultPositionX == prizeX && resultPositionY == prizeY else { continue }
                    let cost = Self.aCost * aPresses + Self.bCost * bPresses
                    if let currentLowestTokens = lowestTokens {
                        if currentLowestTokens > cost {
                            lowestTokens = cost
                        }
                    } else {
                        lowestTokens = cost
                        /*
                        if let (x, y) = calculateXY(
                            deltaA: machine.buttonA.decimal,
                            deltaB: machine.buttonB.decimal,
                            prize: machine.prize.decimal
                        ) {
                            
                        } else {
                            fatalError("No XY found...")
                        }
                         */
                    }
                }
            }
            if let lowestTokens {
                totalTokens += lowestTokens
            }
        }
        return totalTokens
    }
    
    func calculateXY(deltaA: GridDelta, deltaB: GridDelta, prize: GridDelta) -> (Int, Int)? {
        let num = deltaB.y * prize.x - deltaB.x * prize.y
        let denom = deltaB.y * deltaA.x - deltaB.x * deltaA.y
        guard num % denom == 0 else { return nil }
        let x = num / denom
        
        let num2 = prize.x * deltaA.y - prize.y * deltaA.x
        let denom2 = deltaB.x * deltaA.y - deltaB.y * deltaA.x
        guard num2 % denom2 == 0 else { return nil }
        let y = num2 / denom2
        
        return (x, y)
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var totalTokens: Int = 0
        for (_, machine) in machines.enumerated() {
            // print(("Machine \(index) of \(machines.count)"))
            if let (x, y) = calculateXY(
                deltaA: machine.buttonA,
                deltaB: machine.buttonB,
                prize: machine.correctedPrize
            ) {
                totalTokens += Self.aCost * x + Self.bCost * y
            }
        }
        return totalTokens
    }
}
