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

    func setWeigth(_ superposition: any WeightableSuperposition.Type, weight: Float) {
        weights[superposition.weigthCategory] = weight
    }

    func weight(_ superposition: any ElementSuperposition) -> Float {
        guard let weightable = superposition as? WeightableSuperposition else { return defaultWeigth }
        let category = type(of: weightable).weigthCategory
        return weights[category] ?? defaultWeigth
    }

    func weigth(_ type: any LabyrinthElement.Type) -> Float {
        guard let weightable = type as? WeightableSuperposition.Type else { return defaultWeigth }
        return weights[weightable.weigthCategory] ?? defaultWeigth
    }
}
