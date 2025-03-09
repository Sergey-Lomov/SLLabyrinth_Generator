//
//  Field.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

class Field<T: Topology> {
    func allPoints() -> [T.Point] { [] }
    func allNodes() -> [Node<T>] { [] }
    func allSuperpositions() -> [NodeSuperposition<T>] { [] }
    func contains(_ point: T.Point) -> Bool { false }
    func nodeAt(_ point: T.Point) -> Node<T>? { nil }
    func superpositionAt(_ point: T.Point) -> NodeSuperposition<T>? { nil }

    func applyBorderConstraints() {
        allSuperpositions().forEach { superposition in
            T.Edge.allCases.forEach { edge in
                let next = T.nextPoint(point: superposition.point, edge: edge)
                if !contains(next) {
                    let restriction = ElementRestriction<T>.wall(edge: edge)
                    superposition.applyRestriction(restriction)
                }
            }
        }
    }

    func connectedPoints(_ point: T.Point) -> [T.Point] {
        guard let node = nodeAt(point) else { return [] }
        let connected = node.element?.connectedPoints(point)
        let nearest = T.Edge.allCases.map { T.nextPoint(point: point, edge: $0) }
        return (connected ?? nearest).filter { contains($0) }
    }
}
