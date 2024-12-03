import Algorithms

struct Day02: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // Splits input data into its component parts and convert from string.
  var reports: [[Int]] {
    data.split(separator: "\n").map {
      $0.split(separator: " ").compactMap { Int($0) }
    }
  }
  
  struct ResultCheck {
    let failureIndex: Int?
    let isSafe: Bool
  }
  
  func checkSafelyIncreasing(report: [Int]) -> ResultCheck {
    var previous: Int?
    for (index, level) in report.enumerated() {
      if let previous {
        guard level - previous >= 1 else {
          return ResultCheck(failureIndex: index, isSafe: false)
        }
        guard level - previous <= 3 else {
          return ResultCheck(failureIndex: index, isSafe: false)
        }
      }
      previous = level
    }
    return ResultCheck(failureIndex: nil, isSafe: true)
  }
  
  func checkSafelyDecreasing(report: [Int]) -> ResultCheck {
    var previous: Int?
    for (index, level) in report.enumerated() {
      if let previous {
        guard previous - level >= 1 else {
          return ResultCheck(failureIndex: index, isSafe: false)
        }
        guard previous - level <= 3 else {
          return ResultCheck(failureIndex: index, isSafe: false)
        }
      }
      previous = level
    }
    return ResultCheck(failureIndex: nil, isSafe: true)
  }
  
  func isSafelyIncreasing(report: [Int], dampened: Bool) -> Bool {
    if checkSafelyIncreasing(report: report).isSafe {
      return true
    }
    guard dampened else {
      return false
    }
    for index in report.indices {
      var newReport = report
      newReport.remove(at: index)
      if checkSafelyIncreasing(report: newReport).isSafe {
        return true
      }
    }
    return false
  }
  
  func isSafelyDecreasing(report: [Int], dampened: Bool) -> Bool {
    if checkSafelyDecreasing(report: report).isSafe {
      return true
    }
    guard dampened else {
      return false
    }
    for index in report.indices {
      var newReport = report
      newReport.remove(at: index)
      if checkSafelyDecreasing(report: newReport).isSafe {
        return true
      }
    }
    return false
  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    var safeReportCount = 0
    for report in reports {
      if isSafelyIncreasing(report: report, dampened: false) {
        safeReportCount += 1
      } else if isSafelyDecreasing(report: report, dampened: false) {
        safeReportCount += 1
      }
    }
    return safeReportCount
  }

  // Replace this with your solution for the second part of the day's challenge.
  func part2() -> Any {
    var safeReportCount = 0
    for report in reports {
      if isSafelyIncreasing(report: report, dampened: true) {
        safeReportCount += 1
      } else if isSafelyDecreasing(report: report, dampened: true) {
        safeReportCount += 1
      }
    }
    return safeReportCount
  }
}
