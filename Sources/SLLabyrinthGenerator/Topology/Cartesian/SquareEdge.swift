//
//  SquareEdge.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

enum SquareEdge: TopologyEdge {
    case left, right, top, bottom

    func opposite() -> SquareEdge? {
        switch self {
        case .left: return .right
        case .right: return .left
        case .top: return .bottom
        case .bottom: return .top
        }
    }
}
