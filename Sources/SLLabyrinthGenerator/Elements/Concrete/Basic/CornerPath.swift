//
//  CornerPath.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// A labyrinth element with two entrances on non-opposite sides.
final class CornerPath<T: Topology>: PassagesBasedElement<T> {}

final class CornerPathSuperposition<T: Topology>: PassagesBasedSuperposition<T, CornerPath<T>>, CategorizedSuperposition {
    // TODO: Investigate possbility to remove this and similar typealiases. Looks like Element typealias inside superpositions is unused.
    typealias Element = CornerPath

    static var category: String { "corner_path" }

    override func filterInitial(_ variant: [T.Edge]) -> Bool {
        guard variant.count == 2 else { return false }
        return variant[0].opposite() != variant[1]
    }
}
