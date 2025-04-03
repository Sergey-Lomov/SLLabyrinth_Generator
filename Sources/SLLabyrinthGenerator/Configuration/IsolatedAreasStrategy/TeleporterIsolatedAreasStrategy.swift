//
//  TeleporterIsolatedAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 31.03.2025.
//

import Foundation

final class TeleporterIsolatedAreasStrategy<T: Topology>: IsolatedAreasStrategy<T> {
    typealias Direction = IsolatedAreaIssue<T>.Direction

    var allowOneway: Bool
    private let restrictionsProvider = "teleporter_merge"

    init(allowOneway: Bool) {
        self.allowOneway = allowOneway
    }

    override func handle(issue: IsolatedAreaIssue<T>, generator: Generator) -> Bool {
        let oneway = allowOneway ? Bool.random() : false

        var innerPoints = issue.area.graph.points.toSet()
        var outerPoints = generator.isolatedAreas.vertices.flatMap {
            $0 == issue.area ? [] : $0.graph.points
        }.toSet()

        while !innerPoints.isEmpty && !outerPoints.isEmpty {
            guard let inner = innerPoints.randomElement() else { continue }
            guard let outer = outerPoints.randomElement() else { continue }
            let from = issue.direction == .income ? outer : inner
            let to = issue.direction == .income ? inner : outer
            let result = tryToRegenerate(from: from, to: to, oneway: oneway, generator: generator)

            switch result {
            case .success:
                return handleSuccessRegeneration(
                    from: from,
                    to: to,
                    oneway: oneway,
                    areas: generator.isolatedAreas
                )
            case .fail(let point):
                if inner == point {
                    innerPoints.remove(point)
                } else {
                    outerPoints.remove(point)
                }
            }

        }

        return false
    }

    private func tryToRegenerate(
        from: Point,
        to: Point,
        oneway: Bool,
        generator: Generator
    ) -> LabyrinthGenerator<T>.FieldRegenerationResult {
        let fromType: TeleporterType = oneway ? .sender : .bidirectional
        let toType: TeleporterType = oneway ? .receiver : .bidirectional
        let fromRestriction = TeleporterRestriction<T>(target: to, types: [fromType])
        let toRestriction = TeleporterRestriction<T>(target: from, types: [toType])
        let restrictions = [
            from: [fromRestriction],
            to: [toRestriction]
        ]

        return generator.regenerate(
            points: [from, to],
            restrictions: restrictions,
            restrictionsProvider: restrictionsProvider
        )
    }

    private func handleSuccessRegeneration(
        from: Point,
        to: Point,
        oneway: Bool,
        areas: AreasGraph<T>
    ) -> Bool {
        let fromArea = areas.firstVertexContains(from)
        let toArea = areas.firstVertexContains(to)
        guard let fromArea = fromArea, let toArea = toArea else {
            return false
        }

        let fromPatch = fromArea.graph.embedVertex(atPoint: from)
        let toPatch = toArea.graph.embedVertex(atPoint: to)
        guard let fromVertex = fromPatch.addedVertices.first,
              let toVertex = toPatch.addedVertices.first else {
            return false
        }

        let points = [from, to]
        let pathsEdge = PathsGraphEdge<T>(
            points: points,
            from: fromVertex,
            to: toVertex,
            category: PathsEdgeCategory.teleporter
        )
        let areasEdge = AreasGraphEdge(pathsEdge: pathsEdge, from: fromArea, to: toArea)
        areas.appendEdge(areasEdge)

        if !oneway {
            let backPathsEdge = pathsEdge.reversed()
            let backAreasEdge = AreasGraphEdge(pathsEdge: backPathsEdge, from: toArea, to: fromArea)
            areas.appendEdge(backAreasEdge)
        }

        areas.groupFirstMuttuallyReachable(from: areasEdge)

        return true
    }
}
