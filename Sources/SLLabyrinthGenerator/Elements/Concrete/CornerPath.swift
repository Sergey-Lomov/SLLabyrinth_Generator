//
//  CornerPath.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// A labyrinth element with two entrances on non-opposite sides.
class CornerPath<T: Topology>: EdgeBasedElement<T> {
    init(path: (T.Edge, T.Edge)) {
        super.init(passages: [path.0, path.1])
    }
}

final class CornerPathSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, WeightableSuperposition {
    typealias Element = CornerPath

    static var weigthCategory: String { "corner_path" }

    var paths = T.Edge.allCases.pairs().removeOppositePairs()

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

    override func applyRestriction(_ restriction: TopologyBasedElementRestriction<T>) {
        switch restriction {
        case .wall(let edge), .fieldEdge(let edge):
            paths = paths.filter { $0 != edge && $1 != edge }
        case .passage(let edge):
            paths = paths.filter { $0 == edge || $1 == edge }
        }
    }

    override func resetRestrictions() {
        paths = T.Edge.allCases.pairs().removeOppositePairs()
    }

    override func waveFunctionCollapse() -> T.Field.Element? {
        guard let path = paths.randomElement() else { return nil }
        return CornerPath<T>(path: path) as? T.Field.Element
    }
}
