//
//  IsolatedAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 12.03.2025.
//

import Foundation

struct IsolatedAreaIssue<T: Topology> {
    enum Direction {
        case income, outgoing
    }

    let area: PathsGraphArea<T>
    let direction: Direction
    let graph: AreasGraph<T>
}

public class IsolatedAreasStrategy<T: Topology> {
    typealias Area = PathsGraphArea<T>
    typealias Graph = AreasGraph<T>
    typealias Generator = LabyrinthGenerator<T>
    typealias Field = T.Field
    typealias Point = T.Point
    typealias Edge = T.Edge
    typealias Restriction = PassagesElementRestriction<T>

    internal struct Merge {
        let id = UIDProvider.next()
        let innerPoint: Point
        let innerEdge: Edge
        let outerPoint: Point
        let outerEdge: Edge
    }

    func handle(issue: IsolatedAreaIssue<T>, generator: Generator) -> Bool {
        return false
    }

    func postprocessing(generator: Generator) {}

    internal func tryOnEachPoint(area: Area, field: Field, _ closure: (Point) -> Bool) -> Bool {
        var unhandled = area.graph.points.shuffled()
        while !unhandled.isEmpty {
            guard let point = unhandled.last else { continue }
            if closure(point) { return true }
            unhandled.removeLast()
        }

        return false
    }

    internal func tryOnEachMerge(area: Area, field: Field, _ closure: (Merge) -> Bool) -> Bool {
        tryOnEachPoint(area: area, field: field) {
            tryMergesAt($0, area: area, field: field, closure)
        }
    }

    private func tryMergesAt(_ point: Point, area: Area, field: Field, _ closure: (Merge) -> Bool) -> Bool {
        let merges = T.Edge.allCases.compactMap {
            mergeAt(point: point, edge: $0, area: area, field: field)
        }
        
        for merge in merges {
            if closure(merge) { return true }
        }

        return false
    }

    private func mergeAt(point: Point, edge: Edge, area: Area, field: Field) -> Merge? {
        let next = T.nextPoint(point: point, edge: edge)
        guard field.contains(next), !area.graph.contains(next) else { return nil }
        let outerEdge = T.adaptToNextPoint(edge)

        return Merge(innerPoint: point, innerEdge: edge, outerPoint: next, outerEdge: outerEdge)
    }
}
