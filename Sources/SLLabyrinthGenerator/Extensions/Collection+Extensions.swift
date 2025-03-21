//
//  Collection+Extensions.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 06.03.2025.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    func toArray() -> [Element] {
        Array(self)
    }

    func pairs(allowDuplication: Bool = false) -> Array<(Element, Element)> where Element: Comparable {
        return reduce(into: Array<(Element, Element)>()) { arr, element in
            forEach {
                if $0 != element || allowDuplication {
                    let pair = (element, $0)
                    if !arr.containsPair(pair) {
                        arr.append(pair)
                    }
                }
            }
        }
    }

    func combinations() -> Array<Array<Element>> {
        var results: Array<Array<Element>> = []
        let maxIndex = Int(pow(2, Double(count))) - 1

        for i in 1...maxIndex {
            let indexArray = elementsByMask(i)
            results.append(indexArray)
        }

        return results
    }

    func elementsByMask(_ mask: Int) -> [Element] {
        enumerated().compactMap { index, element in
            let selected = mask & (1 << index) > 0
            return selected ? element : nil
        }
    }
}
