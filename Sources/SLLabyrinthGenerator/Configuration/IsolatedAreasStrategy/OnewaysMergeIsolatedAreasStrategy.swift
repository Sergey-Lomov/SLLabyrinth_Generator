//
//  OnewaysMergeIsolatedAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 22.03.2025.
//

import Foundation

private enum Direction {
    case income, outcome
}

final class OnewaysMergeIsolatedAreasStrategy<T: Topology>: IsolatedAreasStrategy<T> {
    override func handle(area: Area, graph: Graph, generator: Generator) -> Bool {
        let incomeRequired = graph.edges(to: area).count == 0
        let outcomeRequired = graph.edges(from: area).count == 0

        if incomeRequired {
            let success = tryToAdd(.income, area: area, graph: graph, generator: generator)
            if !success { return false }
        }

        if outcomeRequired {
            let success = tryToAdd(.outcome, area: area, graph: graph, generator: generator)
            if !success { return false }
        }

        return true
    }

    private func tryToAdd(_ direction: Direction, area: Area, graph: Graph, generator: Generator) -> Bool {
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
        direction: Direction,
        area: Area,
        graph: Graph,
        generator: Generator) -> Bool {
        let restrictions = restrictionFor(merge, direction: direction)
        let success = generator.regenerate(
            points: [merge.innerPoint, merge.outerPoint],
            restrictions: restrictions,
            onetime: false,
            restrictionsProvider: merge.id
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

    private func restrictionFor(_ merge: Merge, direction: Direction) -> Dictionary<Point, [any SuperpositionRestriction]> {
        switch direction {
        case .income:
            return [
                merge.outerPoint: restrictionsFor(edge: merge.outerEdge)
            ]
        case .outcome:
            return [
                merge.innerPoint: restrictionsFor(edge: merge.innerEdge)
            ]
        }
    }

    private func restrictionsFor(edge: Edge) -> [any SuperpositionRestriction] {
        let edgesRestrictions = Edge.allCases.map {
            if $0 == edge {
                return OneWayRestriction<T>(edge: $0, type: .required)
            } else {
                return OneWayRestriction<T>(edge: $0, type: .locked)
            }
        }

        let typeRestrictions = AvailableElementsRestriction(type: OneWayHolderSuperposition<T>.self)
        return typeRestrictions + edgesRestrictions
    }

    private func handleSuccessRegeneration(
        merge: Merge,
        innerArea: Area,
        graph: Graph,
        direction: Direction,
        generator: Generator
    ) -> Bool {
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
//        graph.groupFirstMuttuallyReachable(from: areasEdge)

        return true
    }
}
