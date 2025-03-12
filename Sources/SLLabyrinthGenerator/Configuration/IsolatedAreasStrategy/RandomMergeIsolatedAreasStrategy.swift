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
    override var recalculation: RecalcualtionLevel { .paths }

    override func handle(area: PathsGraphArea<T>, generator: LabyrinthGenerator<T>) -> Bool {
        let points = area.graph.points
        let field = generator.field
        var unhandled = points
            .reduce(into: [MergeData<T>]()) { acc, point in
                for edge in T.Edge.allCases {
                    let next = T.nextPoint(point: point, edge: edge)
                    guard field.contains(next), !points.contains(next) else { continue }
                    let edge2 = T.adaptToNextPoint(edge)
                    let merge = MergeData<T>(point1: point, edge1: edge, point2: next, edge2: edge2)
                    acc.append(merge)
                }
            }
            .shuffled()

        while !unhandled.isEmpty {
            guard let merge = unhandled.last else { continue }
            if tryToMerge(merge, generator: generator) {
                return true
            }
            unhandled.removeLast()
        }

        return false
    }

    private func tryToMerge(_ merge: MergeData<T>, generator: LabyrinthGenerator<T>) -> Bool {
        guard let super1 = generator.superpositions[merge.point1],
              let super2 = generator.superpositions[merge.point2],
              let element1 = generator.field.element(at: merge.point1),
              let element2 = generator.field.element(at: merge.point2) else {
            return false
        }

        let initialRestrictions1 = super1.resetRestrictions()
        let initialRestrictions2 = super2.resetRestrictions()

        var newRestrictions1 = initialRestrictions1
            .filter { $0.provider != element1.id && $0.provider != element2.id }
        var newRestrictions2 = initialRestrictions2
            .filter { $0.provider != element1.id && $0.provider != element2.id }

        let passage1 = TopologyBasedElementRestriction<T>.passage(edge: merge.edge1)
        let passage2 = TopologyBasedElementRestriction<T>.passage(edge: merge.edge2)
        let appliedPassage1 = AppliedRestriction(restriction: passage1, provider: merge.id)
        let appliedPassage2 = AppliedRestriction(restriction: passage2, provider: merge.id)
        newRestrictions1.append(appliedPassage1)
        newRestrictions2.append(appliedPassage2)

        newRestrictions1.forEach { super1.applyRestriction($0) }
        newRestrictions2.forEach { super2.applyRestriction($0) }

        if let newElement1 = super1.waveFunctionCollapse(),
           let newElement2 = super2.waveFunctionCollapse() {
            generator.setFieldElement(at: merge.point1, element: newElement1)
            generator.setFieldElement(at: merge.point2, element: newElement2)
            return true
        } else {
            _ = super1.resetRestrictions()
            _ = super2.resetRestrictions()
            initialRestrictions1.forEach { super1.applyRestriction($0) }
            initialRestrictions2.forEach { super2.applyRestriction($0) }
            return false
        }

    }
}
