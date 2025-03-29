//
//  PassagesBasedElement.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 08.03.2025.
//

/// Abstract base class for all labyrinth elements based on their passages
class PassagesBasedElement<T: Topology>: TopologyBasedLabyrinthElement<T> {
    var passages: [T.Edge]

    required init(passages: [T.Edge]) {
        self.passages = passages
    }

    override func outcomeRestrictions<F: TopologyField>(point: Point, field: F) -> OutcomeRestrictions {
        T.Edge.allCases.reduce(into: OutcomeRestrictions()) { restrictions, edge in
            let target = T.nextPoint(point: point, edge: edge)
            let adaptedEdge = T.adaptToNextPoint(edge)

            let restriction: TopologyBasedElementRestriction<T> = passages.contains(edge) ?
                .passage(edge: adaptedEdge) :
                .wall(edge: adaptedEdge)

            restrictions.append(key: target, arrayValue: restriction)
        }
    }

    override func connectedPoints(_ point: T.Point) -> [T.Point] {
        passages.map {
            T.nextPoint(point: point, edge: $0)
        }
    }
}
