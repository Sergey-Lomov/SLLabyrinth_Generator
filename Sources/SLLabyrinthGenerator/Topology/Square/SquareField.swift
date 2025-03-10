//
//  SquareField.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

final class SquareField: TopologyField {
    typealias Size = (Int, Int)
    typealias Point = SquarePoint
    typealias Element = TopologyBasedLabyrinthElement<SquareTopology>

    let size: Size
    var nodes: Dictionary<Point, Element> = [:]

    init(size: Size) {
        self.size = size
    }

    func allPoints() -> [SquarePoint] {
        (0..<size.0).flatMap { x in
            (0..<size.1).map { y in
                SquarePoint(x: x, y: y)
            }
        }
    }

    func element(at point: Point) -> Element? {
        nodes[point]
    }

    func setElement(at point: Point, element: Element?) {
        guard contains(point) else { return }
        nodes[point] = element
    }

    func connectedPoints(_ point: SquarePoint) -> [SquarePoint] {
        let connected = element(at: point)?.connectedPoints(point)
        let nearest = SquareEdge.allCases.map { SquareTopology.nextPoint(point: point, edge: $0) }
        return (connected ?? nearest).filter { contains($0) }
    }
}
