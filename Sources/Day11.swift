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

    // MARK: - Init

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

    // MARK: - Part 1

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

    // MARK: - Part 2

    func findAllPathsToDAC(
        from currentNode: GraphNode,
        cache: inout [GraphNode: Int]
    ) -> Int {
        guard !currentNode.isDAC else {
            return 1
        }
        if let cachedValue = cache[currentNode] {
            return cachedValue
        }
        var total = 0
        for connection in currentNode.connections {
            guard !connection.isFFT else {
                continue
            }
            total += findAllPathsToDAC(from: connection, cache: &cache)
        }
        cache[currentNode] = total
        return total
    }

    func findAllPathsToFFT(
        from currentNode: GraphNode,
        cache: inout [GraphNode: Int]
    ) -> Int {
        guard !currentNode.isFFT else {
            return 1
        }
        if let cachedValue = cache[currentNode] {
            return cachedValue
        }
        var total = 0
        for connection in currentNode.connections {
            guard !connection.isDAC else {
                continue
            }
            total += findAllPathsToFFT(from: connection, cache: &cache)
        }
        cache[currentNode] = total
        return total
    }

    func findAllPathsFromDACToFFT(
        currentNode: GraphNode,
        cache: inout [GraphNode: Int]
    ) -> Int {
        guard !currentNode.isFFT else {
            return 1
        }
        if let cachedValue = cache[currentNode] {
            return cachedValue
        }
        var total = 0
        for connection in currentNode.connections {
            total += findAllPathsFromDACToFFT(currentNode: connection, cache: &cache)
        }
        cache[currentNode] = total
        return total
    }

    func findAllPathsFromFFTToDAC(
        currentNode: GraphNode,
        cache: inout [GraphNode: Int]
    ) -> Int {
        guard !currentNode.isDAC else {
            return 1
        }
        if let cachedValue = cache[currentNode] {
            return cachedValue
        }
        var total = 0
        for connection in currentNode.connections {
            total += findAllPathsFromFFTToDAC(currentNode: connection, cache: &cache)
        }
        cache[currentNode] = total
        return total
    }

    func findAllPathsOutExcludingDACAndFFT(
        from node: GraphNode,
        cache: inout [GraphNode: Int]
    ) -> Int {
        guard !node.hasOutput else {
            return 1
        }
        if let cachedValue = cache[node] {
            return cachedValue
        }
        var total = 0
        for connection in node.connections {
            guard !connection.isDAC else {
                continue
            }
            guard !connection.isFFT else {
                continue
            }
            total += findAllPathsOutExcludingDACAndFFT(from: connection, cache: &cache)
        }
        cache[node] = total
        return total
    }

    func part2() -> Any {
        let initialNode = graphs.first(where: { $0.name == "svr" })!
        let dacNode = graphs.first(where: { $0.name == "dac" })!
        let fftNode = graphs.first(where: { $0.name == "fft" })!

        // Paths from SVR to DAC
        var svrToDACCache = [GraphNode: Int]()
        let svrToDAC = findAllPathsToDAC(from: initialNode, cache: &svrToDACCache)

        // Paths from SVR to FFT
        var svrToFFTCache = [GraphNode: Int]()
        let svrToFFT = findAllPathsToFFT(from: initialNode, cache: &svrToFFTCache)

        // Paths from DAC to FFT
        var dacToFFTCache = [GraphNode: Int]()
        let dacToFFT = findAllPathsFromDACToFFT(currentNode: dacNode, cache: &dacToFFTCache)

        // Paths from FFT to DAC
        var fftToDACCache = [GraphNode: Int]()
        let fftToDAC = findAllPathsFromFFTToDAC(currentNode: fftNode, cache: &fftToDACCache)

        // Paths out
        var pathsOutCache = [GraphNode: Int]()
        // Paths from DAC out
        let dacOut = findAllPathsOutExcludingDACAndFFT(from: dacNode, cache: &pathsOutCache)
        // Paths from FFT out
        let fftOut = findAllPathsOutExcludingDACAndFFT(from: fftNode, cache: &pathsOutCache)

        var total = 0
        // This combination includes all SVR -> DAC -> FFT -> Out paths
        total += svrToDAC * dacToFFT * fftOut
        // And this combination includes all SVR -> FFT -> DAC -> Out paths
        total += svrToFFT * fftToDAC * dacOut
        return total
    }
}
