//
//  SquarePoint.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

struct SquarePoint: TopologyPoint, CustomStringConvertible {
    var x: Int
    var y: Int

    var description: String { "x: \(x) y: \(y)" }
}
