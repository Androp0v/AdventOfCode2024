import Algorithms

struct Day18: AdventDay {
    
    enum TileType {
        case corrupted
        case safe
    }
    
    struct GridPosition: Equatable, Hashable {
        let i: Int
        let j: Int
        
        func left(grid: [[TileType]]) -> GridPosition? {
            guard (i - 1) >= 0 else { return nil }
            return GridPosition(i: i - 1, j: j)
        }
        func right(grid: [[TileType]]) -> GridPosition? {
            guard (i + 1) < grid[0].count else { return nil }
            return GridPosition(i: i + 1, j: j)
        }
        func up(grid: [[TileType]]) -> GridPosition? {
            guard (j - 1) >= 0 else { return nil }
            return GridPosition(i: i, j: j - 1)
        }
        func down(grid: [[TileType]]) -> GridPosition? {
            guard (j + 1) < grid.count else { return nil }
            return GridPosition(i: i, j: j + 1)
        }
    }
    
    let bytes: [GridPosition]
    
    init(data: String) {
        var bytes = [GridPosition]()
        for line in data.split(separator: "\n") {
            let rawLine = line.split(separator: ",")
            bytes.append(GridPosition(
                i: Int(rawLine[0])!,
                j: Int(rawLine[1])!
            ))
        }
        self.bytes = bytes
    }
    
    func createGrid(corruptedBytes: some Sequence<GridPosition>, width: Int, height: Int) -> [[TileType]] {
        let row = [TileType](repeating: .safe, count: width)
        var grid = [[TileType]](repeating: row, count: height)
        
        for position in corruptedBytes {
            grid[position.j][position.i] = .corrupted
        }
        return grid
    }
    
    
    enum Direction: CaseIterable {
        case left
        case right
        case up
        case down
    }
    
    func manhattanDistance(from a: GridPosition, to b: GridPosition) -> Int {
        return abs(a.i - b.i) + abs(a.j - b.j)
    }
    
    
    func shortestPathLength(from initial: GridPosition, to final: GridPosition, in grid: [[TileType]]) -> Int? {
        let firstNode = initial
        
        var nodeCost = [GridPosition: Int]()
        nodeCost[initial] = 0
        var estimatedFullCost = [GridPosition: Int]()
        estimatedFullCost[initial] = nodeCost[initial]! + manhattanDistance(from: initial, to: final)
        
        var openNodes = Set<GridPosition>()
        openNodes.insert(firstNode)
        
        while true {
            guard !openNodes.isEmpty else {
                return nil
            }
            let currentNodeCost = openNodes.map({ nodeCost[$0]! + manhattanDistance(from: $0, to: final) }).min()!
            let currentNode = openNodes.first(where: {
                (nodeCost[$0]! + manhattanDistance(from: $0, to: final)) == currentNodeCost
            })!
            openNodes.remove(currentNode)
                        
            if currentNode == final {
                return nodeCost[currentNode]!
            }
            
            for direction in Direction.allCases {
                let next = switch direction {
                case .up:
                    currentNode.up(grid: grid)
                case .down:
                    currentNode.down(grid: grid)
                case .left:
                    currentNode.left(grid: grid)
                case .right:
                    currentNode.right(grid: grid)
                }
                if let next, grid[next.j][next.i] != .corrupted {
                    let nextScore = nodeCost[currentNode]! + 1
                    if nextScore < nodeCost[next, default: Int.max] {
                        nodeCost[next] = nextScore
                        openNodes.insert(next)
                    }
                }
            }
        }
    }


    // MARK: - Part 1
    
    func part1() -> Any {
        let grid = createGrid(
            corruptedBytes: self.bytes.prefix(1024), // (1024),
            width: 71,
            height: 71
        )
        let startPoint = GridPosition(i: 0, j: 0)
        let endPoint = GridPosition(i: 70, j: 70)
        return shortestPathLength(from: startPoint, to: endPoint, in: grid)!
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        let startPoint = GridPosition(i: 0, j: 0)
        let endPoint = GridPosition(i: 70, j: 70)
        for byteCount in 1..<self.bytes.count {
            let grid = createGrid(
                corruptedBytes: self.bytes.prefix(byteCount),
                width: 71,
                height: 71
            )
            guard shortestPathLength(from: startPoint, to: endPoint, in: grid) != nil else {
                return self.bytes[byteCount - 1]
            }
        }
        fatalError()
    }
}
