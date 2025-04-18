//
//  OneWayHolder.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 20.03.2025.
//

import Foundation

/// A labyrinth element with two entrances on opposite sides, allowing movement in only one direction.
final class OneWayHolder<T: Topology>: TopologyBasedLabyrinthElement<T> {
    typealias Point = T.Point
    typealias Edge = T.Edge

    let passages: [Edge]
    let incomes: [Edge]
    let outgoings: [Edge]
    let walls: [Edge]

    init(passages: [Edge], incomes: [Edge], outgoings: [Edge], walls: [Edge]) {
        self.incomes = incomes
        self.outgoings = outgoings
        self.passages = passages
        self.walls = walls
    }

    override func singleConnected(_ point: Point) -> [ElementsConnection<Point>] {
        let onewayConnections = outgoings.map {
            let point = T.nextPoint(point: point, edge: $0)
            return ElementsConnection(point: point, type: .onewayPasssage)
        }

        let passagesConnections = passages.map {
            let point = T.nextPoint(point: point, edge: $0)
            return ElementsConnection(point: point, type: .passage)
        }

        return onewayConnections + passagesConnections
    }

    override func outcomeRestrictions<F>(point: Point, field: F) -> OutcomeRestrictions where F : TopologyField {
        Edge.allCases
            .map { restriction(point: point, edge: $0) }
            .toDictionary()
    }

    private func restriction(point: Point, edge: Edge) -> (Point, [ElementRestriction]) {
        let next = T.nextPoint(point: point, edge: edge)
        let adapted = T.adaptToNextPoint(edge)

        var restriction: ElementRestriction? = nil
        if incomes.contains(edge) {
            restriction = OneWayRestriction<T>(edge: adapted, direction: .outgoing)
        } else if outgoings.contains(edge) {
            restriction = OneWayRestriction<T>(edge: adapted, direction: .income)
        } else if passages.contains(edge) {
            restriction = PassagesElementRestriction<T>.passage(edge: adapted)
        } else {
            restriction = PassagesElementRestriction<T>.wall(edge: adapted)
        }

        guard let restriction = restriction else {
            return (next, [])
        }
        let onlyRequired = OnlyRequiredOnewaysRestriction()
        return (next, [restriction, onlyRequired])
    }
}

extension PathsEdgeType {
    static let onewayPasssage =
        PathsEdgeType(title: "oneway_passage", bidirectional: false)
}
