//
//  Day09.swift
//  AdventOfCode
//
//  Created by Raúl Montón Pinillos on 6/12/25.
//

import Algorithms
import simd

struct Day09: AdventDay {

    let tilePositions: [SIMD2<Int>]

    init(data: String) {
        var tilePositions = [SIMD2<Int>]()
        for line in data.split(separator: "\n") {
            let coordinates = line.split(separator: ",").map { Int($0)! }
            tilePositions.append(SIMD2<Int>(coordinates[0], coordinates[1]))
        }
        self.tilePositions = tilePositions
    }

    func getArea(tileA: SIMD2<Int>, tileB: SIMD2<Int>) -> Int {
        let width = abs(tileA.x - tileB.x) + 1
        let height = abs(tileA.y - tileB.y) + 1
        return width * height
    }

    func part1() -> Any {
        var maxArea: Int = 0
        for i in 0..<tilePositions.count {
            for j in i..<tilePositions.count {
                guard i != j else { continue }
                let area = getArea(
                    tileA: tilePositions[i],
                    tileB: tilePositions[j]
                )
                if area > maxArea {
                    maxArea = area
                }
            }
        }
        return maxArea
    }

    func paintGreenTilesBetween(tileA: SIMD2<Int>, tileB: SIMD2<Int>, in matrix: inout [[Character]]) {
        if matrix[tileB.y] == matrix[tileA.y] {
            // Same row
            if tileB.x < tileA.x {
                for k in (tileB.x + 1)..<tileA.x {
                    matrix[tileA.y][k] = "#"
                }
            } else if tileB.x > tileA.x {
                for k in (tileA.x + 1)..<tileB.x {
                    matrix[tileA.y][k] = "#"
                }
            }
        } else {
            // Same column
            if tileB.y < tileA.y {
                for k in (tileB.y + 1)..<tileA.y {
                    matrix[k][tileA.x] = "#"
                }
            } else if tileB.y > tileA.y {
                for k in (tileA.y + 1)..<tileB.y {
                    matrix[k][tileA.x] = "#"
                }
            }
        }
    }

    enum Direction: CaseIterable {
        case left
        case right
        case up
        case down
    }

    func isInsidePolygon(_ tile: SIMD2<Int>, matrix: inout [[Character]]) -> Bool {
        guard matrix[tile.y][tile.x] == "." else {
            return true
        }
        for direction in Direction.allCases {
            var crossings = 0
            var current: Character = "."
            switch direction {
            case .left:
                var k = tile.x - 1
                while true {
                    guard k >= 0 else { break }
                    let newCurrent = matrix[tile.y][k]
                    if newCurrent != current {
                        crossings += 1
                        current = newCurrent
                    }
                    k -= 1
                }
            case .right:
                var k = tile.x + 1
                while true {
                    guard k < matrix[tile.y].count else { break }
                    let newCurrent = matrix[tile.y][k]
                    if newCurrent != current {
                        crossings += 1
                        current = newCurrent
                    }
                    k += 1
                }
            case .up:
                var k = tile.y - 1
                while true {
                    guard k >= 0 else { break }
                    let newCurrent = matrix[k][tile.x]
                    if newCurrent != current {
                        crossings += 1
                        current = newCurrent
                    }
                    k -= 1
                }
            case .down:
                var k = tile.y + 1
                while true {
                    guard k < matrix.count else { break }
                    let newCurrent = matrix[k][tile.x]
                    if newCurrent != current {
                        crossings += 1
                        current = newCurrent
                    }
                    k += 1
                }
            }
            if crossings == 0 {
                guard current == "#" else {
                    return false
                }
            }
            if (crossings/2) % 2 == 0 {
                return false
            }
        }
        return true
    }

    func paintGreenTilesInsidePolygon(matrix: inout [[Character]]) {
        for y in 0..<matrix.count {
            for x in 0..<matrix[y].count {
                if isInsidePolygon(SIMD2<Int>(x, y), matrix: &matrix) {
                    matrix[y][x] = "#"
                }
                /*
                printFloor(matrix)
                print("\n")
                 */
            }
        }
    }

    func buildFloor() -> [[Character]] {
        var tilePositions = tilePositions
        let minX = tilePositions.map(\.x).min()! - 1
        let minY = tilePositions.map(\.y).min()! - 1
        for i in 0..<tilePositions.count {
            tilePositions[i] &-= SIMD2<Int>(minX, minY)
        }
        let width = tilePositions.map(\.x).max()! + 2
        let height = tilePositions.map(\.y).max()! + 2

        var matrix: [[Character]] = [[Character]](repeating: [Character](repeating: ".", count: width), count: height)
        matrix[tilePositions[0].y][tilePositions[0].x] = "#"
        for i in 1..<tilePositions.count {
            let currentTile = tilePositions[i]
            let previousTile = tilePositions[i - 1]
            matrix[currentTile.y][currentTile.x] = "#"
            paintGreenTilesBetween(
                tileA: currentTile,
                tileB: previousTile,
                in: &matrix
            )
        }
        paintGreenTilesBetween(
            tileA: tilePositions.first!,
            tileB: tilePositions.last!,
            in: &matrix
        )

        paintGreenTilesInsidePolygon(matrix: &matrix)

        return matrix
    }

    func printFloor(_ floor: [[Character]]) {
        for row in floor {
            for character in row {
                print(character, terminator: "")
            }
            print("\n", terminator: "")
        }
    }

    func allTilesInsidePolygon(
        tileA: SIMD2<Int>,
        tileB: SIMD2<Int>,
        floor: inout [[Character]]
    ) -> Bool {
        let minX = min(tileA.x, tileB.x)
        let minY = min(tileA.y, tileB.y)
        let maxX = max(tileA.x, tileB.x)
        let maxY = max(tileA.y, tileB.y)

        for y in minY...maxY {
            for x in minX...maxX {
                guard isInsidePolygon(SIMD2(x, y), matrix: &floor) else {
                    return false
                }
            }
        }

        return true
    }

    func part2() -> Any {
        var floor = buildFloor()
        // printFloor(floor)
        var maxArea: Int = 0
        for i in 0..<tilePositions.count {
            for j in i..<tilePositions.count {
                guard i != j else { continue }
                let area = getArea(
                    tileA: tilePositions[i],
                    tileB: tilePositions[j]
                )
                if area > maxArea {
                    guard allTilesInsidePolygon(
                        tileA: tilePositions[i],
                        tileB: tilePositions[j],
                        floor: &floor
                    ) else {
                        continue
                    }
                    maxArea = area
                }
            }
        }
        return maxArea
    }
}
