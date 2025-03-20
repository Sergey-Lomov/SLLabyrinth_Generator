//
//  BinomialCoefficient.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 20.03.2025.
//

import Foundation

// Chached calculations for binomial coefficient
final class BinomialCoefficient {
    private struct Params: Hashable {
        let n: Int
        let m: Int
    }

    private static var cache: Dictionary<Params, Int> = [:]

    static func calculate(n: Int, m: Int) -> Int {
        guard n >= 0, m >= n else { return 0 }
        let params = Params(n: n, m: m)
        if let cached = cache[params] { return cached }

        var result = 1
        for i in 0..<n {
            result *= (m - i) / (i + 1)
        }

        cache[params] = result
        return result
    }
}
