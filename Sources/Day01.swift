import Algorithms

struct Day01: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // Splits input data into its component parts and convert from string.
  var entities: [[Int]] {
    var tempList: [[Int]] = [[], []]
    data.split(separator: "\n").forEach { line in
      let values = line.split(separator: "   ")
      tempList[0].append(Int(values[0])!)
      tempList[1].append(Int(values[1])!)
    }
    return tempList
  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let listA = entities[0].sorted()
    let listB = entities[1].sorted()
    var distance: Int = 0
    for (a, b) in zip(listA, listB) {
      distance += abs(a - b)
    }
    print(distance)
    return distance
  }

  // Replace this with your solution for the second part of the day's challenge.
  func part2() -> Any {
    let listA = entities[0]
    let listB = entities[1]
    var countInB = [Int: Int]()
    for b in listB {
      if let existing = countInB[b] {
        countInB[b] = existing + 1
      } else {
        countInB[b] = 1
      }
    }
    var similarity = 0
    for a in listA {
      if let count = countInB[a] {
        similarity += a * count
      }
    }
    return similarity
  }
}
