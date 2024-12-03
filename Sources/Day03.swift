import Algorithms

struct Day03: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  
  func parseFrom(firstHalf: String, secondHalf: String) -> (Int, Int) {
    return (Int(firstHalf)!, Int(secondHalf)!)
  }
  
  enum Half {
    case firstHalf
    case secondHalf
  }
    
  func parseMul(mul: String.SubSequence) -> (Int, Int)? {
    var half = Half.firstHalf
    var firstHalf = ""
    var secondHalf = ""
    for character in mul {
      if Int(String(character)) != nil {
        switch half {
        case .firstHalf:
          firstHalf.append(character)
        case .secondHalf:
          secondHalf.append(character)
        }
      } else if character == "," {
        switch half {
        case .firstHalf:
          half = .secondHalf
          continue
        case .secondHalf:
          return nil
        }
      } else if character == ")" {
        switch half {
        case .firstHalf:
          return nil
        case .secondHalf:
          return parseFrom(
            firstHalf: firstHalf,
            secondHalf: secondHalf
          )
        }
      } else {
        return nil
      }
    }
    return nil
  }
  
  func parseConditionals(in mul: String.SubSequence) -> Bool? {
    guard mul.contains("do()") || mul.contains("don't()") else {
      return nil
    }
    var modMul = mul
    var result = true
    while modMul.count > 0 {
      if modMul.starts(with: "do()") {
        result = true
      } else if modMul.starts(with: "don't()") {
        result = false
      }
      modMul = modMul.dropFirst()
    }
    return result
  }

  // Splits input data into its component parts and convert from string.
  func parseEntities(useConditionals: Bool) -> [(Int, Int)] {
    var results = [(Int, Int)]()
    var allowMultiply: Bool = true
    for mul in data.split(separator: "mul(") {
      if let result = parseMul(mul: mul) {
        if allowMultiply || !useConditionals {
          results.append(result)
        }
      }
      if useConditionals {
        if let valuesInThisLine = parseConditionals(in: mul) {
          allowMultiply = valuesInThisLine
        }
      }
    }
    return results
  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    // Calculate the sum of the first set of input data
    parseEntities(useConditionals: false)
      .map {
        $0.0 * $0.1
      }
      .reduce(0, +)
  }

  // Replace this with your solution for the second part of the day's challenge.
  func part2() -> Any {
    parseEntities(useConditionals: true)
      .map {
        $0.0 * $0.1
      }
      .reduce(0, +)
  }
}
