//
//  SLLabyrinthGenerator.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 03.03.2025.
//

import Foundation

enum GenerationStep {
    case collapse, paths, isolated, cycles
}

struct GeneratorState<T: Topology> {
    let field: T.Field
    let superpositions: Dictionary<T.Point, T.Superposition>
    let affectedArea: Dictionary<T.Field.Element, [T.Superposition]>

    let pathsGraph: PathsGraph<T>
    let filteredGraph: PathsGraph<T>
    let cyclesAreas: [PathsGraphArea<T>]
    let isolatedAreas: AreasGraph<T>
}

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

    // Debug mode
    private var debugMode: Bool = false
    private var savedStates: Dictionary<GenerationStep, GeneratorState<T>> = [:]

    enum FieldRegenerationResult {
        case success
        case fail(point: Point)

        var isSuccess: Bool {
            switch self {
            case .success: return true
            default: return false
            }
        }
    }

    init(configuration: GeneratorConfiguration<T>) {
        self.configuration = configuration
        self.field = Field(size: configuration.size)
    }

    @discardableResult
    func generateLabyrinth(debugMode: Bool = false) -> TimeLog {
        let timeLog = TimeLog()
        self.debugMode = debugMode

        field = Field(size: configuration.size)
        executeStep(.collapse, log: timeLog)
        executeStep(.paths, log: timeLog)
//        executeStep(.isolated, log: timeLog)
//        executeStep(.cycles, log: timeLog)

        return timeLog
    }

    func executeStep(_ step: GenerationStep, log: TimeLog = TimeLog()) {
        switch step {
        case .collapse:
            log("Collapse field") { collapseField(log: $0) }
        case .paths:
            log("Calculate paths graph") { calculatePathsGraph(log: $0) }
        case .isolated:
            log("Handle isolated areas") { handleIsolatedAreas(log: $0) }
        case .cycles:
            log("Handle cycles areas") { handleCyclesAreas(log: $0) }
        }
    }

    private func saveState(step: GenerationStep) {
        let sups = superpositions.mapValues { $0.copy() }

        let affectedArea = self.affectedArea.mapValues { pointSups in
            pointSups.compactMap { sups[$0.point] }
        }

        savedStates[step] = GeneratorState(
            field: field.copy(),
            superpositions: sups,
            affectedArea: affectedArea,
            pathsGraph: pathsGraph.copy(),
            filteredGraph: filteredGraph.copy(),
            cyclesAreas: cyclesAreas.map { $0.copy() },
            isolatedAreas: isolatedAreas.copy()
        )
    }

    func restoreSavedState(step: GenerationStep) {
        guard let state = savedStates[step] else { return }

        field = state.field.copy()
        superpositions = state.superpositions.mapValues { $0.copy() }
        affectedArea = state.affectedArea.mapValues { pointSups in
            pointSups.compactMap { superpositions[$0.point] }
        }
        pathsGraph = state.pathsGraph.copy()
        filteredGraph = state.filteredGraph.copy()
        cyclesAreas = state.cyclesAreas.map { $0.copy() }
        isolatedAreas = state.isolatedAreas.copy()
    }

    func updatePathsGraph() {
        pathsGraph = FieldAnalyzer.pathsGraph(field)
        pathsGraph.compactizePaths()
    }

    private func setupSuperpositions() {
        let superProvider = configuration.superpositionsProvider
        field.allPoints().forEach {
            let nestsed = superProvider.instantiate()
            superpositions[$0] = Superposition(point: $0, elementsSuperpositions: nestsed)
        }
    }

    private func collapseField(log timeLog: TimeLog) {
        timeLog("Setup superpositions") { setupSuperpositions() }
        timeLog("Apply borders") { applyBorderConstraints() }
        timeLog("Collapse") { collapse() }

        if debugMode {
            timeLog("Save state") { saveState(step: .collapse) }
        }
    }

    private func calculatePathsGraph(log timeLog: TimeLog) {
        timeLog("Calculate") {
            pathsGraph = FieldAnalyzer.pathsGraph(field)
        }

        timeLog("Compactize") {
            pathsGraph.compactizePaths()
        }

        if debugMode {
            timeLog("Save state") { saveState(step: .paths) }
        }
    }

    private func handleCyclesAreas(log timeLog: TimeLog) {
        guard configuration.cycledAreasStrategy != nil else { return }

        timeLog("Calculate cycles areas") { calculateCyclesAreas() }
        timeLog("Resolve cycles areas") { resolveCyclesAreas() }

        if debugMode {
            filteredGraph = pathsGraph.noDeadendsGraph()
            timeLog("Save state") { saveState(step: .cycles) }
        }
    }

    private func handleIsolatedAreas(log timeLog: TimeLog) {
        guard configuration.isolatedAreasStrategy != nil else { return }

        timeLog("Calculate isolated areas") { isolatedAreas = pathsGraph.isolatedAreas() }
        timeLog("Resolve isolated areas") { resolveIsolatedAreas() }

        if debugMode {
            timeLog("Save state") { saveState(step: .isolated) }
        }
    }

    private func applyEmptyFieldConstraints() {
        eachPointEdgeConstraint { point, edge, hasNext in
            if hasNext {
                let element = PassagesElementRestriction<T>.passage(edge: edge)
                return (element, Self.emptyFieldRestrictionId)
            } else {
                let element = PassagesElementRestriction<T>.passage(edge: edge)
                return (element, Self.borderRestrictionId)
            }
        }
    }

    private func applyBorderConstraints() {
        eachPointEdgeConstraint { point, edge, hasNext in
            guard !hasNext else { return nil }
            let restriction = PassagesElementRestriction<T>.wall(edge: edge)
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

        var success = false

        // This variable is part of the zero-entropy avoidance approach, which remains unused in the majority of cases.  Therefore, it is optional to skip calculations whose results are almost never used.
        var absoluteEntropy: Int? = nil
        while (absoluteEntropy ?? 1) > 0 {
            let generated = superposition.waveFunctionCollapse(
                weights: configuration.elementsWeights,
                point: point,
                field: field
            )

            guard let element = generated else {
                print("Issue")
                break
            }

            let zeroEntropyRestriction = setFieldElement(
                at: point,
                element: element,
                entropyContainer: uncollapsed,
                failOnZeroEntropy: true
            )

            if let zeroEntropyRestriction = zeroEntropyRestriction {
                let oldEntropy = absoluteEntropy ?? superposition.absoluteEntropy(point: point, field: field)
                superposition.preventRestriction(zeroEntropyRestriction)
                let newEntropy = superposition.absoluteEntropy(point: point, field: field)
                guard newEntropy < oldEntropy else { break }
                absoluteEntropy = newEntropy
            } else {
                success = true
                break
            }
        }

        if !success { eraseFieldElement(at: point) }
    }

    func eraseFieldElement(at point: Point) {
        guard let element = field.element(at: point) else { return }
        affectedArea[element, default: []]
            .forEach { $0.resetRestrictions(by: element.restrictionId) }
        affectedArea[element] = nil
        field.setElement(at: point, element: nil)
    }

    @discardableResult
    /// Set field element and apply necessary restrictions
    /// If failOnZeroEntropy is true and some restrictions leads to appearing superposition with zero entropy, this restriction will be returned
    func setFieldElement(
        at point: Point,
        element: Element,
        entropyContainer: MinEntropyContainer<T>? = nil,
        failOnZeroEntropy: Bool = false
    ) -> (any ElementRestriction)? {
        field.setElement(at: point, element: element)

        var zeroEntropyRestriction: (any ElementRestriction)?
        let outcomeRestrictions = element.outcomeRestrictions(point: point, field: field)
        for (target, restrictions) in outcomeRestrictions {
            guard let superposition = superpositions[target] else { continue }

            for restriction in restrictions {
                superposition.applyRestriction(
                    restriction,
                    provider: element.restrictionId,
                    onetime: false
                )

                if failOnZeroEntropy && superposition.entropy == 0 {
                    zeroEntropyRestriction = restriction
                    break
                }
            }

            let entropyHandled = entropyContainer?.contains(superposition) ?? false
            if entropyHandled {
                // Update entropy in container more efficiently
                entropyContainer?.updateEntropy(for: superposition)
            }

            affectedArea.append(key: element, arrayValue: superposition)
        }

        if zeroEntropyRestriction != nil {
            eraseFieldElement(at: point)
        }

        return zeroEntropyRestriction
    }

    func regenerate(
        points: [Point],
        restrictions: Dictionary<Point, [any SuperpositionRestriction]> = [:],
        onetime: Bool = true,
        restrictionsProvider: String = UIDProvider.nextString()
    ) -> FieldRegenerationResult {
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

        let result = regenerate(at: points)

        if result.isSuccess {
            FieldAnalyzer.updatePaths(pathsGraph, at: points, field: field)
        } else {
            originalElements.forEach { point, element in
                eraseFieldElement(at: point)
                if let sup = superpositions[point] {
                    sup.resetRestrictions(by: restrictionsProvider)
                }
                setFieldElement(at: point, element: element)
            }
        }

        return result
    }

    private func regenerate(at points: [Point]) -> FieldRegenerationResult {
        let weights = configuration.elementsWeights
        for point in points {
            guard let sup = superpositions[point] else { return .fail(point: point) }

            let element = sup.waveFunctionCollapse(weights: weights, point: point, field: field)
            guard let element = element else { return .fail(point: point) }
            setFieldElement(at: point, element: element)
        }

        return .success
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

    private func resolveIsolatedAreas() {
        guard let strategy = configuration.isolatedAreasStrategy else { return }

        var nextIssue = nextIsolatedAreaIssue()
        while let issue = nextIssue, isolatedAreas.vertices.count > 1 {
            let success = strategy.handle(issue: issue, generator: self)
            if !success {
                isolatedAreas.removeVertex(issue.area)
            }

            nextIssue = nextIsolatedAreaIssue()
            if nextIssue == nil {
                isolatedAreas.groupCycled()
                nextIssue = nextIsolatedAreaIssue()
            }
        }

        strategy.postprocessing(generator: self)
    }

    private func nextIsolatedAreaIssue() -> IsolatedAreaIssue<T>? {
        let area = isolatedAreas.vertices
            .filter { issueDirection($0) != nil }
            .sorted { $0.size < $1.size }
            .first

        guard let area = area, let direction = issueDirection(area) else { return nil }
        return IsolatedAreaIssue(area: area, direction: direction, graph: isolatedAreas)
    }

    private func issueDirection(_ area: PathsGraphArea<T>) -> IsolatedAreaIssue<T>.Direction? {
        let incomes = !isolatedAreas.edges(to: area).isEmpty
        let outgoings = !isolatedAreas.edges(from: area).isEmpty

        if !incomes { return .income }
        if !outgoings { return .outgoing }
        return nil
    }
}
