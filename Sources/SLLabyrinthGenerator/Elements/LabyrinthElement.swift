//
//  TopologyBasedLabyrinthElement.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

public protocol LabyrinthElement {
    associatedtype Point: TopologyPoint
    associatedtype Restriction: ElementRestriction

    typealias OutcomeRestrictions = Dictionary<Point, [Restriction]>

    var isVisitable: Bool { get }
    func connectedPoints(_ point: Point) -> [Point]
    func outcomeRestrictions<T: Topology>(point: Point, field: TopologyBasedField<T>) -> OutcomeRestrictions where T.Point == Point
}

class TopologyBasedLabyrinthElement<T: Topology>: LabyrinthElement {
    typealias Point = T.Point
    typealias Restriction = TopologyBasedElementRestriction<T>

    var isVisitable: Bool { true }

    func connectedPoints(_ point: Point) -> [Point] { [] }

    func outcomeRestrictions<FT>(point: Point, field: TopologyBasedField<FT>) -> OutcomeRestrictions where T : Topology, FT.Point == Point { [:] }
}
