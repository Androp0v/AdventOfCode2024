import Algorithms

struct Day16: AdventDay {
    
    enum TileType: Character {
        case empty = "."
        case wall = "#"
        case end = "E"
    }
    
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
    
    let grid: [[TileType]]
    let startPosition: GridPosition
    
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
    
    func rotateClockwise(_ direction: Direction) -> Direction {
        switch direction {
        case .left:
            return .up
        case .right:
            return .down
        case .up:
            return .right
        case .down:
            return .left
        }
    }
    
    func rotateCounterclockwise(_ direction: Direction) -> Direction {
        switch direction {
        case .left:
            return .down
        case .right:
            return .up
        case .up:
            return .left
        case .down:
            return .right
        }
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
    
    struct Step {
        let score: Int
        let nextPosition: GridPosition
        let direction: Direction
    }
        
    func findMinScore(startingAt: GridPosition, facing direction: Direction, currentScore: Int, visited: [GridPosition]) -> Int? {
        var scores = [Int]()
        for (index, direction) in [
            direction,
            rotateClockwise(direction),
            rotateCounterclockwise(direction)
        ].enumerated() {
            let rotationCost = (index == 0) ? 0 : 1000
            let next = nextPosition(startingAt, direction: direction)
            if !visited.contains(next) {
                switch grid[next.j][next.i] {
                case .empty:
                    var newVisited = visited
                    newVisited.append(next)
                    if let score = findMinScore(
                        startingAt: next,
                        facing: direction,
                        currentScore: currentScore + 1 + rotationCost,
                        visited: newVisited
                    ) {
                        scores.append(score)
                    }
                case .wall:
                    break
                case .end:
                    scores.append(currentScore + 1)
                }
            }
        }
        return scores.min()
    }
    
    func nextSteps(startingAt: GridPosition, facing direction: Direction, currentScore: Int) -> [Step] {
        var nextSteps = [Step]()
        for (index, direction) in [
            direction,
            rotateClockwise(direction),
            rotateCounterclockwise(direction)
        ].enumerated() {
            let rotationCost = (index == 0) ? 0 : 1000
            let next = nextPosition(startingAt, direction: direction)
            switch grid[next.j][next.i] {
            case .empty, .end:
                nextSteps.append(
                    Step(
                        score: currentScore + 1 + rotationCost,
                        nextPosition: next,
                        direction: direction
                    )
                )
            case .wall:
                break
            }
        }
        return nextSteps
    }
    
    struct Visit: Hashable {
        let position: GridPosition
        let direction: Direction
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() async -> Any {
        var possibleSteps = [Int: [Step]]()
        var visitedWithScore = [Visit: Int]()
        for direction in Direction.allCases {
            let nextPosition = nextPosition(startPosition, direction: direction)
            guard grid[nextPosition.j][nextPosition.i] != .wall else { continue }
            let score = direction == .right ? 1 : 1001
            let step = Step(score: score, nextPosition: nextPosition, direction: direction)
            possibleSteps[score, default: [Step]()].append(step)
        }
        while true {
            let minScore = possibleSteps.keys.min()!
            let lowestScoreSteps = possibleSteps[minScore]!
            possibleSteps[minScore] = nil
            // print("Current score: \(minScore)")
            for step in lowestScoreSteps {
                if grid[step.nextPosition.j][step.nextPosition.i] == .end {
                    return step.score
                }
                let nextSteps = nextSteps(
                    startingAt: step.nextPosition,
                    facing: step.direction,
                    currentScore: step.score
                )
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

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        return 0
    }
}
