//
//  Day08.swift
//  AdventOfCode
//
//  Created by Raúl Montón Pinillos on 6/12/25.
//

import Algorithms
import Collections
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

    struct Connection: Comparable {
        let distance: Double
        let boxA: simd_double3
        let boxB: simd_double3

        static func < (lhs: Day08.Connection, rhs: Day08.Connection) -> Bool {
            return lhs.distance < rhs.distance
        }
    }

    func findConnections(in positions: [simd_double3]) -> Heap<Connection> {
        var connections = Heap<Connection>()
        for i in 0..<positions.count {
            for j in i..<positions.count {
                guard i != j else { continue }
                let distance = simd_distance(positions[i], positions[j])
                connections.insert(Connection(
                    distance: distance,
                    boxA: positions[i],
                    boxB: positions[j])
                )
            }
        }
        return connections
    }

    func part1() -> Any {
        var connections = findConnections(in: positions)

        var junctionBoxSubgraphs = Set<Set<simd_double3>>()
        for _ in 0..<1000 {
            let connection = connections.popMin()!
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

    func isFullyConnected(subgraphs: Set<Set<simd_double3>>, positions: [simd_double3]) -> Bool {
        guard subgraphs.count == 1 else {
            return false
        }
        for position in positions {
            guard subgraphs.first!.contains(position) else {
                return false
            }
        }
        return true
    }

    func part2() -> Any {
        var connections = findConnections(in: positions)
        var subgraphs = Set<Set<simd_double3>>()
        for index in 0..<Int.max {
            let connection = connections.popMin()!
            connectJunctionBoxes(
                connection: connection,
                subgraphs: &subgraphs
            )
            if index >= 1000 {
                if isFullyConnected(subgraphs: subgraphs, positions: positions) {
                    return Int(connection.boxA.x * connection.boxB.x)
                }
            }
        }
        fatalError("Unreachable, hopefully...")
    }
}
