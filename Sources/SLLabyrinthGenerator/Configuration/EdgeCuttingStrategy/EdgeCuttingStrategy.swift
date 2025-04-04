//
//  EdgeCuttingStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 03.04.2025.
//

class EdgeCuttingStrategy<T: Topology> {
    typealias Edge = PathsGraphEdge<T>
    typealias Generator = LabyrinthGenerator<T>

    func tryToCut(_ edge: Edge, generator: Generator, provider: String) -> Bool { false }
}
