//
//  Field.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

class Field<T: Topology> {
    func allPoints() -> [T.Point] { [] }
    func allSuperpositions() -> [NodeSuperposition<T>] { [] }
    func contains(_ point: T.Point) -> Bool { false }
    func element(at point: T.Point) -> TopologyBasedLabyrinthElement<T>? { nil }
    func setElement(at point: T.Point, element: TopologyBasedLabyrinthElement<T>?) { }
    func superpositionAt(_ point: T.Point) -> NodeSuperposition<T>? { nil }

    func applyBorderConstraints() {
        allSuperpositions().forEach { superposition in
            T.Edge.allCases.forEach { edge in
                let next = T.nextPoint(point: superposition.point, edge: edge)
                if !contains(next) {
                    let restriction = TopologyBasedElementRestriction<T>.wall(edge: edge)
                    superposition.applyRestriction(restriction)
                }
            }
        }
    }

    func connectedPoints(_ point: T.Point) -> [T.Point] {
        let connected = element(at: point)?.connectedPoints(point)
        let nearest = T.Edge.allCases.map { T.nextPoint(point: point, edge: $0) }
        return (connected ?? nearest).filter { contains($0) }
    }
}
