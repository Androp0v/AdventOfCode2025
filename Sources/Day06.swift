//
//  Day06.swift
//  AdventOfCode
//
//  Created by Raúl Montón Pinillos on 6/12/25.
//

import Algorithms

struct Day06: AdventDay {

    enum Operation {
        case sum
        case multiply
        
        init?(from character: Character) {
            switch character {
            case "+":
                self = .sum
            case "*":
                self = .multiply
            default:
                return nil
            }
        }
    }

    let numbers: [[Int]]
    let operations: [Operation]
    let rawMatrix: [[Character]]

    init(data: String) {

        var numbers = [[Int]]()
        var operations = [Operation]()
        var rawMatrix = [[Character]]()

        for line in data.split(separator: "\n") {
            let rawRow = Array(line)
            if rawRow.count != 0 {
                rawMatrix.append(rawRow)
            }
            if line.starts(with: "*") || line.starts(with: "+") {
                for operation in line.split(separator: " ") {
                    switch operation {
                    case "+":
                        operations.append(.sum)
                    case "*":
                        operations.append(.multiply)
                    default:
                        fatalError()
                    }
                }
            } else {
                var lineNumbers = [Int]()
                for number in line.split(separator: " ") {
                    lineNumbers.append(Int(number)!)
                }
                numbers.append(lineNumbers)
            }
        }
        self.numbers = numbers
        self.operations = operations
        self.rawMatrix = rawMatrix
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var totalResult = 0
        for j in 0..<numbers[0].count {
            let operation = operations[j]
            var partialResult = numbers[0][j]
            for i in 1..<numbers.count {
                switch operation {
                case .sum:
                    partialResult += numbers[i][j]
                case .multiply:
                    partialResult *= numbers[i][j]
                }
            }
            totalResult += partialResult
        }
        return totalResult
    }
    
    func performOperation(_ operation: Operation, on numbers: [Int]) -> Int {
        var partialResult = numbers[0]
        for i in 1..<numbers.count {
            switch operation {
            case .sum:
                partialResult += numbers[i]
            case .multiply:
                partialResult *= numbers[i]
            }
        }
        return partialResult
    }
    
    func part2() -> Any {
        var totalResult = 0
        var currentNumbers = [Int]()
        for j in (0..<rawMatrix[0].count).reversed() {
            let rawColumn = rawMatrix.map { $0[j] }
            var partialNumber = ""
            for character in rawColumn.dropLast() {
                if character != " " {
                    partialNumber.append(character)
                }
            }
            if partialNumber != "" {
                currentNumbers.append(Int(partialNumber)!)
            }
            
            if let operation = Operation(from: rawColumn.last!) {
                let partialResult = performOperation(operation, on: currentNumbers)
                totalResult += partialResult
                currentNumbers = []
            }
        }
        return totalResult
    }
}
