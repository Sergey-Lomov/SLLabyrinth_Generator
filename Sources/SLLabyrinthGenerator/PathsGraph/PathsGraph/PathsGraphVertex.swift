//
//  PathsGraphVertex.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

import Foundation

// Extensionable enum of edge types
struct PathsVertexType: Hashable {
    static let basic =
        PathsVertexType(title: "basic", compactizable: true)

    var title: String
    var compactizable: Bool
}

struct PathsGraphVertex<T: Topology>: GraphVertex, Hashable
{
    typealias Point = T.Point

    let point: Point
    let type: PathsVertexType
    let edgePointsValidator: (([Point]) -> Bool)?

    init(
        point: Point,
        type: PathsVertexType = .basic,
        edgePointsValidator: (([Point]) -> Bool)? = nil
    ) {
        self.point = point
        self.type = type
        self.edgePointsValidator = edgePointsValidator
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.point == rhs.point && lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(point)
        hasher.combine(type)
    }
}
