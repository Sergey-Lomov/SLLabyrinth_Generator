//
//  IsolatedRoom.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 18.11.2025.
//

import Foundation

/// An isolated room element with no entrance, but visitable.
final class IsolatedRoom<T: Topology>: PassagesBasedElement<T> {

    init() {
        super.init(passages: [])
    }
}

final class IsolatedRoomSuperposition<T: Topology>: IsolatedElementSuperposition<T>, CategorizedSuperposition {

    static var category: String { "isolated_room" }

    override func waveFunctionCollapse(point: Point, field: Field) -> Field.Element? {
        let room = IsolatedRoom<T>() as? Field.Element
        return available ? room : nil
    }
}
