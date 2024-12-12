import Algorithms

struct Day12: AdventDay {
    
    let grid: [[Character]]
    
    struct GridPosition: Equatable, Hashable {
        let i: Int
        let j: Int
        
        func left(grid: [[Character]]) -> GridPosition? {
            guard (i - 1) >= 0 else { return nil }
            return GridPosition(i: i - 1, j: j)
        }
        func right(grid: [[Character]]) -> GridPosition? {
            guard (i + 1) < grid[0].count else { return nil }
            return GridPosition(i: i + 1, j: j)
        }
        func up(grid: [[Character]]) -> GridPosition? {
            guard (j - 1) >= 0 else { return nil }
            return GridPosition(i: i, j: j - 1)
        }
        func down(grid: [[Character]]) -> GridPosition? {
            guard (j + 1) < grid.count else { return nil }
            return GridPosition(i: i, j: j + 1)
        }
    }
    
    init(data: String) {
        var grid: [[Character]] = []
        data.split(separator: "\n").forEach { line in
            grid.append(line.map({ $0 }))
        }
        self.grid = grid
    }
    
    final class GridRegion {
        let character: Character
        var area: Int
        var perimeter: Int
        var corners: Int
        
        init(character: Character, area: Int, perimeter: Int, corners: Int) {
            self.character = character
            self.area = area
            self.perimeter = perimeter
            self.corners = corners
        }
    }
    
    func countEdges(at position: GridPosition, differentTo character: Character) -> Int {
        var edgeCount: Int = 0
        if let left = position.left(grid: grid) {
            if grid[left.j][left.i] != character {
                edgeCount += 1
            }
        } else  {
            edgeCount += 1
        }
        if let right = position.right(grid: grid) {
            if grid[right.j][right.i] != character {
                edgeCount += 1
            }
        } else  {
            edgeCount += 1
        }
        if let up = position.up(grid: grid) {
            if grid[up.j][up.i] != character {
                edgeCount += 1
            }
        } else  {
            edgeCount += 1
        }
        if let down = position.down(grid: grid) {
            if grid[down.j][down.i] != character {
                edgeCount += 1
            }
        } else  {
            edgeCount += 1
        }
        return edgeCount
    }
    
    func hasLeftEdge(at position: GridPosition, differentTo character: Character) -> Bool {
        if let left = position.left(grid: grid) {
            if grid[left.j][left.i] != character {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    func hasRightEdge(at position: GridPosition, differentTo character: Character) -> Bool {
        if let right = position.right(grid: grid) {
            if grid[right.j][right.i] != character {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    func hasTopEdge(at position: GridPosition, differentTo character: Character) -> Bool {
        if let up = position.up(grid: grid) {
            if grid[up.j][up.i] != character {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    func hasBottomEdge(at position: GridPosition, differentTo character: Character) -> Bool {
        if let down = position.down(grid: grid) {
            if grid[down.j][down.i] != character {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    func countCorners(at position: GridPosition, differentTo character: Character) -> Int {
        var cornerCount: Int = 0
        // "External" corners
        if hasLeftEdge(at: position, differentTo: character) && hasTopEdge(at: position, differentTo: character) {
            cornerCount += 1
        }
        if hasRightEdge(at: position, differentTo: character) && hasTopEdge(at: position, differentTo: character) {
            cornerCount += 1
        }
        if hasLeftEdge(at: position, differentTo: character) && hasBottomEdge(at: position, differentTo: character) {
            cornerCount += 1
        }
        if hasRightEdge(at: position, differentTo: character) && hasBottomEdge(at: position, differentTo: character) {
            cornerCount += 1
        }
        // "Internal" corners
        if let left = position.left(grid: grid), grid[left.j][left.i] == character {
            if let up = position.up(grid: grid), grid[up.j][up.i] == character {
                if hasTopEdge(at: left, differentTo: character) && hasLeftEdge(at: up, differentTo: character) {
                    cornerCount += 1
                }
            }
        }
        if let right = position.right(grid: grid), grid[right.j][right.i] == character {
            if let up = position.up(grid: grid), grid[up.j][up.i] == character {
                if hasTopEdge(at: right, differentTo: character) && hasRightEdge(at: up, differentTo: character) {
                    cornerCount += 1
                }
            }
        }
        if let left = position.left(grid: grid), grid[left.j][left.i] == character {
            if let down = position.down(grid: grid), grid[down.j][down.i] == character {
                if hasBottomEdge(at: left, differentTo: character) && hasLeftEdge(at: down, differentTo: character) {
                    cornerCount += 1
                }
            }
        }
        if let right = position.right(grid: grid), grid[right.j][right.i] == character {
            if let down = position.down(grid: grid), grid[down.j][down.i] == character {
                if hasBottomEdge(at: right, differentTo: character) && hasRightEdge(at: down, differentTo: character) {
                    cornerCount += 1
                }
            }
        }
        return cornerCount
    }
    
    func visitRegion(
        at position: GridPosition,
        in grid: [[Character]],
        extending region: inout GridRegion,
        visited: inout Set<GridPosition>
    ) {
        visited.insert(position)
        region.perimeter += countEdges(at: position, differentTo: region.character)
        region.corners += countCorners(at: position, differentTo: region.character)
        region.area += 1
        
        if let left = position.left(grid: grid), grid[left.j][left.i] == region.character, !visited.contains(left) {
            visitRegion(at: left, in: grid, extending: &region, visited: &visited)
        }
        if let right = position.right(grid: grid), grid[right.j][right.i] == region.character, !visited.contains(right) {
            visitRegion(at: right, in: grid, extending: &region, visited: &visited)
        }
        if let up = position.up(grid: grid), grid[up.j][up.i] == region.character, !visited.contains(up) {
            visitRegion(at: up, in: grid, extending: &region, visited: &visited)
        }
        if let down = position.down(grid: grid), grid[down.j][down.i] == region.character, !visited.contains(down) {
            visitRegion(at: down, in: grid, extending: &region, visited: &visited)
        }
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var alreadyVisited = Set<GridPosition>()
        var regions = [GridRegion]()
        for i in 0..<grid[0].count {
            for j in 0..<grid.count {
                let position = GridPosition(i: i, j: j)
                guard !alreadyVisited.contains(position) else {
                    continue
                }
                let regionCharacter = grid[position.j][position.i]
                var region = GridRegion(character: regionCharacter, area: 0, perimeter: 0, corners: 0)
                visitRegion(
                    at: position,
                    in: grid,
                    extending: &region,
                    visited: &alreadyVisited
                )
                regions.append(region)
            }
        }
        
        var totalFencePrice: Int = 0
        for region in regions {
            totalFencePrice += region.perimeter * region.area
        }
        return totalFencePrice
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var alreadyVisited = Set<GridPosition>()
        var regions = [GridRegion]()
        for i in 0..<grid[0].count {
            for j in 0..<grid.count {
                let position = GridPosition(i: i, j: j)
                guard !alreadyVisited.contains(position) else {
                    continue
                }
                let regionCharacter = grid[position.j][position.i]
                var region = GridRegion(character: regionCharacter, area: 0, perimeter: 0, corners: 0)
                visitRegion(
                    at: position,
                    in: grid,
                    extending: &region,
                    visited: &alreadyVisited
                )
                regions.append(region)
            }
        }
        
        var totalFencePrice: Int = 0
        for region in regions {
            totalFencePrice += region.corners * region.area
        }
        return totalFencePrice
    }
}
