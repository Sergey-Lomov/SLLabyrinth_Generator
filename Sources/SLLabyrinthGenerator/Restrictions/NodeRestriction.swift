//
//  NodeRestriction.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

protocol NodeRestriction {
    func validateElement<T>(_ element:T) -> Bool
}
