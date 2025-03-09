//
//  EdgeBasedElement.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 08.03.2025.
//

/// Abstract base class for all labyrinth elements based on their edges—walls or passages.
class EdgeBasedElement<T: Topology>: LabyrinthElement<T> {
    var passages: [T.Edge]

    init(passages: [T.Edge]) {
        self.passages = passages
    }

    override func outcomeRestrictions(point: T.Point, field: Field<T>) -> OutcomeRestrictions {
        T.Edge.allCases.reduce(into: OutcomeRestrictions()) { restrictions, edge in
            let target = T.nextPoint(point: point, edge: edge)
            let adaptedEdge = T.adaptToNextPoint(edge)

            let restriction: ElementRestriction<T> = passages.contains(edge) ?
                .passage(edge: adaptedEdge) :
                .wall(edge: adaptedEdge)

            if !restrictions.keys.contains(target) {
                restrictions[target] = []
            }
            restrictions[target]?.append(restriction)
        }
    }

    override func connectedPoints(_ point: T.Point) -> [T.Point] {
        passages.map {
            T.nextPoint(point: point, edge: $0)
        }
    }
}
