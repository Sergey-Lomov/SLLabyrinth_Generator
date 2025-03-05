//
//  File.swift
//  SLLabirinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

protocol LabirinthElementFactory {
    func elements<T: Topology>() -> [LabirinthElement<T>]
}

final class ElementFactoriesManager {
    @MainActor static let shared = ElementFactoriesManager()

    private var factories: Array<LabirinthElementFactory> = []

    private init() {}

    func add(_ factory: LabirinthElementFactory) {
        factories.append(factory)
    }

    func getElements<T>() -> Array<LabirinthElement<T>> {
        var result: Array<LabirinthElement<T>> = []
        factories.forEach {
            result.append(contentsOf: $0.elements())
        }
        return result
    }
}
