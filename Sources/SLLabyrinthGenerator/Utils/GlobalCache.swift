//
//  GlobalCache.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 28.03.2025.
//

import Foundation

final class GlobalCache {

    private static var values: Dictionary<String, Any> = [:]

    private init() {}

    static func addValue(id: String, value: Any) {
        values[id] = value
    }

    static func getValue<T>(id: String) -> T? {
        return values[id] as? T
    }

    static func getValue<T>(id: String, compute: () -> T) -> T {
        if let value = values[id] as? T { return value }
        let value = compute()
        values[id] = value
        return value
    }
}
