//
//  Day03.swift
//  AdventOfCode
//
//  Created by Raúl Montón Pinillos on 3/12/25.
//

import Algorithms

struct Day03: AdventDay {

    let batteries: [[Int]]

    init(data: String) {
        var batteries = [[Int]]()
        for line in data.split(separator: "\n") {
            let characters = Array(line)
            batteries.append(characters.map { Int(String($0))! })
        }
        self.batteries = batteries
    }

    func findHighestJoltage(in battery: [Int]) -> Int {
        var maxIndexA: Int = 0
        for i in battery.indices.dropLast() {
            if battery[i] > battery[maxIndexA] {
                maxIndexA = i
            }
        }

        var maxIndexB: Int = maxIndexA + 1
        for i in (maxIndexA + 1)..<battery.count {
            if battery[i] > battery[maxIndexB] {
                maxIndexB = i
            }
        }

        return battery[maxIndexA] * 10 + battery[maxIndexB]
    }

    func part1() -> Any {
        return batteries
            .map { findHighestJoltage(in: $0) }
            .reduce(0, +)
    }

    struct CacheableInput: Hashable {
        let batteryBank: [Int]
        let maxEnabledBatteries: Int
    }

    func findHighestJoltage(
        in batteryBank: [Int],
        maxEnabledBatteries: Int,
        cache: inout [CacheableInput: Int]
    ) -> Int {
        let input = CacheableInput(batteryBank: batteryBank, maxEnabledBatteries: maxEnabledBatteries)
        if let cachedResult = cache[input] {
            return cachedResult
        }

        var results = [Int]()
        for enableCurrent in [true, false] {
            switch enableCurrent {
            case true:
                if maxEnabledBatteries == 1 {
                    results.append(batteryBank.first!)
                } else {
                    let subsequenceResult = findHighestJoltage(
                        in: Array(batteryBank.dropFirst()),
                        maxEnabledBatteries: maxEnabledBatteries - 1,
                        cache: &cache
                    )
                    results.append(Int("\(batteryBank.first!)\(subsequenceResult)")!)
                }
            case false:
                guard batteryBank.dropFirst().count >= maxEnabledBatteries else {
                    continue
                }
                results.append(findHighestJoltage(
                    in: Array(batteryBank.dropFirst()),
                    maxEnabledBatteries: maxEnabledBatteries,
                    cache: &cache
                ))
            }
        }
        let result = results.max()!
        cache[input] = result
        return result
    }

    func part2() -> Any {
        var result = 0
        for battery in batteries {
            var cache = [CacheableInput: Int]()
            result += findHighestJoltage(
                in: battery,
                maxEnabledBatteries: 12,
                cache: &cache
            )
        }
        return result
    }
}

