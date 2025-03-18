//
//  AreasGraph.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 15.03.2025.
//

import Foundation

final class AreasGraph<T: Topology>: Graph<AreasGraphEdge<T>> {
    typealias Edge = AreasGraphEdge<T>
    typealias Path = AreasGraphPath<T>

    func groupCycled() {
        var unhandled = Set(edges)
        while !unhandled.isEmpty {
            guard let edge = unhandled.first else { continue }
            unhandled.remove(edge)
            let path = Path(edge: edge)
            groupCycled(path: path, unhandled: &unhandled)
        }
    }

    // If no cycle is found, returns nil. Otherwise, returns the pre-cycle vertex to rollback.
    @discardableResult
    private func groupCycled(path: Path, unhandled: inout Set<Edge>) -> Vertex? {
        guard let vertex = path.to, let lastEdge = path.edges.last else { return nil }

        if lastEdge.from == vertex {
            return handleCycle(path: path, vertex: vertex, unhandled: &unhandled)
        }

        var handledVertexEdges: Set<Edge> = []
        var nextEdge = edges(from: vertex).first
        while nextEdge != nil {
            guard let edge = nextEdge else { continue }
            handledVertexEdges.insert(edge)

            guard !edge.pathsEdge.isReversed(lastEdge.pathsEdge) else {
                nextEdge = Set(edges(from: vertex)).subtracting(handledVertexEdges).first
                continue
            }

            if path.contains(edge.to) {
                return handleCycle(path: path, vertex: edge.to, unhandled: &unhandled)
            } else {
                let edgePath = path.copy(append: edge)
                let rollback = groupCycled(path: edgePath, unhandled: &unhandled)
                if rollback != nil && rollback != vertex { return rollback }
            }

            unhandled.remove(edge)
            nextEdge = Set(edges(from: vertex)).subtracting(handledVertexEdges).first
        }

        return nil
    }

    private func handleCycle(path: Path, vertex: Vertex, unhandled: inout Set<Edge>) -> Vertex? {
        guard let cutted = path.subpath(from: vertex) else { return nil }
        cutted.vertices
            .flatMap { edges(of: $0) }
            .forEach { unhandled.remove($0) }

        let grouped = groupAreas(cutted.vertices)
        edges(of: grouped).forEach { unhandled.insert($0) }
        let cycleIncome = path.edges.first { $0.to == vertex }
        guard let cycleIncome = cycleIncome else { return nil }

        return cycleIncome.from
    }

    private func groupAreas(_ areas: [Vertex]) -> Vertex {
        let grouped = Vertex()
        areas.forEach { grouped.merge($0) }
        appendVertex(grouped)

        areas
            .flatMap { edges(from: $0) }
            .forEach {
                removeEdge($0)
                if areas.contains($0.to) {
                    grouped.graph.appendEdge($0.pathsEdge)
                } else {
                    let edge = Edge(pathsEdge: $0.pathsEdge, from: grouped, to: $0.to)
                    appendEdge(edge)
                }
            }

        areas
            .flatMap { edges(to: $0) }
            .forEach {
                removeEdge($0)
                if areas.contains($0.from) {
                    grouped.graph.appendEdge($0.pathsEdge)
                } else {
                    let edge = Edge(pathsEdge: $0.pathsEdge, from: $0.from, to: grouped)
                    appendEdge(edge)
                }
            }

        return grouped
    }
}
