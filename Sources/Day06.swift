import Algorithms

final class Day06: AdventDay, @unchecked Sendable {
    var part1Grid: [[String]]
    let part2Grid: [[String]]
    
    init(data: String) {
        var grid = [[String]]()
        data.split(separator: "\n").forEach { rawLine in
            var line = [String]()
            for character in rawLine {
                line.append(String(character))
            }
            grid.append(line)
        }
        self.part1Grid = grid
        self.part2Grid = grid
    }
    
    struct Position {
        let i: Int
        let j: Int
    }
    
    enum Direction {
        case up
        case right
        case down
        case left
        
        func rotate() -> Direction {
            switch self {
            case .up:
                return .right
            case .right:
                return .down
            case .down:
                return .left
            case .left:
                return .up
            }
        }
    }
    
    func findInitialPosition(grid: [[String]]) -> Position {
        for (j, line) in grid.enumerated() {
            for (i, character) in line.enumerated() {
                if character == "^" {
                    return Position(i: i, j: j)
                }
            }
        }
        fatalError("^ not in grid")
    }
    
    func isOutOfBounds(_ position: Position, grid: [[String]]) -> Bool {
        if position.j < 0 {
            return true
        } else if position.i < 0 {
            return true
        } else if position.j >= grid.count {
            return true
        } else if position.i >= grid[0].count {
            return true
        }
        return false
    }
    
    func getUncheckedNewPosition(from position: Position, direction: inout Direction) -> Position {
        switch direction {
        case .up:
            return Position(i: position.i, j: position.j - 1)
        case .right:
            return Position(i: position.i + 1, j: position.j)
        case .down:
            return Position(i: position.i, j: position.j + 1)
        case .left:
            return Position(i: position.i - 1, j: position.j)
        }
    }
    
    func getNewPositionWithRotation(from position: Position, direction: inout Direction, grid: [[String]]) throws -> Position {
        let newPosition = getUncheckedNewPosition(
            from: position,
            direction: &direction
        )
        guard !isOutOfBounds(newPosition, grid: grid) else {
            throw Day06Error.outOfBounds
        }
        guard grid[newPosition.j][newPosition.i] != "#" else {
            direction = direction.rotate()
            return try getNewPositionWithRotation(from: position, direction: &direction, grid: grid)
        }
        return newPosition
    }
    
    func moveUntilOut(from initialPosition: Position) -> Int {
        var direction: Direction = .up
        var position = initialPosition
        while true {
            part1Grid[position.j][position.i] = "X"
            do {
                position = try getNewPositionWithRotation(
                    from: position,
                    direction: &direction,
                    grid: part1Grid
                )
            } catch {
                break
            }
        }
        
        var stepCount: Int = 0
        for line in part1Grid {
            for character in line {
                if character == "X" {
                    stepCount += 1
                }
            }
        }
        return stepCount
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        let initialPosition = findInitialPosition(grid: part1Grid)
        return moveUntilOut(from: initialPosition)
    }
    
    func checkHasInfiniteLoop(initialPosition: Position, newGrid: inout [[String]]) -> Bool {
        var direction: Direction = .up
        var position = initialPosition
        while true {
            do {
                let existingGridValue = newGrid[position.j][position.i]
                switch direction {
                case .up:
                    if existingGridValue.contains("U") {
                        throw Day06Error.loop
                    }
                    newGrid[position.j][position.i].append("U")
                case .down:
                    if existingGridValue.contains("D") {
                        throw Day06Error.loop
                    }
                    newGrid[position.j][position.i].append("D")
                case .left:
                    if existingGridValue.contains("L") {
                        throw Day06Error.loop
                    }
                    newGrid[position.j][position.i].append("L")
                case .right:
                    if existingGridValue.contains("R") {
                        throw Day06Error.loop
                    }
                    newGrid[position.j][position.i].append("R")
                }
                position = try getNewPositionWithRotation(
                    from: position,
                    direction: &direction,
                    grid: newGrid
                )
            } catch let error {
                guard let error = error as? Day06Error else {
                    fatalError()
                }
                switch error {
                case .outOfBounds:
                    return false
                case .loop:
                    return true
                }
            }
        }
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var loopCount: Int = 0
        let initialPosition = findInitialPosition(grid: part2Grid)
        for i in 0..<part2Grid[0].count {
            for j in 0..<part2Grid.count {
                if part2Grid[j][i] == "#" || part2Grid[j][i] == "^" {
                    continue
                }
                var newGrid = part2Grid
                newGrid[j][i] = "#"
                if checkHasInfiniteLoop(initialPosition: initialPosition, newGrid: &newGrid) {
                    loopCount += 1
                }
            }
        }
        
        return loopCount
    }
}

enum Day06Error: Error {
    case outOfBounds
    case loop
}
