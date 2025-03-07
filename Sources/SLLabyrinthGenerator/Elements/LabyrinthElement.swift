//
//  LabyrinthElement.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

class LabyrinthElement<T: Topology> {
    typealias OutcomeRestrictions = Dictionary<T.Point, Array<ElementRestriction<T>>>

    func outcomeRestrictions(point: T.Point, field: Field<T>) -> OutcomeRestrictions { [:] }

    func edgesBasedOutcomeRestrictions(
        point: T.Point,
        entranceValidator: (T.Edge) -> Bool
    ) -> OutcomeRestrictions {
        T.Edge.allCases.reduce(into: OutcomeRestrictions()) { restrictions, edge in
            let target = T.nextPoint(point: point, edge: edge)
            let adaptedEdge = T.adaptToNextPoint(edge)

            let restriction: ElementRestriction<T> = entranceValidator(edge) ?
                .passage(edge: adaptedEdge) :
                .wall(edge: adaptedEdge)

            if !restrictions.keys.contains(target) {
                restrictions[target] = []
            }
            restrictions[target]?.append(restriction)
        }
    }
}
