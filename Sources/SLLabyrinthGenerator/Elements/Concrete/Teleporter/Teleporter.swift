//
//  Teleporter.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 29.03.2025.
//

import Foundation

enum TeleporterType: CaseIterable {
    case sender, receiver, bidirectional
}

final class Teleporter<T: Topology>: PassagesBasedElement<T> {
    typealias Point = T.Point
    typealias Edge = T.Edge

    var target: Point
    var type: TeleporterType

    init(target: Point, type: TeleporterType, passages: [Edge]) {
        self.target = target
        self.type = type
        super.init(passages: passages)
    }

    override func connected(_ point: Point) -> [ElementsConnection<Point>] {
        var connections = super.connected(point)

        if type != .receiver {
            let connection = ElementsConnection<Point>(point: target, edgeType: .teleport)
            connections.append(connection)
        }

        return connections
    }

    override func outcomeRestrictions<F: TopologyField>(point: Point, field: F) -> OutcomeRestrictions {
        var restrictions = super.outcomeRestrictions(point: point, field: field)

        let teleporterRestriction = TeleporterRestriction<T>(
            target: point,
            types: targetTypes()
        )
        restrictions.append(key: target, arrayValue: teleporterRestriction)

        return restrictions
    }

    private func targetTypes() -> Set<TeleporterType> {
        switch type {
        case .sender:
            [.receiver]
        case .receiver:
            [.sender]
        case .bidirectional:
            [.bidirectional]
        }
    }
}
