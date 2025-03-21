//
//  MinEntropyContainer.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 19.03.2025.
//

import Foundation

// A container optimized to find the superposition with minimal entropy.
final class MinEntropyContainer<T: Topology> {
    typealias Superposition = T.Superposition

    private var map: Dictionary<Int, Set<Superposition>> = [:]
    private var minEntropy: Int = .max
    private var count: Int = 0

    var isEmpty: Bool { count == 0 }

    init<C: Collection>(_ superpositions: C) where C.Element == Superposition {
        superpositions.forEach { map.insert(key: $0.entropy, setValue: $0) }
        minEntropy = map.keys.min() ?? .max
        count = superpositions.count
    }

    func append(_ sup: Superposition) {
        let entropy = sup.entropy
        minEntropy = min(minEntropy, entropy)
        map.insert(key: entropy, setValue: sup)
        count += 1
    }

    func remove(_ sup: Superposition) {
        let entropy = sup.entropy
        map.remove(key: entropy, setValue: sup)
        if entropy == minEntropy {
            let minEmpty = map[entropy, default: []].isEmpty
            if minEmpty {
                map[entropy] = nil
                let entropies = map.keys.filter { !(map[$0]?.isEmpty ?? true) }
                minEntropy = entropies.min() ?? .max
            }
        }
        count -= 1
    }

    func contains(_ sup: Superposition) -> Bool {
        map[sup.entropy]?.contains(sup) ?? false
    }

    func getSuperposition() -> Superposition? {
        map[minEntropy]?.first
    }
}
