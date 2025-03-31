//
//  SquareTopology.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import math_h

final class SquareTopology: Topology {
    typealias Point = SquarePoint
    typealias Edge = SquareEdge
    typealias Field = SquareField
    typealias Superposition = TopologyBasedNodeSuperposition<SquareTopology>

    static func nextPoint(point: Point, edge: Edge) -> Point {
        switch edge {
        case .left: return SquarePoint(x: point.x - 1, y: point.y)
        case .right: return SquarePoint(x: point.x + 1, y: point.y)
        case .top: return SquarePoint(x: point.x, y: point.y + 1)
        case .bottom: return SquarePoint(x: point.x, y: point.y - 1)
        }
    }

    static func distance(point1: SquarePoint, point2: SquarePoint) -> Float {
        let dx = Float(point1.x - point2.x)
        let dy = Float(point1.y - point2.y)
        return sqrt(dx*dx + dy*dy)
    }

    static func oppositeEdge(_ edge: Edge) -> Edge? {
        switch edge {
        case .left: return .right
        case .right: return .left
        case .top: return .bottom
        case .bottom: return .top
        }
    }

    static func visualScale(size: Field.Size, width: Float, height: Float) -> Float {
        let hScale = width / Float(size.0)
        let vScale = height / Float(size.1)
        return min(hScale, vScale)
    }

    static func visualPosition(_ point: Point) -> (Float, Float) {
        (Float(point.x) + 0.5, Float(point.y) + 0.5)
    }
}
