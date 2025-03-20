//
//  PathsGraphArea.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 11.03.2025.
//

import Foundation

public final class PathsGraphArea<T: Topology>: IdHashable, GraphVertex {
    public var id = UUID().uuidString
    var graph: PathsGraph = PathsGraph<T>()

    var size: Int { graph.points.count }

    init() {}

    convenience init(vertex: PathsGraphVertex<T>) {
        self.init()
        graph.appendVertex(vertex)
    }

    func merge(_ area: PathsGraphArea<T>) {
        graph.merge(area.graph)
//        outgoing = outgoing + area.outgoing
//        income = income + area.income
//        outgoing = outgoing.filter { !graph.vertices.contains($0.to) }
//        income = outgoing.filter { !graph.vertices.contains($0.from) }
    }
}
