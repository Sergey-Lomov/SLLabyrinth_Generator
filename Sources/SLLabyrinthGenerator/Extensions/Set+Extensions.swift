//
//  Set+Extensions.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 13.03.2025.
//

import Foundation

extension Set: ZeroRepresentable {
    static func getZero() -> Set<Element> {
        Self()
    }
}
