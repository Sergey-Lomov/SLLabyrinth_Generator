//
//  GeneratorConfiguration.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

public struct GeneratorConfiguration<T: Topology> {
    let size: T.Field.Size
    let elementsWeights = ElementsWeightsContainer()
    var isolatedAreasStrategy: IsolatedAreasStrategy<T>? = nil
    var cycledAreasStrategy: CycledAreasStrategy<T>? = nil

    func setWeigth(_ superposition: any WeightableSuperposition.Type, weight: Float) {
        elementsWeights.setWeigth(superposition, weight: weight)
    }

    static func basic(size: T.Field.Size) -> GeneratorConfiguration<T> {
        var config = GeneratorConfiguration(size: size)
        config.isolatedAreasStrategy = RandomMergeIsolatedAreasStrategy()
        config.cycledAreasStrategy = MinLengthCycledAreasStrategy(minLength: 25)
        return config
    }
}
