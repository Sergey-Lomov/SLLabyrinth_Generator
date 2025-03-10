//
//  Dictionary.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

import Foundation

extension Dictionary {
    mutating func append<T>(key: Key, arrayValue: T) where Value == Array<T> {
        self[key, default: []].append(arrayValue)
    }
}
