import Algorithms

struct Day05: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    let data: String
    
    struct OrderingRule {
        let first: Int
        let second: Int
    }
    let orderingRules: [OrderingRule]
    let updates: [[Int]]

    init(data: String) {
        self.data = data
        var orderingRules = [OrderingRule]()
        var updates = [[Int]]()
        for line in data.split(separator: "\n") {
            if line.contains("|") {
                let ruleValues = line.split(separator: "|")
                orderingRules.append(OrderingRule(
                    first: Int(ruleValues[0])!,
                    second: Int(ruleValues[1])!
                ))
            } else if line.contains(",") {
                let updateValues = line.split(separator: ",").map({ Int($0)! })
                updates.append(updateValues)
            }
        }
        self.orderingRules = orderingRules
        self.updates = updates
    }
    
    func isOrdered(_ update: [Int]) -> Bool {
        for rule in orderingRules {
            guard let firstIndex = update.firstIndex(of: rule.first) else {
                continue
            }
            guard let secondIndex = update.firstIndex(of: rule.second) else {
                continue
            }
            if firstIndex > secondIndex {
                return false
            }
        }
        return true
    }
    
    func getMiddleValue(_ update: [Int]) -> Int {
        guard update.count % 2 != 0 else {
            fatalError("Even input to getMiddleValue!")
        }
        return update[Int(Double(update.count) / 2.0)]
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var total: Int = 0
        for update in updates {
            if isOrdered(update) {
                total += getMiddleValue(update)
            }
        }
        return total
    }
    
    func reorderUpdate(_ update: [Int]) -> [Int] {
        var modifiedUpdate = update
        for rule in orderingRules {
            guard let firstIndex = modifiedUpdate.firstIndex(of: rule.first) else {
                continue
            }
            guard let secondIndex = modifiedUpdate.firstIndex(of: rule.second) else {
                continue
            }
            if firstIndex > secondIndex {
                let removed = modifiedUpdate.remove(at: firstIndex)
                modifiedUpdate.insert(removed, at: secondIndex)
                return reorderUpdate(modifiedUpdate)
            }
        }
        return modifiedUpdate
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        let incorrectUpdates = updates.filter { !isOrdered($0) }
        let reorderedUpdates = incorrectUpdates.map( { reorderUpdate($0) } )
        var total: Int = 0
        for update in reorderedUpdates {
            total += getMiddleValue(update)
        }
        return total
    }
}
