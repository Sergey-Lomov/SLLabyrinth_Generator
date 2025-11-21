//
//  ConnectionPreventRestriction.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 05.04.2025.
//

import Foundation

/// This type of restriction may be used in cyclic-area handling strategies to block connections between nodes.
final class ConnectionPreventRestriction<T: Topology>: ElementRestriction {
    var allowUnhandled: Bool { false }

    var target: T.Point

    init(target: T.Point) {
        self.target = target
    }
}
