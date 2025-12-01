//
//  Day01.swift
//  AdventOfCode
//
//  Created by Raúl Montón Pinillos on 1/12/25.
//

import Foundation

struct Day01: AdventDay {

    let rotations: [Rotation]

    enum Rotation: CustomStringConvertible {
        case left(Int)
        case right(Int)

        var description: String {
            switch self {
            case .left(let count):
                "L\(count)"
            case .right(let count):
                "R\(count)"
            }
        }
    }

    init(data: String) {
        var rotations = [Rotation]()
        for line in data.split(separator: "\n") {
            let number = Int(line.dropFirst())!
            switch line.first! {
            case "L":
                rotations.append(.left(number))
            case "R":
                rotations.append(.right(number))
            default:
                fatalError("Unexpected!")
            }
            
        }
        self.rotations = rotations
    }

    struct RotationResult: CustomStringConvertible {
        let position: Int
        let clicksThroughZero: Int

        var description: String {
            "\(position) (+\(clicksThroughZero))"
        }
    }

    func rotateLeft(from position: Int) -> RotationResult {
        let tmp = position - 1
        if tmp == -1 {
            return RotationResult(position: 99, clicksThroughZero: 0)
        } else if tmp == 0 {
            return RotationResult(position: 0, clicksThroughZero: 1)
        } else {
            return RotationResult(position: tmp, clicksThroughZero: 0)
        }
    }
    func rotateRight(from position: Int) -> RotationResult {
        let tmp = position + 1
        if tmp == 100 {
            return RotationResult(position: 0, clicksThroughZero: 1)
        } else {
            return RotationResult(position: tmp, clicksThroughZero: 0)
        }
    }

    func rotate(initialValue: Int, rotation: Rotation) -> RotationResult {
        var currentPosition = initialValue
        var clicksThroughZero = 0
        switch rotation {
        case .left(let count):
            for _ in 0..<count {
                let result = rotateLeft(from: currentPosition)
                currentPosition = result.position
                clicksThroughZero += result.clicksThroughZero
            }
        case .right(let count):
            for _ in 0..<count {
                let result = rotateRight(from: currentPosition)
                currentPosition = result.position
                clicksThroughZero += result.clicksThroughZero
            }
        }
        return RotationResult(
            position: currentPosition,
            clicksThroughZero: clicksThroughZero
        )
    }

    func part1() -> Any {
        var zeroCount = 0
        var currentValue = 50
        for rotation in rotations {
            currentValue = rotate(initialValue: currentValue, rotation: rotation).position
            // print("\(rotation) -> \(currentValue)")
            if currentValue == 0 {
                zeroCount += 1
            }
        }
        return zeroCount
    }

    func part2() -> Any {
        var zeroCount = 0
        var currentValue = 50
        for rotation in rotations {
            let result = rotate(initialValue: currentValue, rotation: rotation)
            currentValue = result.position
            // print("\(rotation) -> \(result)")
            zeroCount += result.clicksThroughZero
        }
        return zeroCount
    }
}
