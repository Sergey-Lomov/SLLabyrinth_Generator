//
//  PathsGraphArea.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 11.03.2025.
//

import Foundation

public final class PathsGraphArea<T: Topology> {
    var id = UUID()

    var graph: PathsGraph = PathsGraph<T>()
    var income: [PathsGraphEdge<T>] = []
    var outgoing: [PathsGraphEdge<T>] = []
}
