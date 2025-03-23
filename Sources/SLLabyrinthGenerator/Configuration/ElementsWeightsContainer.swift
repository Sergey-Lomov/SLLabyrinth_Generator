//
//  ElementsWeightsContainer.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 19.03.2025.
//

import Foundation

public final class ElementsWeightsContainer {
    private let defaultWeigth: Float = 1.0
    private var weights: Dictionary<String, Float> = [:]

    func setWeigth(_ superposition: any CategorizedSuperposition.Type, weight: Float) {
        weights[superposition.category] = weight
    }

    func weight(_ superposition: any ElementSuperposition) -> Float {
        guard let categorized = superposition as? CategorizedSuperposition else { return defaultWeigth }
        let category = type(of: categorized).category
        return weights[category] ?? defaultWeigth
    }

    func weigth(_ type: any LabyrinthElement.Type) -> Float {
        guard let categorized = type as? CategorizedSuperposition.Type else { return defaultWeigth }
        return weights[categorized.category] ?? defaultWeigth
    }
}
