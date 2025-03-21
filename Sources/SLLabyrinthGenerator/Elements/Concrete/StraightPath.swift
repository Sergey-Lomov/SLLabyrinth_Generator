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

final class StraightPathSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, WeightableSuperposition {
    typealias Element = StraightPath

    static var weigthCategory: String { "straight_path" }

    var paths = Array(T.Edge.allCases).oppositePairs()

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

    override func applyCommonRestriction(_ restriction: TopologyBasedElementRestriction<T>) {
        switch restriction {
        case .wall(let edge), .fieldEdge(let edge):
            paths = paths.filter { $0.0 != edge && $0.1 != edge }
        case .passage(let edge):
            paths = paths.filter { $0.0 == edge || $0.1 == edge }
        }
    }

    override func resetRestrictions() {
        paths = Array(T.Edge.allCases).oppositePairs()
    }

    override func waveFunctionCollapse() -> T.Field.Element? {
        guard let path = paths.randomElement() else { return nil }
        return StraightPath<T>(path: path) as? T.Field.Element
    }
}
