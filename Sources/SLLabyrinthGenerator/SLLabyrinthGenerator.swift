//
//  SLLabyrinthGenerator.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 03.03.2025.
//

import Foundation

public final class LabyrinthGenerator<T: Topology> {
    typealias Point = T.Point
    typealias Edge = T.Edge
    typealias Field = T.Field
    typealias Element = T.Field.Element
    typealias Superposition = T.Superposition

    private static var borderRestrictionId: String { "field_border" }
    private static var emptyFieldRestrictionId: String { "empty_field" }

    let configuration: GeneratorConfiguration<T>
    var field: Field

    var superpositions: Dictionary<Point, Superposition> = [:]
    private var affectedArea: Dictionary<Element, [Superposition]> = [:]
    var pathsGraph = PathsGraph<T>()
    var filteredGraph = PathsGraph<T>()
    var cyclesAreas: [PathsGraphArea<T>] = []
    var isolatedAreas = AreasGraph<T>()

    // TODO: Remove testing code
    var savedField: Field?
    var savedSuperpositions: Dictionary<Point, Superposition> = [:]

    private var timeLog = TimeLog()

    init(configuration: GeneratorConfiguration<T>) {
        self.configuration = configuration
        self.field = Field(size: configuration.size)
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

//        saveState()

        timeLog("Handle cycles areas") { handleCyclesAreas() }

        return timeLog
    }

    func saveState() {
        savedField = field.copy()
        savedSuperpositions = superpositions
            .map { ($0, Superposition(superposition: $1)) }
            .toDictionary()
    }

    func restoreSavedState() {
        guard let savedField = savedField else { return }
        field = savedField.copy()
        superpositions = savedSuperpositions
            .map { ($0, Superposition(superposition: $1)) }
            .toDictionary()

        calculatePathsGraph()
        filteredGraph = pathsGraph.noDeadendsGraph()
        filteredGraph.compactizePaths()
    }

    private func setupSuperpositions() {
        let superProvider = setupSuperProvider()
        field.allPoints().forEach {
            let nestsed = superProvider.instantiate()
            superpositions[$0] = Superposition(point: $0, elementsSuperpositions: nestsed)
        }
    }

    func calculatePathsGraph() {
        pathsGraph = FieldAnalyzer.pathsGraph(field)
        pathsGraph.compactizePaths()
    }

    private func applyEmptyFieldConstraints() {
        eachPointEdgeConstraint { point, edge, hasNext in
            if hasNext {
                let element = TopologyBasedElementRestriction<T>.passage(edge: edge)
                return (element, Self.emptyFieldRestrictionId)
            } else {
                let element = TopologyBasedElementRestriction<T>.passage(edge: edge)
                return (element, Self.borderRestrictionId)
            }
        }
    }

    private func applyBorderConstraints() {
        eachPointEdgeConstraint { point, edge, hasNext in
            guard !hasNext else { return nil }
            let restriction = TopologyBasedElementRestriction<T>.fieldEdge(edge: edge)
            return (restriction, Self.borderRestrictionId)
        }
    }

    private func eachPointEdgeConstraint(
        handler: (Point, Edge, Bool) -> (any ElementRestriction, String)?
    ) {
        superpositions.values.forEach { superposition in
            Edge.allCases.forEach { edge in
                let next = T.nextPoint(point: superposition.point, edge: edge)
                let nextExist = field.contains(next)
                let restriction = handler(superposition.point, edge, nextExist)

                guard let restriction = restriction else { return }
                superposition.applyRestriction(restriction.0, provider: restriction.1, onetime: false)
            }
        }
    }

    private func collapse() {
        let uncollapsed = MinEntropyContainer<T>(superpositions.values)
        while !uncollapsed.isEmpty {
            collapsingStep(uncollapsed: uncollapsed)
        }
    }

    private func collapsingStep(uncollapsed: MinEntropyContainer<T>) {
        guard let superposition = uncollapsed.getSuperposition() else { return }
        uncollapsed.remove(superposition)
        let point = superposition.point
        let solid = Solid<T>() as? Element
        let generated = superposition.waveFunctionCollapse(weights: configuration.elementsWeights)
        let element = generated ?? solid
        guard let element = element else { return }
        setFieldElement(at: point, element: element, entropyContainer: uncollapsed)
    }

