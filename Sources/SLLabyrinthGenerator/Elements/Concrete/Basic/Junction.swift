//
//  Junction.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 06.03.2025.
//

import Foundation

/// A labyrinth element with more than two entrances.
final class Junction<T: Topology>: PassagesBasedElement<T> {}

final class JunctionSuperposition<T: Topology>: PassagesBasedSuperposition<T, Junction<T>>, CategorizedSuperposition {
    typealias Element = Junction

    static var category: String { "junction" }

    override func filterInitial(_ variant: [T.Edge]) -> Bool {
        variant.count > 2
    }
}

