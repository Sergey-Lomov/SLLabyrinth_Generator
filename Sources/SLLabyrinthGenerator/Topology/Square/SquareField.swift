//
//  SquareField.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

final class SquareField: DictionaryBasedField {
    typealias Size = (Int, Int)
    typealias Point = SquarePoint
    typealias Element = TopologyBasedLabyrinthElement<SquareTopology>

    let size: Size
    var nodes: Dictionary<Point, Element> = [:]

    init(size: Size) {
        self.size = size
        for x in 0..<size.0 {
            for y in 0..<size.1 {
                let point = SquarePoint(x: x, y: y)
                nodes[point] = Element.undefined()
            }
        }
    }

    func connectedPoints(_ point: SquarePoint) -> [SquarePoint] {
        let connected = element(at: point)?.connectedPoints(point)
        let nearest = SquareEdge.allCases.map { SquareTopology.nextPoint(point: point, edge: $0) }
        return (connected ?? nearest).filter { contains($0) }
    }
}
