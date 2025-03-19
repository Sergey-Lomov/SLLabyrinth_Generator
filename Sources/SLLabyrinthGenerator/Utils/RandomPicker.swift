//
//  RandomPicker.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 19.03.2025.
//

import Foundation

final class RandomPicker {
    static func weigthed<T, C: Collection>(_ data: C) -> T? where C.Element == (T, Float) {
        guard !data.isEmpty else { return nil }
        let total = data.map({ $1 }).reduce(0, +)
        let random = Float.random(in: 0..<total)

        var acc: Float = 0
        for pair in data {
            acc += pair.1
            if acc > random { return pair.0 }
        }

        return nil
    }
}
