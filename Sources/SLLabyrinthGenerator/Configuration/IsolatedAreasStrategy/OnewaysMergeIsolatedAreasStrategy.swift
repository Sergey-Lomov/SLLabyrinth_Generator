//
//  OnewaysMergeIsolatedAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 22.03.2025.
//

import Foundation

final class OnewaysMergeIsolatedAreasStrategy<T: Topology>: IsolatedAreasStrategy<T> {
    private let restrictionsProvider = "oneway_merge"
    private var affectedPoints: Set<Point> = []

    override func handle(area: Area, graph: Graph, generator: Generator) -> Bool {
        let incomeRequired = graph.edges(to: area).count == 0
        let outcomeRequired = graph.edges(from: area).count == 0

        if incomeRequired {
            let success = tryToAdd(.income, area: area, graph: graph, generator: generator)
            if !success { return false }
        }

        if outcomeRequired {
            let success = tryToAdd(.outgoing, area: area, graph: graph, generator: generator)
            if !success { return false }
        }

        return true
    }

    override func postprocessing(generator: Generator) {
        affectedPoints.forEach {
            guard let sup = generator.superpositions[$0] else { return }
            sup.resetRestrictions(by: restrictionsProvider)
        }
    }

    private func tryToAdd(_ direction: OnewayDirection, area: Area, graph: Graph, generator: Generator) -> Bool {
        tryOnEachMerge(area: area, field: generator.field) {
            tryToRegenerate(
                merge: $0,
                direction: direction,
                area: area,
                graph: graph,
                generator: generator)
        }
    }

    private func tryToRegenerate(
        merge: Merge,
        direction: OnewayDirection,
        area: Area,
        graph: Graph,
        generator: Generator
    ) -> Bool {
        let innerDirection: OnewayDirection = direction == .income ? .income : .outgoing
        let outerDirection: OnewayDirection = direction == .income ? .outgoing : .income

        let restrictions = [
            merge.innerPoint:
                mergeRestrictions(edge: merge.innerEdge, direction: innerDirection),
            merge.outerPoint:
                mergeRestrictions(edge: merge.outerEdge, direction: outerDirection)
        ]
        let success = generator.regenerate(
            points: [merge.innerPoint, merge.outerPoint],
            restrictions: restrictions,
            onetime: false,
            restrictionsProvider: restrictionsProvider
        )

        if success {
            return handleSuccessRegeneration(
                merge: merge,
                innerArea: area,
                graph: graph,
                direction: direction,
                generator: generator)
        } else {
            return false
        }
    }

    private func mergeRestrictions(edge: Edge, direction: OnewayDirection) -> [any SuperpositionRestriction] {
        [
            OnlyRequiredOnewaysRestriction(),
            OneWayRestriction<T>(edge: edge, direction: direction)
        ]
    }

    private func handleSuccessRegeneration(
        merge: Merge,
        innerArea: Area,
        graph: Graph,
        direction: OnewayDirection,
        generator: Generator
    ) -> Bool {
        affectedPoints.insert(merge.innerPoint)
        affectedPoints.insert(merge.outerPoint)

        let outerArea = generator.isolatedAreas.firstVertexContains(merge.outerPoint)
        guard let outerArea = outerArea else {
            return false
        }

        let innerPatch = generator.pathsGraph.embedVertex(atPoint: merge.innerPoint)
        let outerPatch = generator.pathsGraph.embedVertex(atPoint: merge.outerPoint)
        innerPatch.apply(on: innerArea.graph)
        outerPatch.apply(on: outerArea.graph)

        guard let innerVertex = innerPatch.addedVertices.first,
              let outerVertex = outerPatch.addedVertices.first else {
            return false
        }

        let points = [merge.innerPoint, merge.outerPoint]
        var pathsEdge = PathsGraphEdge<T>(points: points, from: innerVertex, to: outerVertex)
        var areasEdge = AreasGraphEdge(pathsEdge: pathsEdge, from: innerArea, to: outerArea)
        if direction == .income {
            pathsEdge = pathsEdge.reversed()
            areasEdge = areasEdge.reversed()
        }

        generator.pathsGraph.appendEdge(pathsEdge)
        graph.appendEdge(areasEdge)
        graph.groupFirstMuttuallyReachable(from: areasEdge)

        return true
    }
}
