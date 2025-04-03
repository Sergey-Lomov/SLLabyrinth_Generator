//
//  TopologyBasedLabyrinthElement.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

public struct ElementsConnection<P: TopologyPoint> {
    let point: P
    let category: String

    init(point: P, category: String = PathsEdgeCategory.passage) {
        self.point = point
        self.category = category
    }
}

public protocol LabyrinthElement: AnyObject, Hashable {
    associatedtype Point: TopologyPoint

    typealias OutcomeRestrictions = Dictionary<Point, [any ElementRestriction]>

    var id: String { get }
    var isVisitable: Bool { get }

    func connected(_ point: Point) -> [ElementsConnection<Point>]
    func outcomeRestrictions<F: TopologyField>(point: Point, field: F) -> OutcomeRestrictions

    static func undefined<U: LabyrinthElement>() -> U?
    static func isUndefined(_ element: any LabyrinthElement) -> Bool
}

class TopologyBasedLabyrinthElement<T: Topology>: LabyrinthElement, IdHashable {

    typealias Point = T.Point
    typealias Restriction = TopologyBasedElementRestriction<T>

    var isVisitable: Bool { true }
    var id: String = "element_" + UUID().uuidString

    func connected(_ point: Point) -> [ElementsConnection<Point>] { [] }

    func outcomeRestrictions<F: TopologyField>(point: Point, field: F) -> OutcomeRestrictions { [:] }

    static func undefined<U: LabyrinthElement>() -> U? { UndefinedElement<T>.init() as? U }

    static func isUndefined(_ element: any LabyrinthElement) -> Bool {
        element is UndefinedElement<T>
    }
}
