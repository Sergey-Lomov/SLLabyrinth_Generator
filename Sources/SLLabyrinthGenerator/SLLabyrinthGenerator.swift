//
//  SLLabyrinthGenerator.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 03.03.2025.
//

private let borderRestrictionId = "field_border"

public final class LabyrinthGenerator<T: Topology> {
    let configuration: GeneratorConfiguration<T>
    var field: T.Field

    var superpositions: Dictionary<T.Point, T.Superposition> = [:]
    var pathsGraph = PathsGraph<T>()
    var isolatedAreas: [PathsGraphArea<T>] = []

    init(configuration: GeneratorConfiguration<T>) {
        self.configuration = configuration
        self.field = T.Field(size: configuration.size)
    }

    func generateLabyrinth() {
        let superProvider = setupSuperProvider()
        field.allPoints().forEach {
            let nestsed = superProvider.instantiate()
            superpositions[$0] = T.Superposition(point: $0, elementsSuperpositions: nestsed)
        }

        applyBorderConstraints()
        collapse()

        recalculatePathsGraph()
        recalculateIsolatedAreas()
        handleIsolatedAreas()
    }

    func recalculatePathsGraph() {
        pathsGraph = FieldAnalyzer.pathsGraph(field)
        pathsGraph.compactizePaths()
    }

    func recalculateIsolatedAreas() {
        isolatedAreas = pathsGraph.isolatedAreas()
    }

    private func applyBorderConstraints() {
        superpositions.values.forEach { superposition in
            T.Edge.allCases.forEach { edge in
                let next = T.nextPoint(point: superposition.point, edge: edge)
                guard !field.contains(next) else { return }
                let restriction = TopologyBasedElementRestriction<T>.wall(edge: edge)
                guard let restriction = restriction as? T.ElementRestriction else { return }
                superposition.applyRestriction(restriction, provider: borderRestrictionId)
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
                superposition.applyRestriction($0, provider: element.id)
            }
        }
    }

//    private func handleIsolatedAreas() {
//        for area in isolatedAreas {
//            let strategy = configuration.isolatedAreasStrategy
//            _ = strategy.handle(area: area, generator: self)
//        }
//
//        recalculatePathsGraph()
//        recalculateIsolatedAreas()
//    }

    private func handleIsolatedAreas() {
        var failedCount = 0
        while isolatedAreas.count > (1 + failedCount) {
            guard let area = isolatedAreas.randomElement() else { continue }
            let strategy = configuration.isolatedAreasStrategy
            let success = strategy.handle(area: area, generator: self)
            if !success { failedCount += 1}
            recalculatePathsGraph()
            recalculateIsolatedAreas()
        }
    }

//    private func postProcess(_ field: T.Field) {
//        var unprocessed = field.allPoints().shuffled()
//        var failed: [T.Point] = []
//        let flowEdges = T.coverageFlowEdges()
//
//        while !unprocessed.isEmpty {
//            guard let point = unprocessed.last else { continue }
//            unprocessed.removeLast()
//            let success = postProcessPoint(point, atField: field, flowEdges: flowEdges)
//            if !success { failed.append(point) }
//        }
//
//        while !failed.isEmpty {
//            guard let point = failed.last else { continue }
//            failed.removeLastt()
//            let success = postProcessPoint(point, atField: field, flowEdges: flowEdges)
//            if !success {
//                print("Labirynth generator: point postprocessing failed after second try: \(point)")
//            }
//        }
//    }
//
//    private func postProcessPoint(_ point: T.Point, atField field: T.Field, flowEdges: [T.Edge]) -> Bool {
//        return true
//    }

    private func setupSuperProvider() -> SuperpositionsProvider<T> {
        let superProvider = SuperpositionsProvider<T>()

        superProvider.reqisterSuperposition(DeadendSuperposition<T>.self)
        superProvider.reqisterSuperposition(StraightPathSuperposition<T>.self)
        superProvider.reqisterSuperposition(CornerPathSuperposition<T>.self)
        superProvider.reqisterSuperposition(JunctionSuperposition<T>.self)

        return superProvider
    }
}
