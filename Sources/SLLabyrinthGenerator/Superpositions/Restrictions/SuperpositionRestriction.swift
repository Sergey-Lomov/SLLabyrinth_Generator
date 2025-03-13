//
//  SuperpositionRestriction.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 12.03.2025.
//

import Foundation

public protocol SuperpositionRestriction {}

public struct AppliedRestriction {
    let restriction: any SuperpositionRestriction
    let provider: String
}
