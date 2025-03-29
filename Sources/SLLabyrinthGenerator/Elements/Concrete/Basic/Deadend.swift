//
//  Deadend.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// A labyrinth element with only one entrance.
final class Deadend<T: Topology>: PassagesBasedElement<T> { }

final class DeadendSuperposition<T: Topology>: PassagesBasedSuperposition<T, Deadend<T>>, CategorizedSuperposition {

    static var category: String { "deadend" }

    override func filterInitial(_ variant: [T.Edge]) -> Bool {
        variant.count == 1
    }
}
