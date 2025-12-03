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
        let currentIndex: Int
        let maxEnabledBatteries: Int
    }

    func findHighestJoltage(
        in batteryBank: [Int],
        currentIndex: Int,
        maxEnabledBatteries: Int,
        cache: inout [CacheableInput: Int]
    ) -> Int {
        let input = CacheableInput(
            currentIndex: currentIndex,
            maxEnabledBatteries: maxEnabledBatteries
        )
        if let cachedResult = cache[input] {
            return cachedResult
        }

        var results = InlineArray<2, Int>(repeating: .zero)
        for enableCurrent in [true, false] {
            switch enableCurrent {
            case true:
                if maxEnabledBatteries == 1 {
                    results[0] = batteryBank[currentIndex]
                } else {
                    let subsequenceResult = findHighestJoltage(
                        in: batteryBank,
                        currentIndex: currentIndex + 1,
                        maxEnabledBatteries: maxEnabledBatteries - 1,
                        cache: &cache
                    )
                    results[0] = Int("\(batteryBank[currentIndex])\(subsequenceResult)")!
                }
            case false:
                let remainingBatteries = (batteryBank.count - 1) - currentIndex
                guard remainingBatteries >= maxEnabledBatteries else {
                    continue
                }
                results[1] = findHighestJoltage(
                    in: batteryBank,
                    currentIndex: currentIndex + 1,
                    maxEnabledBatteries: maxEnabledBatteries,
                    cache: &cache
                )
            }
        }
        let result = max(results[0], results[1])
        cache[input] = result
        return result
    }

    func part2() -> Any {
        var result = 0
        for battery in batteries {
            var cache = [CacheableInput: Int]()
            result += findHighestJoltage(
                in: battery,
                currentIndex: 0,
                maxEnabledBatteries: 12,
                cache: &cache
            )
        }
        return result
    }
}

