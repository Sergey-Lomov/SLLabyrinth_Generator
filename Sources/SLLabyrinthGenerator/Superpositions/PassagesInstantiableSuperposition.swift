//
//  PassagesInstantiableSuperposition.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 29.03.2025.
//

import Foundation

class PassagesInstantiableSuperposition<T, E>: PassagesBasedSuperposition<T> where T: Topology, E: PassagesInstantiableElement<T> {

    required init() {
        super.init()
    }

    override func waveFunctionCollapse(point: Point, field: Field) -> Field.Element? {
        guard let variation = passagesVariations.randomElement() else { return nil }
        return E.init(passages: variation) as? Field.Element
    }
}
