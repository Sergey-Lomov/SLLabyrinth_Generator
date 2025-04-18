//
//  OnewaysMergeIsolatedAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 22.03.2025.
//

import Foundation

final class OnewaysMergeIsolatedAreasStrategy<T: Topology>: IsolatedAreasStrategy<T> {
    typealias Direction = IsolatedAreaIssue<T>.Direction

    private let restrictionsProvider = "oneway_merge"
    private var affectedPoints: Set<Point> = []

    override func handle(issue: IsolatedAreaIssue<T>, generator: Generator) -> Bool {
        tryOnEachMerge(area: issue.area, field: generator.field) {
            tryToRegenerate(
                merge: $0,
                direction: issue.direction,
                area: issue.area,
                graph: issue.graph,
                generator: generator)
        }
    }

    override func postprocessing(generator: Generator) {
        affectedPoints.forEach {
            guard let sup = generator.superpositions[$0] else { return }
            sup.resetRestrictions(by: restrictionsProvider)
        }
    }

    private func tryToRegenerate(
        merge: Merge,
        direction: Direction,
        area: Area,
        graph: Graph,
        generator: Generator
    ) -> Bool {
        let innerDirection: Direction = direction == .income ? .income : .outgoing
        let outerDirection: Direction = direction == .income ? .outgoing : .income

        let restrictions = [
            merge.innerPoint:
                mergeRestrictions(edge: merge.innerEdge, direction: innerDirection),
            merge.outerPoint:
                mergeRestrictions(edge: merge.outerEdge, direction: outerDirection)
        ]
        let result = generator.regenerate(
            points: [merge.innerPoint, merge.outerPoint],
            restrictions: restrictions,
            onetime: false,
            restrictionsProvider: restrictionsProvider
        )

        guard result.isSuccess else { return false }
        return handleSuccessRegeneration(
            merge: merge,
            innerArea: area,
            graph: graph,
            direction: direction,
            generator: generator)
    }

    private func mergeRestrictions(edge: Edge, direction: Direction) -> [any SuperpositionRestriction] {
        let onewayDirection: OnewayDirection = direction == .income ? .income : .outgoing

        return [
            OnlyRequiredOnewaysRestriction(),
            OneWayRestriction<T>(edge: edge, direction: onewayDirection)
        ]
    }

    private func handleSuccessRegeneration(
        merge: Merge,
        innerArea: Area,
        graph: Graph,
        direction: Direction,
        generator: Generator
    ) -> Bool {
        affectedPoints.insert(merge.innerPoint)
        affectedPoints.insert(merge.outerPoint)

        let outerArea = generator.isolatedAreas.firstVertexContains(merge.outerPoint)
        guard let outerArea = outerArea else {
            return false
        }

        let points = [merge.innerPoint, merge.outerPoint]

        let innerPatch = innerArea.graph.embedVertex(at: merge.innerPoint, edgePoints: points)
        let outerPatch = outerArea.graph.embedVertex(at: merge.outerPoint, edgePoints: points)
        guard let innerVertex = innerPatch.addedVertices.first,
              let outerVertex = outerPatch.addedVertices.first else {
            return false
        }

        var pathsEdge = PathsGraphEdge<T>(
            points: points,
            from: innerVertex,
            to: outerVertex,
            type: PathsEdgeType.onewayPasssage
        )
        var areasEdge = AreasGraphEdge(pathsEdge: pathsEdge, from: innerArea, to: outerArea)
        if direction == .income {
            pathsEdge = pathsEdge.reversed()
            areasEdge = areasEdge.reversed()
        }

        graph.appendEdge(areasEdge)
        graph.groupFirstMuttuallyReachable(from: areasEdge)

        return true
    }
}
