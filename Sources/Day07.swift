import Algorithms

struct Day07: AdventDay {
    
    struct Equation {
        let result: Int
        let numbers: [Int]
    }
    let equations: [Equation]
    
    enum EQOperator: CustomDebugStringConvertible {
        case add
        case multiply
        case concat
        
        var debugDescription: String {
            switch self {
            case .add:
                return "ADD"
            case .multiply:
                return "MUL"
            case .concat:
                return "CONCAT"
            }
        }
    }

    init(data: String) {
        var equations = [Equation]()
        for line in data.split(separator: "\n") {
            let splitLine = line.split(separator: ": ")
            equations.append(Equation(
                result: Int(splitLine[0])!,
                numbers: splitLine[1].split(separator: " ").map { Int($0)! }
            ))
        }
        self.equations = equations
    }
    
    func buildOperatorSequences(length: Int, allowConcat: Bool) -> [[EQOperator]] {
        if length == 1 {
            if allowConcat {
                return [[.add], [.multiply], [.concat]]
            } else {
                return [[.add], [.multiply]]
            }
        }
        var result = [[EQOperator]]()
        for sequence in buildOperatorSequences(length: length - 1, allowConcat: allowConcat) {
            var sequenceA = sequence
            sequenceA.append(.add)
            var sequenceB = sequence
            sequenceB.append(.multiply)
            result.append(sequenceA)
            result.append(sequenceB)
            if allowConcat {
                var sequenceC = sequence
                sequenceC.append(.concat)
                result.append(sequenceC)
            }
        }
        return result
    }
    
    func testValue(of equation: Equation, allowConcat: Bool) -> Bool {
        let operatorCount = equation.numbers.count - 1
        let operatorSequences = buildOperatorSequences(length: operatorCount, allowConcat: allowConcat)
        
        for operatorSequence in operatorSequences {
            // Compute the equation
            var partialResult = equation.numbers.first!
            for (index, eqOperator) in operatorSequence.enumerated() {
                switch eqOperator {
                case .add:
                    partialResult += equation.numbers[index + 1]
                case .multiply:
                    partialResult *= equation.numbers[index + 1]
                case .concat:
                    partialResult = Int(String(partialResult) + String(equation.numbers[index + 1]))!
                }
            }
            if partialResult == equation.result {
                return true
            }
        }
        return false
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var total: Int = 0
        for equation in equations {
            if testValue(of: equation, allowConcat: false) {
                total += equation.result
            }
        }
        return total
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var total: Int = 0
        for equation in equations {
            if testValue(of: equation, allowConcat: true) {
                total += equation.result
            }
        }
        return total
    }
}
