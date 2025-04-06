//
//  OneWayRestrictions.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 28.03.2025.
//

import Foundation

enum OnewayDirection {
    case income, outgoing
}

final class OneWayRestriction<T: Topology>: ElementRestriction, IdHashable {
    typealias Edge = T.Edge

    var allowUnhandled: Bool { false }

    let id = UUID().uuidString
    let edge: Edge
    let direction: OnewayDirection

    init(edge: Edge, direction: OnewayDirection) {
        self.edge = edge
        self.direction = direction
    }
}

final class OnlyRequiredOnewaysRestriction: ElementRestriction {
    var allowUnhandled: Bool { true }
}
