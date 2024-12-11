import Algorithms

struct Day10: AdventDay {
    
    let grid: [[Int]]
    
    struct GridPosition: Equatable, Hashable {
        let i: Int
        let j: Int
        
        func left(grid: [[Int]]) -> GridPosition? {
            guard (i - 1) >= 0 else { return nil }
            return GridPosition(i: i - 1, j: j)
        }
        func right(grid: [[Int]]) -> GridPosition? {
            guard (i + 1) < grid[0].count else { return nil }
            return GridPosition(i: i + 1, j: j)
        }
        func up(grid: [[Int]]) -> GridPosition? {
            guard (j - 1) >= 0 else { return nil }
            return GridPosition(i: i, j: j - 1)
        }
        func down(grid: [[Int]]) -> GridPosition? {
            guard (j + 1) < grid.count else { return nil }
            return GridPosition(i: i, j: j + 1)
        }
    }
    
    init(data: String) {
        var grid: [[Int]] = []
        for line in data.split(separator: "\n") {
            grid.append(line.map( { Int(String($0))! }))
        }
        self.grid = grid
    }
    
    func isTrailhead(_ value: Int) -> Bool {
        return value == 0
    }
    
    func getTrailTops(reachableFrom currentPosition: GridPosition, visited: [GridPosition]) -> Set<GridPosition> {
        let currentValue = grid[currentPosition.j][currentPosition.i]
        let nextValue = currentValue + 1
        if currentValue == 9 {
            var set = Set<GridPosition>()
            set.insert(currentPosition)
            return set
        }
        
        var visited = visited
        visited.append(currentPosition)
        
        var reachableTops = Set<GridPosition>()
        
        if let left = currentPosition.left(grid: grid) {
            if grid[left.j][left.i] == nextValue && !visited.contains(left) {
                for top in getTrailTops(reachableFrom: left, visited: visited) {
                    reachableTops.insert(top)
                }
            }
        }
        if let right = currentPosition.right(grid: grid) {
            if grid[right.j][right.i] == nextValue && !visited.contains(right) {
                for top in getTrailTops(reachableFrom: right, visited: visited) {
                    reachableTops.insert(top)
                }
            }
        }
        if let up = currentPosition.up(grid: grid) {
            if grid[up.j][up.i] == nextValue && !visited.contains(up) {
                for top in getTrailTops(reachableFrom: up, visited: visited) {
                    reachableTops.insert(top)
                }
            }
        }
        if let down = currentPosition.down(grid: grid) {
            if grid[down.j][down.i] == nextValue && !visited.contains(down) {
                for top in getTrailTops(reachableFrom: down, visited: visited) {
                    reachableTops.insert(top)
                }
            }
        }
        
        return reachableTops
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var score: Int = 0
        for i in 0..<grid[0].count {
            for j in 0..<grid.count {
                guard isTrailhead(grid[j][i]) else { continue }
                score += getTrailTops(
                    reachableFrom: GridPosition(i: i, j: j),
                    visited: []
                ).count
            }
        }
        return score
    }
    
    func getTrailRatings(reachableFrom currentPosition: GridPosition, visited: [GridPosition]) -> Int {
        let currentValue = grid[currentPosition.j][currentPosition.i]
        let nextValue = currentValue + 1
        if currentValue == 9 {
            return 1
        }
        
        var visited = visited
        visited.append(currentPosition)
        
        var totalRating: Int = 0
        
        if let left = currentPosition.left(grid: grid) {
            if grid[left.j][left.i] == nextValue && !visited.contains(left) {
                totalRating += getTrailRatings(reachableFrom: left, visited: visited)
            }
        }
        if let right = currentPosition.right(grid: grid) {
            if grid[right.j][right.i] == nextValue && !visited.contains(right) {
                totalRating += getTrailRatings(reachableFrom: right, visited: visited)
            }
        }
        if let up = currentPosition.up(grid: grid) {
            if grid[up.j][up.i] == nextValue && !visited.contains(up) {
                totalRating += getTrailRatings(reachableFrom: up, visited: visited)
            }
        }
        if let down = currentPosition.down(grid: grid) {
            if grid[down.j][down.i] == nextValue && !visited.contains(down) {
                totalRating += getTrailRatings(reachableFrom: down, visited: visited)
            }
        }
        
        return totalRating
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var score: Int = 0
        for i in 0..<grid[0].count {
            for j in 0..<grid.count {
                guard isTrailhead(grid[j][i]) else { continue }
                score += getTrailRatings(
                    reachableFrom: GridPosition(i: i, j: j),
                    visited: []
                )
            }
        }
        return score
    }
}
