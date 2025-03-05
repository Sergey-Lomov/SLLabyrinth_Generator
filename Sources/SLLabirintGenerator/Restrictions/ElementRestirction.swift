//
//  ElementRestirction.swift
//  SLLabirintGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

enum ElementRestirction<T> where T: Topology {
    case WallRestriction(edge: T.Edge)
}
