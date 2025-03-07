//
//  ElementRestriction.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

enum ElementRestriction<T> where T: Topology {
    case wall(edge: T.Edge)
    case passage(edge: T.Edge)
}
