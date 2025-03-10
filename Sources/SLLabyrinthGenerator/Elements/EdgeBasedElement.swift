//
//  EdgeBasedElement.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 08.03.2025.
//

/// Abstract base class for all labyrinth elements based on their edges—walls or passages.
class EdgeBasedElement<T: Topology>: TopologyBasedLabyrinthElement<T> {
    var passages: [T.Edge]

    init(passages: [T.Edge]) {
        self.passages = passages
    }

    override func outcomeRestrictions<FT>(point: Point, field: TopologyBasedField<FT>) -> OutcomeRestrictions where FT : Topology, T.Point == FT.Point {
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
