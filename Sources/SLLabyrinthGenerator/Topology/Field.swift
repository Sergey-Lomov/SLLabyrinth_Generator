//
//  Field.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

public protocol TopologyField {
    associatedtype Point: TopologyPoint
    associatedtype Element: LabyrinthElement where Element.Point == Point

    func allPoints() -> [Point]
    func contains(_ point: Point) -> Bool
    func element(at point: Point) -> Element?
    func setElement(at point: Point, element: Element?)
    func connectedPoints(_ point: Point) -> [Point]
}

public class TopologyBasedField<T: Topology>: TopologyField {
    public typealias Point = T.Point
    public typealias Element = T.Field.Element

    public func allPoints() -> [Point] { [] }
    public func contains(_ point: Point) -> Bool { false }
    public func element(at point: Point) -> Element? { nil }
    public func setElement(at point: Point, element: Element?) { }

    public func connectedPoints(_ point: Point) -> [Point] {
        let connected = element(at: point)?.connectedPoints(point)
        let nearest = T.Edge.allCases.map { T.nextPoint(point: point, edge: $0) }
        return (connected ?? nearest).filter { contains($0) }
    }
}
