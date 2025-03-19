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

    mutating func append<T>(key: Key, setValue: T) where Value == Set<T> {
        self[key, default: []].insert(setValue)
    }

    mutating func remove<T>(key: Key, setValue: T) where Value == Set<T>, T: Equatable {
        self[key]?.remove(setValue)
    }
}
