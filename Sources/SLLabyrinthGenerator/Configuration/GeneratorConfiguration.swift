//
//  GeneratorConfiguration.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

public struct GeneratorConfiguration<T: Topology> {
    let size: T.Field.Size
    var isolatedAreasStrategy: IsolatedAreasStrategy<T>? = nil
    var cycledAreasStrategy: CycledAreasStrategy<T>? = nil

    static func basic(size: T.Field.Size) -> GeneratorConfiguration<T> {
        var config = GeneratorConfiguration(size: size)
        config.isolatedAreasStrategy = RandomMergeIsolatedAreasStrategy()
        config.cycledAreasStrategy = MinLengthCycledAreasStrategy(minLength: 15)
        return config
    }
}
