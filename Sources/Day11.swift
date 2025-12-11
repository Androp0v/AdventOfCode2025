import Algorithms

public struct Day11: AdventDay {

    let graphs: Set<GraphNode>

    final class GraphNode: Hashable, CustomStringConvertible, @unchecked Sendable {
        let name: String
        let hasOutput: Bool
        let isDAC: Bool
        let isFFT: Bool

        var connections = Set<GraphNode>()

        init(name: String, hasOutput: Bool) {
            self.name = name
            self.isDAC = name == "dac" ? true : false
            self.isFFT = name == "fft" ? true : false
            self.hasOutput = hasOutput
        }

        static func == (lhs: Day11.GraphNode, rhs: Day11.GraphNode) -> Bool {
            lhs.name == rhs.name
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }

        var description: String {
            "\(name): \(connections.map(\.name).joined(separator: " "))\(hasOutput ? "out" : "")"
        }
    }

    public init(data: String) {
        var graphs = Set<GraphNode>()
        for rawLine in data.split(separator: "\n") {
            let rawComponents = rawLine.split(separator: ":")
            graphs.insert(
                GraphNode(
                    name: String(rawComponents.first!),
                    hasOutput: rawComponents[1] == " out"
                )
            )
        }

        for rawLine in data.split(separator: "\n") {
            let rawComponents = rawLine.split(separator: ":")
            let currentNode = graphs.first(where: { $0.name == rawComponents.first! })
            for connection in rawComponents[1].split(separator: " ") {
                if connection == "out" {
                    continue
                } else {
                    let connectionNode = graphs.first(where: { $0.name == connection })
                    currentNode!.connections.insert(connectionNode!)
                }
            }
        }

        self.graphs = graphs
    }

    func findAllPathsOut(from node: GraphNode) -> Int {
        guard !node.hasOutput else {
            return 1
        }
        var total = 0
        for connection in node.connections {
            total += findAllPathsOut(from: connection)
        }
        return total
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        guard let initialNode = graphs.first(where: { $0.name == "you" }) else {
            return 0
        }
        return findAllPathsOut(from: initialNode)
    }

    /*
    func findAllPaths(from currentNode: GraphNode, to finalNode: GraphNode, excluding excludedNode: GraphNode) -> Int {
        guard !currentNode.connections.contains(finalNode) else {
            return 1
        }
        var total = 0
        for connection in currentNode.connections {
            guard connection != excludedNode else {
                continue
            }
            total += findAllPaths(from: connection, to: finalNode, excluding: excludedNode)
        }
        return total
    }

    func part2() -> Any {
        let initialNode = graphs.first(where: { $0.name == "svr" })!
        let dacNode = graphs.first(where: { $0.name == "dac" })!
        let fftNode = graphs.first(where: { $0.name == "fft" })!

        let svrToDAC = findAllPaths(from: initialNode, to: dacNode, excluding: fftNode)
        print("\(svrToDAC) paths from svr to dac")
        let svrToFFT = findAllPaths(from: initialNode, to: fftNode, excluding: dacNode)
        print("\(svrToFFT) paths from svr to fft")
        let dacOut = findAllPathsOut(from: dacNode)
        print("\(dacOut) paths from dac to out")
        let fftOut = findAllPathsOut(from: fftNode)
        print("\(fftOut) paths from fft to out")

        return 0
    }
     */

    func findValidPathsOut(
        from node: GraphNode,
        currentPath: [String],
        validPaths: inout [[String]]
    ) {
        var currentPath = currentPath
        currentPath.append(node.name)

        guard !node.hasOutput else {
            if currentPath.contains("dac") && currentPath.contains("fft") {
                validPaths.append(currentPath)
            }
            return
        }
        for connection in node.connections {
            findValidPathsOut(
                from: connection,
                currentPath: currentPath,
                validPaths: &validPaths
            )
        }
        return
    }

    func findValidPathsCount(
        from node: GraphNode,
        hasVisitedDAC: Bool,
        hasVisitedFFT: Bool,
        depth: Int
    ) async -> Int {
        guard !node.hasOutput else {
            if hasVisitedDAC && hasVisitedFFT {
                print("Found valid path")
                return 1
            } else {
                return 0
            }
        }

        if depth > 2 {
            var total = 0
            for connection in node.connections {
                total += await findValidPathsCount(
                    from: connection,
                    hasVisitedDAC: hasVisitedDAC || node.isDAC,
                    hasVisitedFFT: hasVisitedFFT || node.isFFT,
                    depth: depth + 1
                )
            }
            return total
        } else {
            return await withTaskGroup { taskGroup in
                for connection in node.connections {
                    taskGroup.addTask {
                        return await findValidPathsCount(
                            from: connection,
                            hasVisitedDAC: hasVisitedDAC || node.isDAC,
                            hasVisitedFFT: hasVisitedFFT || node.isFFT,
                            depth: depth + 1
                        )
                    }
                }

                var total = 0
                for await partialResult in taskGroup {
                    total += partialResult
                }
                return total
            }
        }
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() async -> Any {
        let initialNode = graphs.first(where: { $0.name == "svr" })!
        return await findValidPathsCount(
            from: initialNode,
            hasVisitedDAC: false,
            hasVisitedFFT: false,
            depth: 0
        )
    }
}
