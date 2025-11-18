//
//  FieldAnalyzer.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 08.03.2025.
//

import Foundation

final class FieldAnalyzer<T: Topology> {
    typealias Field = T.Field
    typealias Point = T.Point
    typealias Graph = PathsGraph<T>

    static func pathsGraph(_ field: Field) -> Graph {
        let graph = Graph()
        graph.usePointsIndexing = true

        let points = field.allPoints()

        points.forEach() {
            guard let element = field.element(at: $0), element.isVisitable else { return }
            handleConnectionsVertices(element: element, point: $0, graph: graph)
        }

        points.forEach() {
            guard let element = field.element(at: $0), element.isVisitable else { return }
            handleConnectionsEdges(element: element, point: $0, graph: graph) {
                field.contains($0.point)
            }
        }

        return graph
    }

    static func updatePaths(_ graph: Graph, at point: Point, field: Field) {
        var affectedVertices: Set<PathsGraphVertex<T>> = []

        let edges = graph.edges(of: point)
        for edge in edges {
            let subedgesPoints = edge
                .splitPoints(at: point, includeSeparator: false)

            for subedgePoints in subedgesPoints {
                if subedgePoints.count > 1 {
                    if let edge = graph.appendEdge(points: subedgePoints, type: edge.type) {
                        affectedVertices.insert(edge.from)
                        affectedVertices.insert(edge.to)
                    }
                } else {
                    if let subedgeFirst = subedgePoints.first {
                        affectedVertices.formUnion(graph.vertices(of: subedgeFirst))
                    }
                }
            }

            graph.removeEdge(edge)
        }

        guard let element = field.element(at: point) else { return }
        handleConnectionsVertices(element: element, point: point, graph: graph)
        handleConnectionsEdges(element: element, point: point, graph: graph) {
            field.contains($0.point)
        }

        affectedVertices
            .map { $0.point }
            .toSet()
            .forEach { affected in
                guard let element = field.element(at: affected) else { return }
                handleConnectionsEdges(element: element, point: affected, graph: graph) {
                    $0.point == point
                }
            }

        affectedVertices.formUnion(graph.vertices(of: point))
        affectedVertices.forEach {
            graph.compactize(vertex: $0)
        }
    }

    static func updatePaths(_ graph: Graph, at points: [Point], field: Field) {
        points.forEach {
            updatePaths(graph, at: $0, field: field)
        }
    }

    private static func handleConnectionsVertices(
        element: Field.Element,
        point: Point,
        graph: Graph
    ) {
        let connnectionGroups = element.connected(point)
        connnectionGroups.forEach { group in
            let existVertex = graph.vertices(of: point)
                .first { $0.type == group.vertexType }
            if existVertex == nil {
                let vertex = PathsGraphVertex<T>(
                    point: point,
                    type: group.vertexType,
                    edgePointsValidator: group.validator
                )
                graph.appendVertex(vertex)
            }
        }
    }

    private static func handleConnectionsEdges(
        element: Field.Element,
        point: Point,
        graph: Graph,
        validator: (ElementsConnection<Point>) -> Bool
    ) {
        let connnectionGroups = element.connected(point)
        connnectionGroups.forEach { group in
            group.connections
                .filter { validator($0) }
                .forEach {
                    let points = [point, $0.point]
                    graph.appendEdge(points: points, type: $0.type)
                }
        }
    }
}
