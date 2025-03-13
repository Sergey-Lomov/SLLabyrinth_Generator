//
//  PathsGraphArea.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 11.03.2025.
//

import Foundation

public final class PathsGraphArea<T: Topology>: IdEquatable {
    var id = UUID()

    var graph: PathsGraph = PathsGraph<T>()
    var income: [PathsGraphEdge<T>] = []
    var outgoing: [PathsGraphEdge<T>] = []

    var size: Int { graph.points.count }

    func merge(_ area: PathsGraphArea<T>) {
        graph.merge(area.graph)
        outgoing = outgoing + area.outgoing
        income = income + area.income
        outgoing = outgoing.filter { !graph.vertices.contains($0.to) }
        income = outgoing.filter { !graph.vertices.contains($0.from) }
    }
}
