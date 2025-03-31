//
//  Deadend.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// A labyrinth element with only one entrance.
final class Deadend<T: Topology>: PassagesInstantiableElement<T> { }

final class DeadendSuperposition<T: Topology>: PassagesInstantiableSuperposition<T, Deadend<T>>, CategorizedSuperposition {

    static var category: String { "deadend" }

    override func filterInitialPassages(_ variant: [T.Edge]) -> Bool {
        variant.count == 1
    }
}
