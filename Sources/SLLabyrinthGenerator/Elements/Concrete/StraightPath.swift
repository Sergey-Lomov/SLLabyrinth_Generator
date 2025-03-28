//
//  StraightPath.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// A labyrinth element with two entrances on opposite sides.
class StraightPath<T: Topology>: EdgeBasedElement<T> {
    init(path: (T.Edge, T.Edge)) {
        super.init(passages: [path.0, path.1])
    }
}

final class StraightPathSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, CategorizedSuperposition {
    typealias Element = StraightPath

    static var category: String { "straight_path" }

    static var initialPaths: [(T.Edge, T.Edge)] {
        GlobalCache.getValue(id: "straight_path_init") {
            T.Edge.allCases.toArray().oppositePairs()
        }
    }

    var paths = initialPaths

    override var entropy: Int {
        paths.count
    }

    required init() {
        super.init()
    }

    init(paths: [(T.Edge, T.Edge)]) {
        super.init()
        self.paths = paths
    }

    override func copy() -> Self {
        Self.init(paths: paths)
    }

    override func applyCommonRestriction(_ restriction: TopologyBasedElementRestriction<T>) -> Bool {
        switch restriction {
        case .wall(let edge), .fieldEdge(let edge):
            paths = paths.filter { $0.0 != edge && $0.1 != edge }
        case .passage(let edge):
            paths = paths.filter { $0.0 == edge || $0.1 == edge }
        @unknown default:
            return false
        }

        return true
    }

    override func resetRestrictions() {
        paths = Self.initialPaths
    }

    override func waveFunctionCollapse() -> T.Field.Element? {
        guard let path = paths.randomElement() else { return nil }
        return StraightPath<T>(path: path) as? T.Field.Element
    }
}
