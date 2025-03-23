//
//  NodeRestriction.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

public protocol NodeRestriction: SuperpositionRestriction {
    func validateElement<T: ElementSuperposition>(_ element: T) -> Bool
}
