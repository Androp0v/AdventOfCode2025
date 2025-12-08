//
//  Day08.swift
//  AdventOfCode
//
//  Created by Raúl Montón Pinillos on 6/12/25.
//

import Algorithms
import simd

struct Day08: AdventDay {

    let positions: [simd_double3]

    init(data: String) {
        var positions = [simd_double3]()
        for rawPosition in data.split(separator: "\n") {
            let numbers = rawPosition.split(separator: ",").map {
                Double($0)!
            }
            positions.append(simd_double3(
                numbers[0],
                numbers[1],
                numbers[2])
            )
        }
        self.positions = positions
    }

    struct Connection {
        let distance: Double
        let boxA: simd_double3
        let boxB: simd_double3
    }

    func findClosestPairs(in positions: [simd_double3], upTo maxLength: Int) -> [Connection] {
        var distances = [Double: (Int, Int)]()
        for i in 0..<positions.count {
            for j in i..<positions.count {
                guard i != j else { continue }
                let distance = simd_distance(positions[i], positions[j])
                distances[distance] = (i, j)
            }
        }

        var connections = [Connection]()
        for distance in distances.keys.sorted().prefix(maxLength) {
            connections.append(Connection(
                distance: distance,
                boxA: positions[distances[distance]!.0],
                boxB: positions[distances[distance]!.1]
            ))
        }

        return connections
    }

    func part1() -> Any {
        let connections = findClosestPairs(in: positions, upTo: 1000)

        var junctionBoxSubgraphs = Set<Set<simd_double3>>()
        for connection in connections {
            connectJunctionBoxes(
                connection: connection,
                subgraphs: &junctionBoxSubgraphs
            )
        }
        let junctionBoxCount = junctionBoxSubgraphs
            .map(\.count)
            .sorted(by: { $0 > $1 })

        return junctionBoxCount[0] * junctionBoxCount[1] * junctionBoxCount[2]
    }

    func connectJunctionBoxes(
        connection: Connection,
        subgraphs: inout Set<Set<simd_double3>>
    ) {
        if let existingSubgraphForA = subgraphs.first(where: { $0.contains(connection.boxA) }) {
            // Box A is already part of a subgraph
            guard !existingSubgraphForA.contains(connection.boxB) else {
                // Subgraph already contains box A and B
                return
            }
            if let existingSubgraphForB = subgraphs.first(where: { $0.contains(connection.boxB) }) {
                // Box A and box B are part of two different graphs. Merge them.
                subgraphs.remove(existingSubgraphForA)
                subgraphs.remove(existingSubgraphForB)
                let mergedSubgraph = existingSubgraphForA.union(existingSubgraphForB)
                subgraphs.insert(mergedSubgraph)
            } else {
                // Box B isn't present in any other subgraph.
                subgraphs.remove(existingSubgraphForA)
                var expandedSubgraph = existingSubgraphForA
                expandedSubgraph.insert(connection.boxB)
                subgraphs.insert(expandedSubgraph)
            }
        } else if let existingSubgraphForB = subgraphs.first(where: { $0.contains(connection.boxB) }) {
            // Box B is already part of a subgraph, but A isn't.
            subgraphs.remove(existingSubgraphForB)
            var expandedSubgraph = existingSubgraphForB
            expandedSubgraph.insert(connection.boxA)
            subgraphs.insert(expandedSubgraph)
        } else {
            // Neither box A nor B are part of any subgraph.
            var newSubgraph = Set<simd_double3>()
            newSubgraph.insert(connection.boxA)
            newSubgraph.insert(connection.boxB)
            subgraphs.insert(newSubgraph)
        }
    }

    func findClosestUnconnectedPair(in positions: [simd_double3], subgraphs: Set<Set<simd_double3>>) -> Connection {
        var minDistance: Double = .infinity
        var minPair: (simd_double3, simd_double3)!
        for i in 0..<positions.count {
            for j in i..<positions.count {
                guard i != j else { continue }
                let isAConnected = subgraphs.contains(where: { $0.contains(positions[i]) })
                let isBConnected = subgraphs.contains(where: { $0.contains(positions[i]) })
                guard !isAConnected || !isBConnected else { continue }
                let distance = simd_distance(positions[i], positions[j])
                if distance < minDistance {
                    minDistance = distance
                    minPair = (positions[i], positions[j])
                }
            }
        }
        return Connection(
            distance: minDistance,
            boxA: minPair.0,
            boxB: minPair.1
        )
    }

    func totalCircuits(subgraphs: Set<Set<simd_double3>>, positions: [simd_double3]) -> Int {
        let subCircuits = subgraphs.count
        let isolated = positions.filter { position in
            return !subgraphs.contains(where: { subgraph in
                subgraph.contains(position)
            })
        }.count
        return subCircuits + isolated
    }

    func part2() -> Any {
        let connections = findClosestPairs(in: positions, upTo: Int.max)
        var subgraphs = Set<Set<simd_double3>>()
        for connection in connections.prefix(1000) {
            connectJunctionBoxes(
                connection: connection,
                subgraphs: &subgraphs
            )
        }
        for connection in connections.dropFirst(1000) {
            connectJunctionBoxes(
                connection: connection,
                subgraphs: &subgraphs
            )
            let circuits = totalCircuits(subgraphs: subgraphs, positions: positions)

            if circuits == 1 {
                return Int(connection.boxA.x * connection.boxB.x)
            }
        }
        fatalError("Unreachable, hopefully...")
    }
}
