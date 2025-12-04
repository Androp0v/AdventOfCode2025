//
//  Day04.swift
//  AdventOfCode
//
//  Created by Raúl Montón Pinillos on 4/12/25.
//

import Foundation
import Algorithms

struct Day04: AdventDay {

    let grid: [[Bool]]

    init(data: String) {
        var grid = [[Bool]]()
        for line in data.split(separator: "\n") {
            var gridLine = [Bool]()
            for character in Array(line) {
                gridLine.append(character == "@")
            }
            grid.append(gridLine)
        }
        self.grid = grid
    }

    enum Direction: CaseIterable {
        case left
        case right
        case top
        case bottom
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    struct Position {
        let x: Int
        let y: Int

        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }
    }

    func move(to direction: Direction, from position: Position?) -> Position? {
        guard let position else { return nil }
        switch direction {
        case .left:
            guard position.x != 0 else { return nil }
            return Position(position.x - 1, position.y)
        case .right:
            guard position.x != (grid[0].count - 1) else { return nil }
            return Position(position.x + 1, position.y)
        case .top:
            guard position.y != 0 else { return nil }
            return Position(position.x, position.y - 1)
        case .bottom:
            guard position.y != (grid.count - 1) else { return nil }
            return Position(position.x, position.y + 1)
        case .topLeft:
            return move(to: .top, from: move(to: .left, from: position))
        case .topRight:
            return move(to: .top, from: move(to: .right, from: position))
        case .bottomLeft:
            return move(to: .bottom, from: move(to: .left, from: position))
        case .bottomRight:
            return move(to: .bottom, from: move(to: .right, from: position))
        }
    }

    func part1() -> Any {
        var accessibleSpots = 0
        for i in 0..<grid.count {
            for j in 0..<grid[i].count {
                if grid[i][j] {
                    var rollsOfPaper = 0
                    for direction in Direction.allCases {
                        if let position = move(to: direction, from: Position(i, j)) {
                            if grid[position.x][position.y] {
                                rollsOfPaper += 1
                            }
                        }
                    }
                    if rollsOfPaper < 4 {
                        accessibleSpots += 1
                    }
                }
            }
        }
        return accessibleSpots
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var grid = grid
        var removedRolls = [Int]()
        repeat {
            var accessibleSpots = 0
            for i in 0..<grid.count {
                for j in 0..<grid[i].count {
                    if grid[i][j] {
                        var rollsOfPaper = 0
                        for direction in Direction.allCases {
                            if let position = move(to: direction, from: Position(i, j)) {
                                if grid[position.x][position.y] {
                                    rollsOfPaper += 1
                                }
                            }
                        }
                        if rollsOfPaper < 4 {
                            accessibleSpots += 1
                            grid[i][j] = false
                        }
                    }
                }
            }
            removedRolls.append(accessibleSpots)
        } while removedRolls.last != 0

        return removedRolls.reduce(0, +)
    }
}
