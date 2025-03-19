//
//  TopologyBasedLabyrinthElement.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

public protocol LabyrinthElement: AnyObject, Hashable {
    associatedtype Point: TopologyPoint
    associatedtype Restriction: ElementRestriction

    typealias OutcomeRestrictions = Dictionary<Point, [Restriction]>

    var id: String { get }
    var isVisitable: Bool { get }
    func connectedPoints(_ point: Point) -> [Point]
    func outcomeRestrictions<F: TopologyField>(point: Point, field: F) -> OutcomeRestrictions

    static func undefined<U: LabyrinthElement>() -> U?
}

class TopologyBasedLabyrinthElement<T: Topology>: LabyrinthElement, IdEquatable {

    typealias Point = T.Point
    typealias Restriction = TopologyBasedElementRestriction<T>

    var isVisitable: Bool { true }
    var id: String = "element_" + UUID().uuidString

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func connectedPoints(_ point: Point) -> [Point] { [] }

    func outcomeRestrictions<F: TopologyField>(point: Point, field: F) -> OutcomeRestrictions { [:] }

    static func undefined<U: LabyrinthElement>() -> U? { UndefinedElement<T>.init() as? U }
}
