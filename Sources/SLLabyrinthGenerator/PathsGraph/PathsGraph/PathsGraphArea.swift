//
//  PathsGraphArea.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 11.03.2025.
//

import Foundation

public final class PathsGraphArea<T: Topology>: IdHashable, GraphVertex {
    public var id = UIDProvider.next()
    var graph = PathsGraph<T>()

    var size: Int { graph.points.count }

    init() {}

    convenience init(area: PathsGraphArea<T>) {
        self.init()
        self.graph = PathsGraph(graph: graph)
    }

    convenience init(vertex: PathsGraphVertex<T>) {
        self.init()
        graph.appendVertex(vertex)
    }

    func merge(_ area: PathsGraphArea<T>) {
        graph.merge(area.graph)
    }

    func copy() -> PathsGraphArea<T> {
        Self(area: self)
    }
}
