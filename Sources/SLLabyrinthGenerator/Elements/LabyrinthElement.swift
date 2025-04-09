//
//  TopologyBasedLabyrinthElement.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

public protocol LabyrinthElement: AnyObject, Hashable {
    associatedtype Point: TopologyPoint

    typealias OutcomeRestrictions = Dictionary<Point, [any ElementRestriction]>

    var isVisitable: Bool { get }
    var restrictionId: String { get }

    func connected(_ point: Point) -> [ElementConnectionsGroup<Point>]
    func outcomeRestrictions<F: TopologyField>(point: Point, field: F) -> OutcomeRestrictions

    static func undefined<U: LabyrinthElement>() -> U?
    static func isUndefined(_ element: any LabyrinthElement) -> Bool
}

class TopologyBasedLabyrinthElement<T: Topology>: LabyrinthElement, IdHashable {

    typealias Point = T.Point
    typealias Restriction = PassagesElementRestriction<T>

    var isVisitable: Bool { true }
    var id = UIDProvider.next()
    var restrictionId: String { "element_\(id)" }

    func connected(_ point: Point) -> [ElementConnectionsGroup<Point>] {
        let group = ElementConnectionsGroup(
            vertexType: .basic,
            connections: singleConnected(point)
        )
        return [group]
    }

    func singleConnected(_ point: Point) -> [ElementsConnection<Point>] { [] }

    func outcomeRestrictions<F: TopologyField>(point: Point, field: F) -> OutcomeRestrictions { [:] }

    static func undefined<U: LabyrinthElement>() -> U? { UndefinedElement<T>.init() as? U }

    static func isUndefined(_ element: any LabyrinthElement) -> Bool {
        element is UndefinedElement<T>
    }
}
