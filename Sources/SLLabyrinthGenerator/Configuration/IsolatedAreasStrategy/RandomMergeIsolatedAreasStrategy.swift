//
//  RandomMergeIsolatedAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 12.03.2025.
//

import Foundation

private struct MergeData<T: Topology> {
    let id = "merge_" + UUID().uuidString
    let point1: T.Point
    let edge1: T.Edge
    let point2: T.Point
    let edge2: T.Edge
}

final class RandomMergeIsolatedAreasStrategy<T: Topology>: IsolatedAreasStrategy<T> {
    typealias Element = T.Field.Element
    typealias Point = T.Point
    typealias Restriction = TopologyBasedElementRestriction<T>
    typealias Generator = LabyrinthGenerator<T>

    override func handle(area: PathsGraphArea<T>, generator: LabyrinthGenerator<T>) -> Bool {
        let field = generator.field
        var unhandled = area.graph.points.shuffled()
        while !unhandled.isEmpty {
            guard let point = unhandled.last else { continue }
            if tryToMerge(at: point, field: field, area: area, generator: generator) {
                return true
            }
            unhandled.removeLast()
        }

        return false
    }

    private func tryToMerge(
        at point: Point,
        field: T.Field,
        area: PathsGraphArea<T>,
        generator: Generator
    ) -> Bool {
        let merges = T.Edge.allCases
            .reduce(into: [MergeData<T>]()) { acc, edge in
                let next = T.nextPoint(point: point, edge: edge)
                guard field.contains(next), !area.graph.contains(next) else { return }
                let edge2 = T.adaptToNextPoint(edge)
                let merge = MergeData<T>(point1: point, edge1: edge, point2: next, edge2: edge2)
                acc.append(merge)
            }

        for merge in merges {
            if tryToMerge(merge, generator: generator) {
                return true
            }
        }

        return false
    }

    private func tryToMerge(_ merge: MergeData<T>, generator: Generator) -> Bool {
        let restriction1 = Restriction.passage(edge: merge.edge1)
        let restriction2 = Restriction.passage(edge: merge.edge2)

        let restrictions = [
            merge.point1 : [restriction1],
            merge.point2 : [restriction2]
        ]

        let success = generator.regenerate(
            points: [merge.point1, merge.point2],
            onetimeRestrictions: restrictions,
            restrictionsProvider: merge.id
        )

        if success {
            return handleSuccessRegeneration(point1: merge.point1, point2: merge.point2, generator: generator)
        } else {
            return false
        }
    }

    private func handleSuccessRegeneration(point1: Point, point2: Point, generator: Generator) -> Bool {
        let area1 = generator.isolatedAreas.firstVertexContains(point1)
        let area2 = generator.isolatedAreas.firstVertexContains(point2)
        guard let area1 = area1, let area2 = area2 else {
            return false
        }

        let patch1 = generator.pathsGraph.embedVertex(atPoint: point1)
        let patch2 = generator.pathsGraph.embedVertex(atPoint: point2)
        patch1.apply(on: area1.graph)
        patch2.apply(on: area2.graph)

        guard let vertex1 = patch1.addedVertices.first,
              let vertex2 = patch2.addedVertices.first else {
            return false
        }

        let edge1_2 = PathsGraphEdge<T>(points: [point1, point2], from: vertex1, to: vertex2)
        let edge2_1 = edge1_2.reversed()
        generator.pathsGraph.appendEdge(edge1_2)
        generator.pathsGraph.appendEdge(edge2_1)

        let areasEdge1_2 = AreasGraphEdge(pathsEdge: edge1_2, from: area1, to: area2)
        let areasEdge2_1 = AreasGraphEdge(pathsEdge: edge2_1, from: area2, to: area1)
        generator.isolatedAreas.appendEdge(areasEdge1_2)
        generator.isolatedAreas.appendEdge(areasEdge2_1)
        generator.isolatedAreas.groupFirstMuttuallyReachable(from: areasEdge1_2)

        generator.pathsGraph.compactize(vertex: vertex1)
        generator.pathsGraph.compactize(vertex: vertex2)

        return true
    }
}
