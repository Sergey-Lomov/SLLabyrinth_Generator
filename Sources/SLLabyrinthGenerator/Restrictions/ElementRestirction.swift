//
//  ElementRestriction.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

enum ElementRestriction<T> where T: Topology {
    case WallRestriction(edge: T.Edge)
    case PassageRestriction(edge: T.Edge)
}
