//
//  Array+Extensions.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

extension Array {
    func oppositePairs() -> Array<(Element, Element)> where Element: TopologyEdge {
        let pairs: [(Element, Element)] = compactMap {
            guard let opposite = $0.opposite() else { return nil }
            return ($0, opposite)
        }

        var unique: [(Element, Element)] = []
        pairs.forEach {
            if !unique.containsPair($0) { unique.append($0) }
        }
        return unique
    }

    func containsPair<T> (_ pair: (T, T)) -> Bool where Element == (T, T), T: Comparable {
        let straight = contains { $0.0 == pair.0 && $0.1 == pair.1 }
        let reversed = contains { $0.0 == pair.1 && $0.1 == pair.0 }
        return straight || reversed
    }

    func removeOppositePairs<T> () -> Array<Element> where Element == (T, T), T: TopologyEdge {
        filter { $0 != $1.opposite() }
    }

    static func + (lhs: Array<Element>, rhs: Element) -> Array<Element> {
        lhs + [rhs]
    }

    static func + (lhs: Element, rhs: Array<Element>) -> Array<Element> {
        [lhs] + rhs
    }
}
