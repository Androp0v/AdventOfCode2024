import Algorithms

struct Day15: AdventDay {
    
    enum TileType: Character {
        case wall = "#"
        case box = "O"
        case empty = "."
        
        init(rawValue: Character) {
            switch rawValue {
            case "#":
                self = .wall
            case "O":
                self = .box
            case ".", "@":
                self = .empty
            default:
                fatalError()
            }
        }
    }
    
    enum Direction: Character {
        case left = "<"
        case right = ">"
        case up = "^"
        case down = "v"
    }
    
    let initialGrid: [[TileType]]
    let initialRobotPosition: GridPosition
    let robotMoves: [Direction]
    
    struct GridPosition: Equatable, Hashable {
        let i: Int
        let j: Int
        
        func left(grid: [[TileType]]) -> GridPosition? {
            guard (i - 1) >= 0 else { return nil }
            return GridPosition(i: i - 1, j: j)
        }
        func left(grid: [[NewTileType]]) -> GridPosition? {
            guard (i - 1) >= 0 else { return nil }
            return GridPosition(i: i - 1, j: j)
        }
        func right(grid: [[TileType]]) -> GridPosition? {
            guard (i + 1) < grid[0].count else { return nil }
            return GridPosition(i: i + 1, j: j)
        }
        func right(grid: [[NewTileType]]) -> GridPosition? {
            guard (i + 1) < grid[0].count else { return nil }
            return GridPosition(i: i + 1, j: j)
        }
        func up(grid: [[TileType]]) -> GridPosition? {
            guard (j - 1) >= 0 else { return nil }
            return GridPosition(i: i, j: j - 1)
        }
        func up(grid: [[NewTileType]]) -> GridPosition? {
            guard (j - 1) >= 0 else { return nil }
            return GridPosition(i: i, j: j - 1)
        }
        func down(grid: [[TileType]]) -> GridPosition? {
            guard (j + 1) < grid.count else { return nil }
            return GridPosition(i: i, j: j + 1)
        }
        func down(grid: [[NewTileType]]) -> GridPosition? {
            guard (j + 1) < grid.count else { return nil }
            return GridPosition(i: i, j: j + 1)
        }
    }
    
    init(data: String) {
        var grid = [[TileType]]()
        var robotPosition: GridPosition?
        var moves = [Direction]()
        for (j, line) in data.split(separator: "\n").enumerated() {
            if line.starts(with: "#") {
                var lineTiles = [TileType]()
                for (i, character) in line.enumerated() {
                    lineTiles.append(TileType(rawValue: character))
                    if character == "@" {
                        robotPosition = GridPosition(i: i, j: j)
                    }
                }
                grid.append(lineTiles)
            } else {
                for character in line {
                    guard character != "\n" else { continue }
                    moves.append(Direction(rawValue: character)!)
                }
            }
        }
        self.initialGrid = grid
        self.initialRobotPosition = robotPosition!
        self.robotMoves = moves
    }
    
    func canMove(boxAt: GridPosition, direction: Direction, in grid: [[TileType]]) -> Bool {
        
        let newPosition = switch direction {
        case .left:
            boxAt.left(grid: grid)!
        case .right:
            boxAt.right(grid: grid)!
        case .up:
            boxAt.up(grid: grid)!
        case .down:
            boxAt.down(grid: grid)!
        }
        
        switch grid[newPosition.j][newPosition.i] {
        case .wall:
            return false
        case .empty:
            return true
        case .box:
            return canMove(boxAt: newPosition, direction: direction, in: grid)
        }
    }
    
    func moveBoxes(_ boxAt: GridPosition, direction: Direction, in grid: inout [[TileType]]) {
        let newPosition = switch direction {
        case .left:
            boxAt.left(grid: grid)!
        case .right:
            boxAt.right(grid: grid)!
        case .up:
            boxAt.up(grid: grid)!
        case .down:
            boxAt.down(grid: grid)!
        }
        
        let targetType = grid[newPosition.j][newPosition.i]
        
        grid[newPosition.j][newPosition.i] = .box
        
        switch targetType {
        case .wall:
            fatalError()
        case .box:
            moveBoxes(newPosition, direction: direction, in: &grid)
        case .empty:
            return
        }
    }
    
