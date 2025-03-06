//
//  Collection.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 06.03.2025.
//

import Foundation

extension Collection {
    func pairs(allowDuplication: Bool = false) -> Array<(Element, Element)> where Element: Comparable {
        return reduce(into: Array<(Element, Element)>()) { arr, element in
            forEach {
                if $0 != element || allowDuplication {
                    var pair = (element, $0)
                    if !arr.containsPair(pair) {
                        arr.append(pair)
                    }
                }
            }
        }
    }

    func combinations() -> Array<Array<Element>> {
        var results: Array<Array<Element>> = []
        let maxIndex = Int(pow(2, Double(count)))

        for i in 1...maxIndex {
            var indexArray: Array<Element> = []
            enumerated().forEach { index, element in
                if i & (2 << index) > 0 {
                    indexArray.append(element)
                }
            }
            results.append(indexArray)
        }

        return results
    }
}
