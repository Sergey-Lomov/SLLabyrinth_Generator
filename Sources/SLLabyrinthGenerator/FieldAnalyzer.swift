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
        var unhandled = field.allPoints()
        let graph = Graph()

        while !unhandled.isEmpty {
            // TODO: Try to use first instead random to optmize speed
            guard let point = unhandled.randomElement() else { continue }
            unhandled.remove(point)
            guard let element = field.element(at: point), element.isVisitable else {
                continue
            }
            handleConnectionsVertices(element: element, point: point, graph: graph)
        }

        field.allPoints().forEach() {
            guard let element = field.element(at: $0), element.isVisitable else { return }
            handleConnectionsEdges(element: element, point: $0, graph: graph) {
                field.contains($0.point)
            }
        }

        return graph
    }

    static func updatePaths(_ graph: Graph, at points: [Point], field: Field) {
        var connectedVertices: Set<PathsGraphVertex<T>> = []

        for point in points {
            let edges = graph.edges(of: point)
            let nearest = edges.flatMap { edge in
                edge.points.enumerated().compactMap { index, edge_point in
                    let next = edge.points[safe: index + 1]
                    let previous = edge.points[safe: index - 1]
                    return next == point || previous == point ? edge_point : nil
                }
            }.toSet()

            nearest.forEach {
                let estimatedEdgePoints = [point, $0]
                let patch = graph.embedVertex(at: $0, edgePoints: estimatedEdgePoints)
                connectedVertices.formUnion(patch.addedVertices)
            }

            let oldVertices = graph.vertices(of: point)
            oldVertices.forEach { graph.removeVertex($0) }
            let oldEdges = graph.edges(of: point)
            oldEdges.forEach { graph.removeEdge($0) }
        }

        for point in points {
            guard let new = field.element(at: point) else { continue }
            handleConnectionsVertices(element: new, point: point, graph: graph)
        }

        for point in points {
            guard let new = field.element(at: point) else { continue }
            handleConnectionsEdges(element: new, point: point, graph: graph) {
                field.contains($0.point)
            }
        }

        connectedVertices.forEach { vertex in
            guard let element = field.element(at: vertex.point) else { return }
            handleConnectionsEdges(element: element, point: vertex.point, graph: graph) {
                points.contains($0.point)
            }
        }

        connectedVertices.forEach { graph.compactize(vertex: $0) }
        graph.vertices
            .filter { points.contains($0.point) }
            .forEach { graph.compactize(vertex: $0) }
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
//            let existVertex = graph.vertices(of: point)
//                .first { $0.id == group.id }
//            if existVertex == nil {
//                let vertex = PathsGraphVertex<T>(id: group.id, point: point, edgePointsValidator: group.validator)
//                graph.appendVertex(vertex)
//            }

            group.connections
                .filter { validator($0) }
                .forEach {
                    let points = [point, $0.point]
                    graph.appendEdge(points: points, type: $0.type)
                }
        }
    }
}
