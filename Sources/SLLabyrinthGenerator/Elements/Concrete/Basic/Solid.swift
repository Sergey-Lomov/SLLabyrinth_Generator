//
//  Untitled.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

/// A solid labyrinth element with no entrance.
final class Solid<T: Topology>: PassagesBasedElement<T> {
    override var isVisitable: Bool { false }

    init() {
        super.init(passages: [])
    }
}

final class SolidSuperposition<T: Topology>: IsolatedElementSuperposition<T>, CategorizedSuperposition {

    static var category: String { "solid" }

    override func waveFunctionCollapse(point: Point, field: Field) -> Field.Element? {
        let solid = Solid<T>() as? Field.Element
        return available ? solid : nil
    }
}
