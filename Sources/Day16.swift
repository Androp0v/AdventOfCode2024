import Algorithms

struct Day16: AdventDay {
    
    enum TileType: Character {
        case empty = "."
        case wall = "#"
        case end = "E"
    }
    
    let grid: [[TileType]]
    let startPosition: GridPosition
    
    // MARK: - Init
    
    init(data: String) {
        var grid = [[TileType]]()
        var start: GridPosition?
        for (j, line) in data.split(separator: "\n").enumerated() {
            var newLine = [TileType]()
            for (i, character) in line.enumerated() {
                switch character {
                case ".":
                    newLine.append(.empty)
                case "#":
                    newLine.append(.wall)
                case "E":
                    newLine.append(.end)
                case "S":
                    newLine.append(.empty)
                    start = GridPosition(i: i, j: j)
                default:
                    fatalError("Unknown character \(character)")
                }
            }
            grid.append(newLine)
        }
        self.grid = grid
        self.startPosition = start!
    }
    
    // MARK: - Functions
    
    enum RotationDirection {
        case clockwise
        case counterclockwise
    }
    
    func rotate(_ direction: Direction, _ rotationDirection: RotationDirection) -> Direction {
        switch direction {
        case .left:
            return rotationDirection == .clockwise ? .up : .down
        case .right:
            return rotationDirection == .clockwise ? .down : .up
        case .up:
            return rotationDirection == .clockwise ? .right : .left
        case .down:
            return rotationDirection == .clockwise ? .left : .right
        }
    }
    
    struct Step {
        let score: Int
        let nextPosition: GridPosition
        let direction: Direction
        let previousPositions: Set<GridPosition>
    }
    
    /// Returns all the possible steps that can be taken after performing the given step.
    ///
    /// After each step, there's 3 options for the next step:
    /// - Go straight.
    /// - Rotate clockwise and go straight.
    /// - Rotate counterclockwise and go straight.
    func nextSteps(after step: Step) -> [Step] {
        var nextSteps = [Step]()
        for (index, direction) in [
            step.direction,
            rotate(step.direction, .clockwise),
            rotate(step.direction, .counterclockwise)
        ].enumerated() {
            let rotationCost = (index == 0) ? 0 : 1000
            let next = nextPosition(step.nextPosition, direction: direction)
            switch grid[next.j][next.i] {
            case .empty, .end:
                var updatedPreviousPositions = step.previousPositions
                updatedPreviousPositions.insert(next)
                nextSteps.append(
                    Step(
                        score: step.score + 1 + rotationCost,
                        nextPosition: next,
                        direction: direction,
                        previousPositions: updatedPreviousPositions
                    )
                )
            case .wall:
                break
            }
        }
        return nextSteps
    }
    
    /// All the possible steps that can be taken from the initial tile.
    func possibleInitialSteps() -> [Int: [Step]] {
        var possibleSteps = [Int: [Step]]()
        for direction in Direction.allCases {
            let nextPosition = nextPosition(startPosition, direction: direction)
            guard grid[nextPosition.j][nextPosition.i] != .wall else { continue }
            let score = direction == .right ? 1 : 1001
            let step = Step(
                score: score,
                nextPosition: nextPosition,
                direction: direction,
                previousPositions: Set<GridPosition>([startPosition, nextPosition])
            )
            possibleSteps[score, default: [Step]()].append(step)
        }
        return possibleSteps
    }
    
    struct Visit: Hashable {
        let position: GridPosition
        let direction: Direction
    }

    // MARK: - Part 1

    func part1() async -> Any {
        var possibleSteps = possibleInitialSteps()
        var visitedWithScore = [Visit: Int]()

        while true {
            let minScore = possibleSteps.keys.min()!
            let lowestScoreSteps = possibleSteps[minScore]!
            possibleSteps[minScore] = nil
            for step in lowestScoreSteps {
                if grid[step.nextPosition.j][step.nextPosition.i] == .end {
                    return step.score
                }
                let nextSteps = nextSteps(after: step)
                for nextStep in nextSteps {
                    let visit = Visit(position: nextStep.nextPosition, direction: nextStep.direction)
                    if let visitedScore = visitedWithScore[visit] {
                        if visitedScore < nextStep.score { continue }
                    }
                    possibleSteps[nextStep.score, default: []].append(nextStep)
                    visitedWithScore[visit] = nextStep.score
                }
            }
        }
    }

    // MARK: - Part 2
    
    func part2() -> Any {
        var possibleSteps: [Int: [Step]] = possibleInitialSteps()
        var visitedWithScore = [Visit: Int]()
        
        var finalSteps = [Step]()
        while true {
            let minScore = possibleSteps.keys.min()!
            let lowestScoreSteps = possibleSteps[minScore]!
            possibleSteps[minScore] = nil
            var shouldEnd = false
            for step in lowestScoreSteps {
                if grid[step.nextPosition.j][step.nextPosition.i] == .end {
                    shouldEnd = true
                    finalSteps.append(step)
                }
                let nextSteps = nextSteps(after: step)
                for nextStep in nextSteps {
                    let visit = Visit(position: nextStep.nextPosition, direction: nextStep.direction)
                    if let visitedScore = visitedWithScore[visit] {
                        if visitedScore < nextStep.score { continue }
                    }
                    possibleSteps[nextStep.score, default: []].append(nextStep)
                    visitedWithScore[visit] = nextStep.score
                }
            }
            if shouldEnd {
                break
            }
        }
        
        var tilesVisitedByFinalPaths = Set<GridPosition>()
        for step in finalSteps {
            for visitedTile in step.previousPositions {
                tilesVisitedByFinalPaths.insert(visitedTile)
            }
            tilesVisitedByFinalPaths.insert(step.nextPosition)
        }
        return tilesVisitedByFinalPaths.count
    }
}

// MARK: - Utility Types

extension Day16 {
    struct GridPosition: Equatable, Hashable {
        let i: Int
        let j: Int
        
        func left() -> GridPosition {
            return GridPosition(i: i - 1, j: j)
        }
        func right() -> GridPosition {
            return GridPosition(i: i + 1, j: j)
        }
        func up() -> GridPosition {
            return GridPosition(i: i, j: j - 1)
        }
        func down() -> GridPosition {
            return GridPosition(i: i, j: j + 1)
        }
    }
    
    enum Direction: CaseIterable {
        case left
        case right
        case up
        case down
    }
    
    func nextPosition(_ position: GridPosition, direction: Direction) -> GridPosition {
        switch direction {
        case .left:
            return position.left()
        case .right:
            return position.right()
        case .up:
            return position.up()
        case .down:
            return position.down()
        }
    }
}
