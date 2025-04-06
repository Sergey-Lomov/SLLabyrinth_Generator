//
//  AvailableElementsRestriction.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 23.03.2025.
//

import Foundation

enum ElementsAvailabilityRestrictionType {
    case allowing, denying
}

final class ElementsAvailabilityRestriction: NodeRestriction {
    var type: ElementsAvailabilityRestrictionType
    var categories: [String] = []
    var allowUncategorized: Bool = true

    init(type: ElementsAvailabilityRestrictionType, category: String) {
        self.categories = [category]
        self.type = type
    }

    init(type: ElementsAvailabilityRestrictionType,categories: [String]) {
        self.categories = categories
        self.type = type
    }

    func validateElement<T>(_ element: T) -> Bool where T : ElementSuperposition {
        guard let categorized = element as? CategorizedSuperposition else {
            return allowUncategorized
        }
        let category = Swift.type(of: categorized).category

        switch type {
        case .allowing:
            return categories.contains(category)
        case .denying:
            return !categories.contains(category)
        }
    }
}
