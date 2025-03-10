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
    func outcomeRestrictions<F: TopologyField>(point: Point, field: F) -> OutcomeRestrictions where F.Point == Point
}

class TopologyBasedLabyrinthElement<T: Topology>: LabyrinthElement {
    typealias Point = T.Point
    typealias Restriction = TopologyBasedElementRestriction<T>

    var isVisitable: Bool { true }

    func connectedPoints(_ point: Point) -> [Point] { [] }

    func outcomeRestrictions<F: TopologyField>(point: Point, field: F) -> OutcomeRestrictions where F.Point == Point { [:] }
}
