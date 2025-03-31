//
//  AvailableElementsRestriction.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 23.03.2025.
//

import Foundation

final class AvailableElementsRestriction: NodeRestriction {
    var categories: [String] = []
    var allowUncategorized: Bool = true

    init(category: String) {
        self.categories = [category]
    }

    init(categories: [String]) {
        self.categories = categories
    }

    init(type: any CategorizedSuperposition.Type) {
        self.categories = [type.category]
    }

    init(types: [any CategorizedSuperposition.Type]) {
        self.categories = types.map { $0.category}
    }

    func validateElement<T>(_ element: T) -> Bool where T : ElementSuperposition {
        guard let categorized = element as? CategorizedSuperposition else {
            return allowUncategorized
        }
        let category = type(of: categorized).category
        return categories.contains(category)
    }
}
