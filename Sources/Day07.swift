//
//  Day07.swift
//  AdventOfCode
//
//  Created by Raúl Montón Pinillos on 6/12/25.
//

import Algorithms

struct Day07: AdventDay {

    struct Manifold: CustomStringConvertible {
        enum PositionType: Character, RawRepresentable {
            case empty = "."
            case startPosition = "S"
            case splitter = "^"
            case beam = "|"

            init(_ character: Character) {
                switch character {
                case ".":
                    self = .empty
                case "^":
                    self = .splitter
                case "S":
                    self = .startPosition
                case "|":
                    self = .beam
                default:
                    fatalError()
                }
            }
        }
        var contents = [[PositionType]]()

        var description: String {
            var result = ""
            for line in self.contents {
                var lineResult = ""
                for position in line {
                    lineResult.append(position.rawValue)
                }
                result.append("\(lineResult)\n")
            }
            return result
        }
    }

    let manifold: Manifold

    init(data: String) {
        var manifold = Manifold()
        for line in data.split(separator: "\n") {
            var manifoldLine = [Manifold.PositionType]()
            for character in line {
                manifoldLine.append(Manifold.PositionType(character))
            }
            manifold.contents.append(manifoldLine)
        }
        self.manifold = manifold
    }
            
    func part1() -> Any {
        var totalSplits = 0
        var manifold = manifold

        for i in 0..<manifold.contents.count {
            // print(manifold)
            for j in 0..<manifold.contents[i].count {
                switch manifold.contents[i][j] {
                case .empty:
                    guard i != 0 else { continue }
                    if manifold.contents[i-1][j] == .beam {
                        manifold.contents[i][j] = .beam
                    }
                case .splitter:
                    guard manifold.contents[i-1][j] == .beam else {
                        continue
                    }
                    let left = manifold.contents[i][j-1]
                    let right = manifold.contents[i][j+1]
                    totalSplits += 1
                    if left == .empty {
                        manifold.contents[i][j-1] = .beam
                    }
                    if right == .empty {
                        manifold.contents[i][j+1] = .beam
                    }
                case .startPosition:
                    manifold.contents[i+1][j] = .beam
                case .beam:
                    break
                }
            }
            // print(totalSplits)
        }
        return totalSplits
    }

    struct CacheableEntry: Hashable {
        let beamPosition: Int
        let index: Int

        init(beamPosition: Int, at index: Int) {
            self.beamPosition = beamPosition
            self.index = index
        }
    }

    func countTimelines(
        in manifold: Manifold,
        currentLineIndex: Int,
        beamPosition: Int,
        cache: inout [CacheableEntry: Int]
    ) -> Int {
        guard currentLineIndex != manifold.contents.count else {
            return 1
        }

        let beamHit = manifold.contents[currentLineIndex][beamPosition]

        switch beamHit {
        case .empty:
            return countTimelines(
                in: manifold,
                currentLineIndex: currentLineIndex + 1,
                beamPosition: beamPosition,
                cache: &cache
            )
        case .splitter:
            let cacheableEntry = CacheableEntry(
                beamPosition: beamPosition,
                at: currentLineIndex,
            )
            if let cachedResult = cache[cacheableEntry] {
                return cachedResult
            } else {
                var totalTimelines = 0
                for newBeamPosition in [beamPosition - 1, beamPosition + 1] {
                    let timelines = countTimelines(
                        in: manifold,
                        currentLineIndex: currentLineIndex + 1,
                        beamPosition: newBeamPosition,
                        cache: &cache
                    )
                    totalTimelines += timelines
                }
                cache[cacheableEntry] = totalTimelines
                return totalTimelines
            }
        case .startPosition:
            return countTimelines(
                in: manifold,
                currentLineIndex: currentLineIndex + 1,
                beamPosition: beamPosition,
                cache: &cache
            )
        case .beam:
            fatalError()
        }
    }

    func part2() -> Any {
        var cache = [CacheableEntry: Int]()
        var beamPosition = 0
        for j in 0..<manifold.contents[0].count {
            if manifold.contents[0][j] == .startPosition {
                beamPosition = j
            }
        }

        return countTimelines(
            in: manifold,
            currentLineIndex: 1,
            beamPosition: beamPosition,
            cache: &cache
        )
    }
}
