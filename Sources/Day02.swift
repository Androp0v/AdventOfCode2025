//
//  Day02.swift
//  AdventOfCode
//
//  Created by Raúl Montón Pinillos on 2/12/25.
//

import Algorithms

struct Day02: AdventDay {

    let idRanges: [ClosedRange<Int>]

    init(data: String) {
        let data = data.replacingOccurrences(of: "\n", with: "")
        var idRanges = [ClosedRange<Int>]()
        for rawRange in data.split(separator: ",") {
            let range = rawRange.split(separator: "-")
            let low = Int(range[0])!
            let high = Int(range[1])!
            idRanges.append(ClosedRange(uncheckedBounds: (low, high)))
        }
        self.idRanges = idRanges
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var invalidIDs = [Int]()
        for idRange in idRanges {
            for id in idRange {
                let characters = Array(String("\(id)"))
                let count = characters.count
                guard count % 2 == 0 else {
                    continue
                }
                let leftHalf = characters[0..<(count/2)]
                let rightHalf = characters[(count/2)..<count]
                if leftHalf == rightHalf {
                    invalidIDs.append(id)
                }
            }
        }
        return invalidIDs.reduce(0, +)
    }

    func hasRepeatedPattern(in id: String) -> Bool {
        let characters = Array(String("\(id)"))
        for patternLength in 1...5 {
            let count = characters.count
            guard count % patternLength == 0, count > patternLength else {
                continue
            }
            let subpatternCount = count / patternLength

            var subpatterns = [ArraySlice<Character>]()
            for i in 0..<subpatternCount {
                let start = i * patternLength
                let end = start + patternLength
                subpatterns.append(characters[start..<end])
            }

            let allEqual = subpatterns.allSatisfy { $0 == subpatterns.first }
            if allEqual {
                return true
            }
        }
        return false
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var invalidIDs = [Int]()
        for idRange in idRanges {
            for id in idRange {
                if hasRepeatedPattern(in: String("\(id)")) {
                    invalidIDs.append(id)
                }
            }
        }
        return invalidIDs.reduce(0, +)
    }
}
