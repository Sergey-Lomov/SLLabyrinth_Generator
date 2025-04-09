//
//  UIDProvider.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 08.04.2025.
//

import Foundation

final class UIDProvider {
    private static var current: Int = 0

    static func next() -> Int {
        current += 1
        return current
    }

    static func nextString() -> String { "\(next())" }
}
