import Algorithms

struct Day19: AdventDay {
    
    let availablePatterns: Set<String>
    let finalPatterns: [String]
    
    init(data: String) {
        let splitData = data.split(separator: "\n")
        
        var availablePatterns = Set<String>()
        for pattern in splitData[0].split(separator: ",") {
            availablePatterns.insert(pattern.trimmingCharacters(in: .whitespaces))
        }
        
        var finalPatterns = [String]()
        for pattern in splitData.dropFirst() {
            finalPatterns.append(String(pattern))
        }
        
        self.availablePatterns = availablePatterns
        self.finalPatterns = finalPatterns
    }
    
    func canBuildTowel(pattern: String) -> Bool {
        // print("Can build towel for \(pattern)")
        for n in 0...pattern.count {
            let partialMatch = String(pattern.prefix(n))
            // print("  Looking for matches of length \(n): \(partialMatch)")
            if availablePatterns.contains(partialMatch) {
                // print("  \(partialMatch) available")
                if n == pattern.count {
                    return true
                } else {
                    if canBuildTowel(pattern: String(pattern.dropFirst(n))) {
                        return true
                    } else {
                        continue
                    }
                }
            }
        }
        
        return false
    }
    
    func findAllPossible(pattern: String, memo: inout [String: Int]) -> Int {
        var result: Int = 0
        // print("Can build towel for \(pattern)")
        for n in 1...pattern.count {
            let partialMatch = String(pattern.prefix(n))
            // print("  Looking for matches of length \(n): \(partialMatch)")
            if availablePatterns.contains(partialMatch) {
                if n == pattern.count {
                    // print("  \(partialMatch) available ✅")
                    return result + 1
                } else {
                    // print("  \(partialMatch) available, looking for the rest")
                    let subpattern = String(pattern.dropFirst(n))
                    let subpatternResult = if let existingValue = memo[subpattern] {
                        existingValue
                    } else {
                        findAllPossible(
                            pattern: subpattern,
                            memo: &memo
                        )
                    }
                    memo[subpattern] = subpatternResult
                    result += subpatternResult
                }
            }
        }
        return result
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var possible: Int = 0
        for finalPattern in finalPatterns {
            if canBuildTowel(pattern: finalPattern) {
                possible += 1
            }
        }
        return possible
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var allPossible: Int = 0
        var memo = [String: Int]()
        for finalPattern in finalPatterns {
            allPossible += findAllPossible(pattern: finalPattern, memo: &memo)
        }
        return allPossible
    }
}
