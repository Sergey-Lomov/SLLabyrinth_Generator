//
//  Field.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

class Field<T: Topology> {
    func allSuperpositions() -> Array<NodeSuperposition<T>> { [] }
    func nodeAt(_ point: T.Point) -> Node<T>? { nil }
    func superpositionAt(_ point: T.Point) -> NodeSuperposition<T>? { nil }

    func applyBorderConstraints() {
        allSuperpositions().forEach { superposition in
            T.Edge.allCases.forEach { edge in
                let next = T.nextPoint(point: superposition.point, edge: edge)
                if superpositionAt(next) == nil {
                    let restriction = ElementRestriction<T>.wall(edge: edge)
                    superposition.applyRestriction(restriction)
                }
            }
        }
    }
}
