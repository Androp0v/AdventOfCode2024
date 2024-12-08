import Algorithms
import simd

struct Day08: AdventDay {
    
    struct GridPosition: Equatable, Hashable {
        let i: Int
        let j: Int
    }
    
    final class SingleFrequencyData: @unchecked Sendable {
        let frequency: Character
        var antennaPositions: [GridPosition]
        
        init(frequency: Character, antennaPositions: [GridPosition]) {
            self.frequency = frequency
            self.antennaPositions = antennaPositions
        }
    }
    
    let grid: [[Character]]
    let frequencyData: [SingleFrequencyData]
    
    init(data: String) {
        var grid = [[Character]]()
        var frequencyData = [Character: SingleFrequencyData]()
        for (j, line) in data.split(separator: "\n").enumerated() {
            grid.append(line.map { $0 })
            for (i, character) in line.enumerated() {
                guard character != "." else { continue }
                let antennaPosition = GridPosition(
                    i: i,
                    j: j
                )
                if let existingData = frequencyData[character] {
                    existingData.antennaPositions.append(antennaPosition)
                } else {
                    frequencyData[character] = SingleFrequencyData(
                        frequency: character,
                        antennaPositions: [antennaPosition]
                    )
                }
            }
        }
        self.grid = grid
        self.frequencyData = Array(frequencyData.values)
    }
    
    func chebyshevDistance(from positionA: GridPosition, to positionB: GridPosition) -> Int {
        return max(abs(positionA.i - positionB.i), abs(positionA.j - positionB.j))
    }
    
    func direction(from pointA: GridPosition, to pointB: GridPosition) -> SIMD2<Double> {
        let dir = simd_double2(Double(pointA.i - pointB.i), Double(pointA.j - pointB.j))
        return normalize(dir)
    }
    
    func isInLine(point: GridPosition, antennaA: GridPosition, antennaB: GridPosition) -> Bool {
        guard point != antennaA && point != antennaB else {
            return true
        }
        let pointToADir = direction(from: point, to: antennaA)
        let pointToBDir = direction(from: point, to: antennaB)
        let dotProduct = dot(pointToADir, pointToBDir)
        return dotProduct >= 0.9999999 || dotProduct <= -0.9999999
    }
    
    func createInlinePoints(antennaA: GridPosition, antennaB: GridPosition) -> [GridPosition] {
        let ab = (antennaB.i - antennaA.i, antennaB.j - antennaA.j)
        let ba = (antennaA.i - antennaB.i, antennaA.j - antennaB.j)
        
        var inlinePoints = [GridPosition]()
        var currentPoint = antennaA
        while true {
            guard currentPoint.i < grid[0].count else { break }
            guard currentPoint.i >= 0 else { break }
            guard currentPoint.j < grid.count else { break }
            guard currentPoint.j >= 0 else { break }
            inlinePoints.append(currentPoint)
            currentPoint = GridPosition(
                i: currentPoint.i + ab.0,
                j: currentPoint.j + ab.1
            )
        }
        
        currentPoint = antennaB
        while true {
            guard currentPoint.i < grid[0].count else { break }
            guard currentPoint.i >= 0 else { break }
            guard currentPoint.j < grid.count else { break }
            guard currentPoint.j >= 0 else { break }
            inlinePoints.append(currentPoint)
            currentPoint = GridPosition(
                i: currentPoint.i + ba.0,
                j: currentPoint.j + ba.1
            )
        }
        
        return inlinePoints
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var antinodes = Set<GridPosition>()
        for singleFrequency in frequencyData {
            for i in 0..<grid[0].count {
                for j in 0..<grid.count {
                    let antennas = singleFrequency.antennaPositions
                    let gridPosition = GridPosition(i: i, j: j)
                    guard !antennas.contains(where: { $0 == gridPosition }) else {
                        continue
                    }
                    for k in 0..<antennas.count {
                        for l in (k + 1)..<antennas.count {
                            let antennaA = antennas[k]
                            let antennaB = antennas[l]
                            guard isInLine(point: gridPosition, antennaA: antennaA, antennaB: antennaB) else {
                                continue
                            }
                            let distanceA = chebyshevDistance(from: gridPosition, to: antennaA)
                            let distanceB = chebyshevDistance(from: gridPosition, to: antennaB)
                            if (distanceA / distanceB) == 2 || (distanceB / distanceA) == 2 {
                                antinodes.insert(gridPosition)
                            }
                        }
                    }
                }
            }
        }
        return antinodes.count
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var antinodes = Set<GridPosition>()
        for singleFrequency in frequencyData {
            let antennas = singleFrequency.antennaPositions
            for k in 0..<antennas.count {
                for l in (k + 1)..<antennas.count {
                    let antennaA = antennas[k]
                    let antennaB = antennas[l]
                    let inlinePoints = createInlinePoints(antennaA: antennaA, antennaB: antennaB)
                    for antinode in inlinePoints {
                        if !antinodes.contains(antinode) {
                            antinodes.insert(antinode)
                        }
                    }
                }
            }
        }
        return antinodes.count
    }
}
