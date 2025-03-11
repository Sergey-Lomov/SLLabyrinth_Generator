//
//  Dictionary+Extensions.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

import Foundation

extension Dictionary {
    mutating func append<T>(key: Key, arrayValue: T) where Value == Array<T> {
        self[key, default: []].append(arrayValue)
    }

    mutating func remove<T>(key: Key, arrayValue: T) where Value == Array<T>, T: Equatable {
        self[key]?.removeAll { $0 == arrayValue }
    }
}