    func moveInGrid(robot: inout GridPosition, direction: Direction, grid: inout [[TileType]]) {
        let newPosition = switch direction {
        case .left:
            robot.left(grid: grid)!
        case .right:
            robot.right(grid: grid)!
        case .up:
            robot.up(grid: grid)!
        case .down:
            robot.down(grid: grid)!
        }
        
        switch grid[newPosition.j][newPosition.i] {
        case .wall:
            return
        case .box:
            guard canMove(boxAt: newPosition, direction: direction, in: grid) else {
                return
            }
            moveBoxes(newPosition, direction: direction, in: &grid)
            robot = newPosition
            grid[robot.j][robot.i] = .empty
        case .empty:
            robot = newPosition
        }
    }
    
    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var grid = initialGrid
        var robot = initialRobotPosition
        for move in robotMoves {
            // printGrid(grid, robotPosition: robot)
            moveInGrid(robot: &robot, direction: move, grid: &grid)
        }
        
        
        var total: Int = 0
        for i in 0..<grid[0].count {
            for j in 0..<grid.count {
                guard grid[j][i] == .box else { continue }
                total += (100 * j) + i
            }
        }
        return total
    }
    
    // MARK: - Part 2
    
    enum NewTileType: Character {
        case wall = "#"
        case boxLeft = "["
        case boxRight = "]"
        case empty = "."
    }
    
    func transformGrid(_ original: [[TileType]]) -> [[NewTileType]] {
        var newGrid = [[NewTileType]]()
        for j in 0..<original.count {
            var newGridLine = [NewTileType]()
            for i in 0..<original[0].count {
                switch original[j][i] {
                case .wall:
                    newGridLine.append(.wall)
                    newGridLine.append(.wall)
                case .box:
                    newGridLine.append(.boxLeft)
                    newGridLine.append(.boxRight)
                case .empty:
                    newGridLine.append(.empty)
                    newGridLine.append(.empty)
                }
            }
            newGrid.append(newGridLine)
        }
        return newGrid
    }
    
    func canMove(boxAt: GridPosition, direction: Direction, in grid: [[NewTileType]]) -> Bool {
        
        let newPosition = switch direction {
        case .left:
            boxAt.left(grid: grid)!
        case .right:
            boxAt.right(grid: grid)!
        case .up:
            boxAt.up(grid: grid)!
        case .down:
            boxAt.down(grid: grid)!
        }
        
        switch grid[newPosition.j][newPosition.i] {
        case .wall:
            return false
        case .empty:
            return true
        case .boxLeft:
            switch direction {
            case .left, .right:
                return canMove(boxAt: newPosition, direction: direction, in: grid)
            case .up, .down:
                let canMoveLeftSide = canMove(
                    boxAt: newPosition,
                    direction: direction,
                    in: grid
                )
                let canMoveRightSide = canMove(
                    boxAt: GridPosition(i: newPosition.i + 1, j: newPosition.j),
                    direction: direction,
                    in: grid
                )
                return canMoveLeftSide && canMoveRightSide
            }
        case .boxRight:
            switch direction {
            case .left, .right:
                return canMove(boxAt: newPosition, direction: direction, in: grid)
            case .up, .down:
                let canMoveLeftSide = canMove(
                    boxAt: GridPosition(i: newPosition.i - 1, j: newPosition.j),
                    direction: direction,
                    in: grid
                )
                let canMoveRightSide = canMove(
                    boxAt: newPosition,
                    direction: direction,
                    in: grid
                )
                return canMoveLeftSide && canMoveRightSide
            }
        }
    }
    
    func moveBoxes(_ boxAt: GridPosition, direction: Direction, in grid: inout [[NewTileType]]) {
        let currentBoxType = grid[boxAt.j][boxAt.i]
        guard currentBoxType == .boxLeft || currentBoxType == .boxRight else {
            fatalError()
        }
        
        let (newPositions, boxTypes) = switch direction {
        case .left:
            ([boxAt.left(grid: grid)!], [currentBoxType])
        case .right:
            ([boxAt.right(grid: grid)!], [currentBoxType])
        case .up:
            switch currentBoxType {
            case .boxLeft:
                ([boxAt.up(grid: grid)!, boxAt.up(grid: grid)!.right(grid: grid)! ], [.boxLeft, .boxRight])
            case .boxRight:
                ([boxAt.up(grid: grid)!, boxAt.up(grid: grid)!.left(grid: grid)! ], [.boxRight, .boxLeft])
            default:
                fatalError()
            }
        case .down:
            switch currentBoxType {
            case .boxLeft:
                ([boxAt.down(grid: grid)!, boxAt.down(grid: grid)!.right(grid: grid)! ], [.boxLeft, .boxRight])
            case .boxRight:
                ([boxAt.down(grid: grid)!, boxAt.down(grid: grid)!.left(grid: grid)! ], [.boxRight, .boxLeft])
            default:
                fatalError()
            }
        }
        
        for (newPosition, boxType) in zip(newPositions, boxTypes) {
            let targetType = grid[newPosition.j][newPosition.i]
            
            switch targetType {
            case .wall:
                fatalError()
            case .boxLeft, .boxRight:
                moveBoxes(newPosition, direction: direction, in: &grid)
            case .empty:
                break
            }
            
            grid[newPosition.j][newPosition.i] = boxType
            switch direction {
            case .left:
                grid[newPosition.j][newPosition.i + 1] = .empty
            case .right:
                grid[newPosition.j][newPosition.i - 1] = .empty
            case .up:
                grid[newPosition.j + 1][newPosition.i] = .empty
            case .down:
                grid[newPosition.j - 1][newPosition.i] = .empty
            }
        }
    }
    
    func moveInGrid(robot: inout GridPosition, direction: Direction, grid: inout [[NewTileType]]) {
        let newPosition = switch direction {
        case .left:
            robot.left(grid: grid)!
        case .right:
            robot.right(grid: grid)!
        case .up:
            robot.up(grid: grid)!
        case .down:
            robot.down(grid: grid)!
        }
        
        switch grid[newPosition.j][newPosition.i] {
        case .wall:
            return
        case .boxLeft:
            let canMoveLeftSide = canMove(boxAt: newPosition, direction: direction, in: grid)
            let canMoveRightSide = canMove(
                boxAt: GridPosition(i: newPosition.i + 1, j: newPosition.j),
                direction: direction,
                in: grid
            )
            guard canMoveLeftSide && canMoveRightSide else {
                return
            }
            moveBoxes(newPosition, direction: direction, in: &grid)
            robot = newPosition
        case .boxRight:
            let canMoveLeftSide = canMove(
                boxAt: GridPosition(i: newPosition.i - 1, j: newPosition.j),
                direction: direction,
                in: grid
            )
            let canMoveRightSide = canMove(boxAt: newPosition, direction: direction, in: grid)
            guard canMoveLeftSide && canMoveRightSide else {
                return
            }
            moveBoxes(newPosition, direction: direction, in: &grid)
            robot = newPosition
        case .empty:
            robot = newPosition
        }
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var newGrid = transformGrid(initialGrid)
        var robot = GridPosition(
            i: 2 * initialRobotPosition.i,
            j: initialRobotPosition.j
        )
        for move in robotMoves {
            // print("Move \(move)")
            // printGrid(newGrid, robotPosition: robot)
            moveInGrid(robot: &robot, direction: move, grid: &newGrid)
        }
        // printGrid(newGrid, robotPosition: robot)
        
        var total: Int = 0
        for i in 0..<newGrid[0].count {
            for j in 0..<newGrid.count {
                guard newGrid[j][i] == .boxLeft else { continue }
                total += (100 * j) + i
            }
        }
        return total
    }
    
    func printGrid(_ grid: [[TileType]], robotPosition: GridPosition) {
        for j in 0..<grid.count {
            for i in 0..<grid[0].count {
                if i == robotPosition.i && j == robotPosition.j {
                    print("@", terminator: "")
                    continue
                }
                print(grid[j][i].rawValue, terminator: "")
            }
            print("\n", terminator: "")
        }
    }
    
    func printGrid(_ grid: [[NewTileType]], robotPosition: GridPosition) {
        for j in 0..<grid.count {
            for i in 0..<grid[0].count {
                if i == robotPosition.i && j == robotPosition.j {
                    print("@", terminator: "")
                    continue
                }
                print(grid[j][i].rawValue, terminator: "")
            }
            print("\n", terminator: "")
        }
    }
}
