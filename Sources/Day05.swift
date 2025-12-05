//
//  Day04.swift
//  AdventOfCode
//
//  Created by Raúl Montón Pinillos on 5/12/25.
//

import Algorithms

struct Day05: AdventDay {

    let ranges: [ClosedRange<Int>]
    let ingredients: [Int]

    init(data: String) {
        var ranges = [ClosedRange<Int>]()
        var ingredients = [Int]()
        for line in data.split(separator: "\n") {
            if line.contains("-") {
                let rawLineComponents = line.split(separator: "-")
                let low = Int(rawLineComponents[0])!
                let high = Int(rawLineComponents[1])!
                ranges.append(ClosedRange(uncheckedBounds: (low, high)))
            } else if line.isEmpty {
                continue
            } else {
                ingredients.append(Int(line)!)
            }
        }
        self.ranges = ranges
        self.ingredients = ingredients
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var freshIngredientCount = 0
        for ingredient in ingredients {
            for range in ranges {
                if range.contains(ingredient) {
                    freshIngredientCount += 1
                    break
                }
            }
        }
        return freshIngredientCount
    }

    enum OverlapCheckResult {
        case noOverlap
        case overlap(overlappingRanges: [ClosedRange<Int>], newRange: ClosedRange<Int>)
    }

    func combineRanges(_ a: ClosedRange<Int>, _ b: ClosedRange<Int>) -> ClosedRange<Int> {
        let low = min(a.first!, b.first!)
        let high = max(a.last!, b.last!)
        return ClosedRange(uncheckedBounds: (low, high))
    }

    func nonOverlappingRanges(from initialRanges: Set<ClosedRange<Int>>) -> Set<ClosedRange<Int>> {
        var nonOverlappingRanges = Set<ClosedRange<Int>>()
        for range in initialRanges {
            // print(("Checking range \(range)"))
            var combinedRange = range
            var existingRangesToRemove = [ClosedRange<Int>]()

            for existingRange in nonOverlappingRanges {
                if existingRange.contains(combinedRange.first!)
                    || existingRange.contains(combinedRange.last!)
                    || combinedRange.contains(existingRange.first!)
                    || combinedRange.contains(existingRange.last!)
                {
                    // print("  Range \(combinedRange) and range \(existingRange) overlap")
                    combinedRange = combineRanges(combinedRange, existingRange)
                    // print("  Combined range \(combinedRange)")
                    existingRangesToRemove.append(existingRange)
                }
            }
            if !existingRangesToRemove.isEmpty {
                for range in existingRangesToRemove {
                    // print("  Removing range \(range)")
                    nonOverlappingRanges.remove(range)
                }
            } else {
                // print("  Range \(combinedRange) had no overlap")
            }
            // print("  Saving range \(combinedRange)")
            nonOverlappingRanges.insert(combinedRange)
        }
        return nonOverlappingRanges
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var total = 0
        for range in nonOverlappingRanges(from: Set(ranges)) {
            total += range.count
        }
        return total
    }
}
