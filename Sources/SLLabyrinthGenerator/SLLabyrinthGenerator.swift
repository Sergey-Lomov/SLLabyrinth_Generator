//
//  SLLabyrinthGenerator.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 03.03.2025.
//

import Foundation

private let borderRestrictionId = "field_border"

public final class LabyrinthGenerator<T: Topology> {
    let configuration: GeneratorConfiguration<T>
    var field: T.Field

    var superpositions: Dictionary<T.Point, T.Superposition> = [:]
    var pathsGraph = PathsGraph<T>()
    var filteredGraph = PathsGraph<T>()
    var cyclesAreas: [PathsGraphArea<T>] = []
    var isolatedAreas: [PathsGraphArea<T>] = []

    // TODO: Remove testing code
    var savedField: T.Field?
    var savedSuperpositions: Dictionary<T.Point, T.Superposition> = [:]

    private var timeLog = TimeLog()

    init(configuration: GeneratorConfiguration<T>) {
        self.configuration = configuration
        self.field = T.Field(size: configuration.size)
    }

    func generateLabyrinth() -> TimeLog {
        timeLog = TimeLog()

        timeLog("Collapse field") {
            timeLog("Setup superpositions") { setupSuperpositions() }
            timeLog("Apply borders") { applyBorderConstraints() }
            timeLog("Collapse") { collapse() }
        }

        timeLog("Calculate paths graph") { calculatePathsGraph() }
        timeLog("Handle isolated areas") { handleIsolatedAreas() }

        savedField = field.copy()
        let pairs = superpositions.map { ($0, T.Superposition(superposition: $1)) }
        savedSuperpositions = Dictionary(uniqueKeysWithValues: pairs)

        timeLog("Handle cycles areas") { handleCyclesAreas() }

        return timeLog
    }

    func restoreSaved() {
        guard let savedField = savedField else { return }
        field = savedField.copy()
        let pairs = savedSuperpositions.map { ($0, T.Superposition(superposition: $1)) }
        superpositions = Dictionary(uniqueKeysWithValues: pairs)
    }

    private func setupSuperpositions() {
        let superProvider = setupSuperProvider()
        field.allPoints().forEach {
            let nestsed = superProvider.instantiate()
            superpositions[$0] = T.Superposition(point: $0, elementsSuperpositions: nestsed)
        }
    }

    func calculatePathsGraph() {
        pathsGraph = FieldAnalyzer.pathsGraph(field)
        pathsGraph.compactizePaths()
    }

    private func applyEmptyFieldConstraints() {
        eachPointEdgeConstraint { point, edge, hasNext in
            if hasNext {
                return TopologyBasedElementRestriction<T>.passage(edge: edge) as? T.ElementRestriction
            } else {
                return TopologyBasedElementRestriction<T>.wall(edge: edge) as? T.ElementRestriction
            }
        }
    }

    private func applyBorderConstraints() {
        eachPointEdgeConstraint { point, edge, hasNext in
            guard !hasNext else { return nil }
            return TopologyBasedElementRestriction<T>.wall(edge: edge) as? T.ElementRestriction
        }
    }

    private func eachPointEdgeConstraint(
        handler: (T.Point, T.Edge, Bool) -> T.ElementRestriction?
    ) {
        superpositions.values.forEach { superposition in
            T.Edge.allCases.forEach { edge in
                let next = T.nextPoint(point: superposition.point, edge: edge)
                let nextExist = field.contains(next)
                let restriction = handler(superposition.point, edge, nextExist)

                guard let restriction = restriction else { return }
                superposition.applyRestriction(restriction, provider: borderRestrictionId, onetime: false)
            }
        }
    }

    private func collapse() {
        var uncollapsed = Array(superpositions.values)
        while !uncollapsed.isEmpty {
            collapsingStep(uncollapsed: &uncollapsed)
        }
    }

