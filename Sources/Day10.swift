//
//  Day09.swift
//  AdventOfCode
//
//  Created by Raúl Montón Pinillos on 6/12/25.
//

import Algorithms
import simd

struct Day10: AdventDay {

    final class Machine: @unchecked Sendable, CustomStringConvertible {
        let desiredStatus: [Bool]
        let buttons: [[Int]]
        var currentStatus: [Bool]

        var isConfigured: Bool {
            currentStatus == desiredStatus
        }

        func press(buttonAt buttonIndex: Int) {
            let button = buttons[buttonIndex]
            for wire in button {
                currentStatus[wire].toggle()
            }
        }

        func reset() {
            currentStatus = [Bool](repeating: false, count: desiredStatus.count)
        }

        init(desiredStatus: [Bool], buttons: [[Int]]) {
            self.desiredStatus = desiredStatus
            self.buttons = buttons
            self.currentStatus = [Bool](repeating: false, count: desiredStatus.count)
        }

        var description: String {
            var finalString = ""
            let status = currentStatus.map({ $0 ? "#" : "." }).joined(separator: "")
            let desiredStatus = desiredStatus.map({ $0 ? "#" : "." }).joined(separator: "")
            finalString.append("[\(status)] | [\(desiredStatus)]")
            for button in buttons {
                finalString.append(" (\(button.map({ String($0) }).joined(separator: ",")))")
            }
            return finalString
        }
    }

    let machines: [Machine]

    init(data: String) {
        var machines = [Machine]()
        for line in data.split(separator: "\n") {
            let substrings = line.split(separator: " ")
            var desiredStatus = [Bool]()
            for character in Array(substrings[0]) {
                if character == "." {
                    desiredStatus.append(false)
                } else if character == "#" {
                    desiredStatus.append(true)
                }
            }

            var buttons = [[Int]]()
            for value in substrings.dropFirst() {
                guard value.contains("(") else { continue }
                let rawButton = value
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                var button = [Int]()
                for number in rawButton.split(separator: ",") {
                    button.append(Int(number)!)
                }
                buttons.append(button)
            }
            machines.append(Machine(desiredStatus: desiredStatus, buttons: buttons))
        }
        self.machines = machines
    }

    final class SequenceGenerator {
        let buttonCount: Int
        var depth = 0
        var values: [Int] = []

        init(buttonCount: Int) {
            self.buttonCount = buttonCount
        }

        func next() -> [Int] {
            guard !values.isEmpty else {
                values = [0]
                return values
            }
            if values[depth] < (buttonCount - 1) {
                values[depth] += 1
            } else {
                var tmpDepth = depth
                while true {
                    if tmpDepth == -1 {
                        depth += 1
                        values = [Int](repeating: 0, count: depth + 1)
                        break
                    }
                    if values[tmpDepth] < (buttonCount - 1) {
                        values[tmpDepth] += 1
                        break
                    } else {
                        values[tmpDepth] = 0
                        tmpDepth -= 1
                    }
                }
            }
            return values
        }
    }

    func getMinButtonPresses(for machine: Machine) -> Int {
        let sequenceGenerator = SequenceGenerator(
            buttonCount: machine.buttons.count
        )
        while true {
            machine.reset()
            let nextSequence = sequenceGenerator.next()
            for buttonIndex in nextSequence {
                machine.press(buttonAt: buttonIndex)
            }
            if machine.isConfigured {
                return sequenceGenerator.depth + 1
            }
        }
    }

    func part1() -> Any {
        var total = 0
        for (index, machine) in machines.enumerated() {
            let minPresses = getMinButtonPresses(for: machine)
            print("\(minPresses) presses for Machine \(index)")
            total += minPresses
        }
        return total
    }

    func part2() -> Any {
        return 0
    }
}
