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

    var edgeCuttingStrategies: Dictionary<PathsEdgeType, EdgeCuttingStrategy<T>> = [:]
    var defaultEdgeCuttingStrategy = IterativeEdgeCuttingStrategy<T>()

    let superpositionsProvider = {
        let provider = SuperpositionsProvider<T>()
        provider.reqisterSuperposition(DeadendSuperposition<T>.self)
        provider.reqisterSuperposition(StraightPathSuperposition<T>.self)
        provider.reqisterSuperposition(CornerPathSuperposition<T>.self)
        provider.reqisterSuperposition(JunctionSuperposition<T>.self)
        return provider
    }()

    func edgeCuttingStrategy(type: PathsEdgeType) -> EdgeCuttingStrategy<T> {
        return edgeCuttingStrategies[type] ?? defaultEdgeCuttingStrategy
    }

    func setWeigth(_ superposition: any CategorizedSuperposition.Type, weight: Float) {
        elementsWeights.setWeigth(superposition, weight: weight)
    }

    static func basic(size: T.Field.Size) -> GeneratorConfiguration<T> {
        var config = GeneratorConfiguration(size: size)
        config.isolatedAreasStrategy = RandomMergeIsolatedAreasStrategy()
        config.cycledAreasStrategy = MinLengthCycledAreasStrategy(minLength: 25)
        return config
    }
}