    private func collapsingStep(uncollapsed: inout [T.Superposition]) {
        uncollapsed = uncollapsed.sorted { $0.entropy > $1.entropy }
        guard let superposition = uncollapsed.last else { return }
        let point = superposition.point
        let solid = Solid<T>() as? T.Field.Element
        let element = superposition.waveFunctionCollapse() ?? solid
        guard let element = element else { return }
        setFieldElement(at: point, element: element)

        uncollapsed.removeLast()
    }

    func setFieldElement(at point: T.Point, element: T.Field.Element) {
        field.setElement(at: point, element: element)

        let restrictions = element.outcomeRestrictions(point: point, field: field)
        restrictions.forEach { point, pointRestrictions in
            guard let superposition = superpositions[point] else { return }
            pointRestrictions.forEach {
                superposition.applyRestriction($0, provider: element.id, onetime: false)
            }
        }
    }

    func regenerate(
        points: [T.Point],
        onetimeRestrioctions: Dictionary<T.Point, [T.ElementRestriction]> = [:],
        restrictionsProvider: String = ""
    ) -> Bool {
        let providers = points.compactMap { field.element(at: $0)?.id }

        let supsPairs = superpositions.map { point, sup in
            let copy = T.Superposition(superposition: sup)
            copy.resetRestrictions(by: providers)
            let additional = onetimeRestrioctions[copy.point, default: []]
            copy.applyRestrictions(additional, provider: restrictionsProvider, onetime: true)
            return (point, copy)
        }
        let sups = Dictionary(uniqueKeysWithValues: supsPairs)

        let newElements: [(T.Point, T.Field.Element)] = points.compactMap { point in
            guard let sup = sups[point] else { return nil }
            guard let element = sup.waveFunctionCollapse() else { return nil }
            return (point, element)
        }

        guard newElements.count == points.count else { return false }
        superpositions = sups
        newElements.forEach { setFieldElement(at: $0, element: $1) }

        return true
    }

    private func handleCyclesAreas() {
        guard configuration.cycledAreasStrategy != nil else { return }

        timeLog("Calculate cycles areas") { calculateCyclesAreas() }
        timeLog("Resolve cycles areas") { resolveCyclesAreas() }

        filteredGraph = pathsGraph.noDeadendsGraph()
        filteredGraph.compactizePaths()
    }

    func calculateCyclesAreas() {
        filteredGraph = pathsGraph.noDeadendsGraph()
        filteredGraph.compactizePaths()
        let areasGraph = filteredGraph.toAreasGraph()
        areasGraph.groupCycled()
        cyclesAreas = areasGraph.vertices
            .filter { $0.graph.points.count != 1 }
    }

    func resolveCyclesAreas() {
        guard let strategy = configuration.cycledAreasStrategy else { return }

        cyclesAreas.forEach {
            strategy.handle(area: $0, generator: self)
        }
        type(of: strategy).postprocessing(generator: self)
    }

    private func handleIsolatedAreas() {
        guard configuration.isolatedAreasStrategy != nil else { return }

        timeLog("Calculate isolated areas") {
            isolatedAreas = pathsGraph.isolatedAreas()
        }
        timeLog("Resolve isolated areas") { resolveIsolatedAreas() }
    }

    private func resolveIsolatedAreas() {
        guard let strategy = configuration.isolatedAreasStrategy else { return }

        var failedCount = 0
        while isolatedAreas.count > (1 + failedCount) {
            let sorted = isolatedAreas.sorted { $0.size < $1.size }
            guard let area = sorted.first else { continue }
            let success = strategy.handle(area: area, generator: self)
            if !success { failedCount += 1}
        }
    }

    private func setupSuperProvider() -> SuperpositionsProvider<T> {
        let superProvider = SuperpositionsProvider<T>()

        superProvider.reqisterSuperposition(DeadendSuperposition<T>.self)
        superProvider.reqisterSuperposition(StraightPathSuperposition<T>.self)
        superProvider.reqisterSuperposition(CornerPathSuperposition<T>.self)
        superProvider.reqisterSuperposition(JunctionSuperposition<T>.self)

        return superProvider
    }
}