    func eraseFieldElement(at point: Point) {
        guard let element = field.element(at: point) else { return }
        affectedArea[element, default: []]
            .forEach { $0.resetRestrictions(by: element.id) }
        affectedArea[element] = nil
        field.setElement(at: point, element: nil)
    }

    func setFieldElement(
        at point: Point,
        element: Element,
        entropyContainer: MinEntropyContainer<T>? = nil
    ) {
        field.setElement(at: point, element: element)

        let restrictions = element.outcomeRestrictions(point: point, field: field)
        restrictions.forEach { point, pointRestrictions in
            guard let superposition = superpositions[point] else { return }

            let entoryHandled = entropyContainer?.contains(superposition) ?? false
            if entoryHandled {
                entropyContainer?.remove(superposition)
            }

            affectedArea.append(key: element, arrayValue: superposition)
            pointRestrictions.forEach {
                superposition.applyRestriction($0, provider: element.id, onetime: false)
            }

            if entoryHandled {
                entropyContainer?.append(superposition)
            }
        }
    }

    func regenerate(
        points: [Point],
        restrictions: Dictionary<Point, [any SuperpositionRestriction]> = [:],
        onetime: Bool = true,
        restrictionsProvider: String = ""
    ) -> Bool {
        let originalElements: Dictionary<Point, Element> = points
            .compactMap {
                guard let element = field.element(at: $0) else { return nil }
                return ($0, element)
            }
            .toDictionary()
        
        points.forEach { eraseFieldElement(at: $0) }

        restrictions.forEach { point, restrictions in
            guard let sup = superpositions[point] else { return }
            sup.applyRestrictions(restrictions, provider: restrictionsProvider, onetime: onetime)
        }

        let newElements: [(Point, Element)] = points.compactMap { point in
            guard let sup = superpositions[point] else { return nil }
            let element = sup.waveFunctionCollapse(weights: configuration.elementsWeights)
            guard let element = element else { return nil }
            return (point, element)
        }

        let success = newElements.count == points.count
        if success {
            newElements.forEach { setFieldElement(at: $0, element: $1) }
        } else {
            originalElements.forEach {
                if let sup = superpositions[$0] {
                    sup.resetRestrictions(by: restrictionsProvider)
                }
                setFieldElement(at: $0, element: $1)
            }
        }

        return success
    }

    func handleCyclesAreas() {
        guard configuration.cycledAreasStrategy != nil else { return }

        timeLog("Calculate cycles areas") { calculateCyclesAreas() }
        timeLog("Resolve cycles areas") { resolveCyclesAreas() }

        filteredGraph = pathsGraph.noDeadendsGraph()
        filteredGraph.compactizePaths()
    }

    private func calculateCyclesAreas() {
        filteredGraph = pathsGraph.noDeadendsGraph()
        filteredGraph.compactizePaths()
        let areasGraph = filteredGraph.toAreasGraph()
        areasGraph.groupCycled()
        cyclesAreas = areasGraph.vertices
            .filter { $0.graph.points.count != 1 }
    }

    private func resolveCyclesAreas() {
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

        var nextArea = isolatedAreas.vertices
            .sorted { $0.size < $1.size }
            .first

        while let area = nextArea, isolatedAreas.vertices.count > 1 {
            let success = strategy.handle(area: area, graph: isolatedAreas, generator: self )
            if !success {
                isolatedAreas.removeVertex(area)
            }

            nextArea = isolatedAreas.vertices
                .filter {
                    let noIncome = isolatedAreas.edges(to: $0).isEmpty
                    let noOutgoing = isolatedAreas.edges(from: $0).isEmpty
                    return noIncome || noOutgoing
                }
                .sorted { $0.size < $1.size }
                .first
        }

        strategy.postprocessing(generator: self)
        isolatedAreas.groupCycled()
    }

    private func setupSuperProvider() -> SuperpositionsProvider<T> {
        let superProvider = SuperpositionsProvider<T>()

        superProvider.reqisterSuperposition(DeadendSuperposition<T>.self)
        superProvider.reqisterSuperposition(StraightPathSuperposition<T>.self)
        superProvider.reqisterSuperposition(CornerPathSuperposition<T>.self)
        superProvider.reqisterSuperposition(JunctionSuperposition<T>.self)
        superProvider.reqisterSuperposition(OneWayHolderSuperposition<T>.self)

        return superProvider
    }
}
