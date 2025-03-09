//
//  LabyrinthElement.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

class LabyrinthElement<T: Topology> {
    typealias OutcomeRestrictions = Dictionary<T.Point, [ElementRestriction<T>]>

    func connectedPoints(_ point: T.Point) -> [T.Point] { [] }
    func outcomeRestrictions(point: T.Point, field: Field<T>) -> OutcomeRestrictions { [:] }
}
