//
//  RandomMergeIsolatedAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 12.03.2025.
//

import Foundation

final class RandomMergeIsolatedAreasStrategy<T: Topology>: IsolatedAreasStrategy<T> {

    override func handle(issue: IsolatedAreaIssue<T>, generator: Generator) -> Bool {
        tryOnEachMerge(area: issue.area, field: generator.field) {
            tryToMerge($0, generator: generator)
        }
    }

    private func tryToMerge(_ merge: Merge, generator: Generator) -> Bool {
        let restriction1 = Restriction.passage(edge: merge.innerEdge)
        let restriction2 = Restriction.passage(edge: merge.outerEdge)

        let restrictions = [
            merge.innerPoint : [restriction1],
            merge.outerPoint : [restriction2]
        ]

        let result = generator.regenerate(
            points: [merge.innerPoint, merge.outerPoint],
            restrictions: restrictions,
            restrictionsProvider: "\(merge.id)"
        )

        guard result.isSuccess else { return false }
        return handleSuccessRegeneration(point1: merge.innerPoint, point2: merge.outerPoint, generator: generator)
    }

    private func handleSuccessRegeneration(point1: Point, point2: Point, generator: Generator) -> Bool {
        let area1 = generator.isolatedAreas.firstVertexContains(point1)
        let area2 = generator.isolatedAreas.firstVertexContains(point2)
        guard let area1 = area1, let area2 = area2 else {
            return false
        }

        let edgePoints = [point1, point2]
        let patch1 = area1.graph.embedVertex(at: point1, edgePoints: edgePoints)
        let patch2 = area2.graph.embedVertex(at: point2, edgePoints: edgePoints)
        guard let vertex1 = patch1.addedVertices.first,
              let vertex2 = patch2.addedVertices.first else {
            return false
        }

        let edge1_2 = PathsGraphEdge<T>(points: edgePoints, from: vertex1, to: vertex2)
        let edge2_1 = edge1_2.reversed()
        let areasEdge1_2 = AreasGraphEdge(pathsEdge: edge1_2, from: area1, to: area2)
        let areasEdge2_1 = AreasGraphEdge(pathsEdge: edge2_1, from: area2, to: area1)

        generator.isolatedAreas.appendEdge(areasEdge1_2)
        generator.isolatedAreas.appendEdge(areasEdge2_1)
        generator.isolatedAreas.groupFirstMuttuallyReachable(from: areasEdge1_2)

        return true
    }
}
