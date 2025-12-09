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

    func paintGreenTilesBetween(tileA: SIMD2<Int>, tileB: SIMD2<Int>, in floor: Floor) {
        if tileB.y == tileA.y {
            // Same row
            if tileB.x < tileA.x {
                for k in (tileB.x + 1)..<tileA.x {
                    floor.paintedTiles.insert(SIMD2<Int>(k, tileA.y))
                }
            } else if tileB.x > tileA.x {
                for k in (tileA.x + 1)..<tileB.x {
                    floor.paintedTiles.insert(SIMD2<Int>(k, tileA.y))
                }
            }
        } else {
            // Same column
            if tileB.y < tileA.y {
                for k in (tileB.y + 1)..<tileA.y {
                    floor.paintedTiles.insert(SIMD2<Int>(tileA.x, k))
                }
            } else if tileB.y > tileA.y {
                for k in (tileA.y + 1)..<tileB.y {
                    floor.paintedTiles.insert(SIMD2<Int>(tileA.x, k))
                }
            }
        }
    }

    final class Floor {
        let width: Int
        let height: Int
        var paintedTiles: Set<SIMD2<Int>>

        init(width: Int, height: Int, paintedTiles: Set<SIMD2<Int>>) {
            self.width = width
            self.height = height
            self.paintedTiles = paintedTiles
        }
    }

    func buildFloor() -> Floor {
        var tilePositions = tilePositions
        let minX = tilePositions.map(\.x).min()! - 1
        let minY = tilePositions.map(\.y).min()! - 1
        for i in 0..<tilePositions.count {
            tilePositions[i] &-= SIMD2<Int>(minX, minY)
        }
        let width = tilePositions.map(\.x).max()! + 2
        let height = tilePositions.map(\.y).max()! + 2

        var paintedTiles = Set<SIMD2<Int>>()
        let floor = Floor(
            width: width,
            height: height,
            paintedTiles: paintedTiles
        )

        floor.paintedTiles.insert(tilePositions.first!)
        paintedTiles.insert(SIMD2<Int>(tilePositions[0].x, tilePositions[0].y))
        for i in 1..<tilePositions.count {
            let currentTile = tilePositions[i]
            let previousTile = tilePositions[i - 1]
            floor.paintedTiles.insert(currentTile)
            paintGreenTilesBetween(
                tileA: currentTile,
                tileB: previousTile,
                in: floor
            )
        }
        paintGreenTilesBetween(
            tileA: tilePositions.first!,
            tileB: tilePositions.last!,
            in: floor
        )

        // paintGreenTilesInsidePolygon(matrix: &matrix)

        return floor
    }

    func printFloor(_ floor: Floor) {
        for y in 0..<floor.height {
            for x in 0..<floor.width {
                let tile = SIMD2<Int>(x, y)
                if floor.paintedTiles.contains(tile) {
                    print("#", terminator: "")
                } else {
                    print(".", terminator: "")
                }
            }
            print("\n", terminator: "")
        }
    }

    enum Direction: CaseIterable {
        case up
        case down
        case left
        case right
    }

    func flood(from tile: SIMD2<Int>, in floor: Floor) {
        var activeTiles = Set<SIMD2<Int>>()
        activeTiles.insert(tile)

        while !activeTiles.isEmpty {
            var newActiveTiles = Set<SIMD2<Int>>()
            for tile in activeTiles {
                guard !floor.paintedTiles.contains(tile) else {
                    continue
                }
                floor.paintedTiles.insert(tile)

                for direction in Direction.allCases {
                    let nextTile = switch direction {
                    case .up:
                        SIMD2<Int>(tile.x, tile.y - 1)
                    case .down:
                        SIMD2<Int>(tile.x, tile.y + 1)
                    case .left:
                        SIMD2<Int>(tile.x - 1, tile.y)
                    case .right:
                        SIMD2<Int>(tile.x + 1, tile.y)
                    }
                    newActiveTiles.insert(nextTile)
                }
            }
            activeTiles = newActiveTiles
        }
    }

    func findSurelyInsideTile(in floor: Floor) -> SIMD2<Int> {
        var surelyInside: SIMD2<Int>?
        var minY = Int.max
        for tile in floor.paintedTiles {
            if tile.y < minY {
                let downwardTile = SIMD2(tile.x, tile.y + 1)
                guard !floor.paintedTiles.contains(downwardTile) else {
                    continue
                }
                minY = tile.y
                surelyInside = SIMD2(tile.x, tile.y + 1)
            }
        }
        guard let surelyInside else {
            fatalError()
        }
        print("Tile \(surelyInside) must be inside")
        return surelyInside
    }

    func findBiggestRectangles(tilePositions: [SIMD2<Int>]) -> Heap<Rectangle> {
        var rectangles = Heap<Rectangle>()
        for i in 0..<tilePositions.count {
            for j in i..<tilePositions.count {
                guard i != j else { continue }
                let tileA = tilePositions[i]
                let tileB = tilePositions[j]
                let area = getArea(
                    tileA: tileA,
                    tileB: tileB
                )
                rectangles.insert(Rectangle(
                    tileA: tileA,
                    tileB: tileB,
                    area: area
                ))
            }
        }
        return rectangles
    }

    struct Rectangle: Comparable {
        let tileA: SIMD2<Int>
        let tileB: SIMD2<Int>
        let area: Int

        static func < (lhs: Day09.Rectangle, rhs: Day09.Rectangle) -> Bool {
            lhs.area < rhs.area
        }
    }

    func allTilesInsidePolygon(
        tileA: SIMD2<Int>,
        tileB: SIMD2<Int>,
        floor: Floor
    ) -> Bool {
        let minX = min(tileA.x, tileB.x)
        let minY = min(tileA.y, tileB.y)
        let maxX = max(tileA.x, tileB.x)
        let maxY = max(tileA.y, tileB.y)

        for y in minY...maxY {
            for x in minX...maxX {
                let tile = SIMD2<Int>(x, y)
                guard floor.paintedTiles.contains(tile) else {
                    return false
                }
            }
        }
        return true
    }


    func part2() -> Any {
        let floor = buildFloor()

        // printFloor(floor)

        let surelyInside = findSurelyInsideTile(in: floor)

        flood(from: surelyInside, in: floor)

        print("Flood complete, \(floor.paintedTiles.count) tiles painted")

        // printFloor(floor)

        var rectangles = findBiggestRectangles(
            tilePositions: tilePositions
        )

        var k = 1
        let originalRectangleCount = rectangles.count
        while true {
            let rectangle = rectangles.popMax()!
            print("Trying rectangle \(k) of \(originalRectangleCount): \(rectangle)")
            if allTilesInsidePolygon(
                tileA: rectangle.tileA,
                tileB: rectangle.tileB,
                floor: floor,
            ) {
                return rectangle.area
            }
            k += 1
        }

        fatalError("Unreachable")
    }
}
