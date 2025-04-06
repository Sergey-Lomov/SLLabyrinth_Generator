//
//  PassagesElementRestriction.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 05.04.2025.
//

enum PassagesElementRestriction<T: Topology>: ElementRestriction, Equatable {
    case wall(edge: T.Edge)
    case passage(edge: T.Edge)

    var allowUnhandled: Bool { false }
}
