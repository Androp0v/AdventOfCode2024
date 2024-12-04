import Algorithms
import os

struct Day04: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String
    
    var lines: [[Character]] {
        return data.split(separator: "\n").map({ Array($0) })
    }
    var lineLength: Int {
        return lines[0].count
    }
    var numberOfLines: Int {
        return lines.count
    }

    // Splits input data into its component parts and convert from string.
    var entities: [[Int]] {
        data.split(separator: "\n\n").map {
            $0.split(separator: "\n").compactMap { Int($0) }
        }
    }
    
    func update(previousMatch: inout String, matchCount: inout Int, newCharacter: Character) {
        if newCharacter == "X" {
            previousMatch = "X"
        } else if previousMatch == "X" && newCharacter == "M" {
            previousMatch.append("M")
        } else if previousMatch == "XM" && newCharacter == "A" {
            previousMatch.append("A")
        } else if previousMatch == "XMA" && newCharacter == "S" {
            previousMatch = ""
            matchCount += 1
        } else {
            previousMatch = ""
        }
    }

    func searchHorizontal(backwards: Bool) -> Int {
        var matchCount = 0
        var previousMatch = ""
        for j in 0..<numberOfLines {
            previousMatch = ""
            let sequence: any Sequence<Int> = if !backwards {
                0..<lineLength
            } else {
                (0..<lineLength).reversed()
            }
            for i in sequence {
                let character = lines[j][i]
                update(
                    previousMatch: &previousMatch,
                    matchCount: &matchCount,
                    newCharacter: character
                )
            }
        }
        if !backwards {
            print("Horizontal: \(matchCount)")
        } else {
            print("Horizontal (backwards): \(matchCount)")
        }
        return matchCount
    }
    
    func searchVertical(backwards: Bool) -> Int {
        var matchCount = 0
        var previousMatch = ""
        for i in 0..<lineLength {
            previousMatch = ""
            let sequence: any Sequence<Int> = if !backwards {
                0..<numberOfLines
            } else {
                (0..<numberOfLines).reversed()
            }
            for j in sequence {
                let character = lines[j][i]
                update(
                    previousMatch: &previousMatch,
                    matchCount: &matchCount,
                    newCharacter: character
                )
            }
        }
        if !backwards {
            print("Vertical: \(matchCount)")
        } else {
            print("Vertical (backwards): \(matchCount)")
        }
        return matchCount
    }
    
    func searchForwardDiagonal(backwards: Bool) -> Int {
        var matchCount = 0
        var previousMatch = ""
        for i in 0..<lineLength {
            previousMatch = ""
            let diagonalLength = min(lineLength - i, numberOfLines - 0)
            let sequence: any Sequence<Int> = if !backwards {
                0..<diagonalLength
            } else {
                (0..<diagonalLength).reversed()
            }
            for k in sequence {
                let character = lines[0 + k][i + k]
                update(
                    previousMatch: &previousMatch,
                    matchCount: &matchCount,
                    newCharacter: character
                )
            }
        }
        for j in 1..<numberOfLines {
            previousMatch = ""
            let diagonalLength = min(lineLength - 0, numberOfLines - j)
            let sequence: any Sequence<Int> = if !backwards {
                0..<diagonalLength
            } else {
                (0..<diagonalLength).reversed()
            }
            for k in sequence {
                let character = lines[j + k][0 + k]
                update(
                    previousMatch: &previousMatch,
                    matchCount: &matchCount,
                    newCharacter: character
                )
            }
        }
        if !backwards {
            print("Forward diagonal: \(matchCount)")
        } else {
            print("Forward diagonal (backwards): \(matchCount)")
        }
        return matchCount
    }
    
    func searchBackwardDiagonal(backwards: Bool) -> Int {
        var matchCount = 0
        var previousMatch = ""
        for i in 0..<lineLength {
            // print("I: \(i), J: 0")
            previousMatch = ""
            let diagonalLength = min(i, numberOfLines) + 1
            let sequence: any Sequence<Int> = if !backwards {
                0..<diagonalLength
            } else {
                (0..<diagonalLength).reversed()
            }
            for k in sequence {
                let character = lines[0 + k][i - k]
                // print("(i: \(i - k), j: \(0 + k)) -> \(character)")
                update(
                    previousMatch: &previousMatch,
                    matchCount: &matchCount,
                    newCharacter: character
                )
            }
            // print("\n")
        }
        for j in 1..<numberOfLines {
            // print("I: \(numberOfLines - 1), J: \(j)")
            previousMatch = ""
            let diagonalLength = min(numberOfLines - 1, numberOfLines - j)
            let sequence: any Sequence<Int> = if !backwards {
                0..<diagonalLength
            } else {
                (0..<diagonalLength).reversed()
            }
            for k in sequence {
                let character = lines[j + k][numberOfLines - 1 - k]
                // print("(i: \(numberOfLines - 1 - k), j: \(j + k)) -> \(character)")
                update(
                    previousMatch: &previousMatch,
                    matchCount: &matchCount,
                    newCharacter: character
                )
            }
        }
        // print("\n")
        if !backwards {
            print("Backward diagonal: \(matchCount)")
        } else {
            print("Backward diagonal (backwards): \(matchCount)")
        }
        return matchCount
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() async -> Any {
        async let horizontal = searchHorizontal(backwards: false)
        async let horizontalB = searchHorizontal(backwards: true)
        async let vertical = searchVertical(backwards: false)
        async let verticalB = searchVertical(backwards: true)
        async let forwardDiagonal = searchForwardDiagonal(backwards: false)
        async let forwardDiagonalB = searchForwardDiagonal(backwards: true)
        async let backwardDiagonal = searchBackwardDiagonal(backwards: false)
        async let backwardDiagonalB = searchBackwardDiagonal(backwards: true)
        let total = await horizontal
            + horizontalB
            + vertical
            + verticalB
            + forwardDiagonal
            + forwardDiagonalB
            + backwardDiagonal
            + backwardDiagonalB
        print("TOTAL: \(total)")
        return total
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var matchCount = 0
        for j in 0..<(numberOfLines - 2) {
            for i in 0..<(lineLength - 2) {
                let diagonalA = String(lines[j][i]) + String(lines[j + 1][i + 1]) + String(lines[j + 2][i + 2])
                let diagonalB = String(lines[j][i + 2]) + String(lines[j + 1][i + 1]) + String(lines[j + 2][i])
                guard diagonalA == "MAS" || diagonalA == "SAM" else {
                    continue
                }
                guard diagonalB == "MAS" || diagonalB == "SAM" else {
                    continue
                }
                matchCount += 1
            }
        }
        return matchCount
    }
}
