//
//  Field.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

public protocol TopologyField {
    associatedtype Size
    associatedtype Point: TopologyPoint
    associatedtype Element: LabyrinthElement where Element.Point == Point

    var size: Size { get }
    init(size: Size)

    func copy() -> Self
    func allPoints() -> Set<Point>
    func undefinedPoints() -> Set<Point>
    func contains(_ point: Point) -> Bool
    func element(at point: Point) -> Element?
    mutating func setElement(at point: Point, element: Element?)
    func connectedPoints(_ point: Point) -> [Point]
}

extension TopologyField {
    func contains(_ point: Point) -> Bool {
        allPoints().contains(point)
    }
}
