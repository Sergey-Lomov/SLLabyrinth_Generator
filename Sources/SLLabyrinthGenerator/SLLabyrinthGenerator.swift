//
//  SLLabyrinthGenerator.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 03.03.2025.
//

open class LabyrinthGenerator<T: Topology> {
    let configuration: GeneratorConfiguration<T>
    var superpositions: Dictionary<T.Point, TopologyBasedNodeSuperposition<T>> = [:]

    init(configuration: GeneratorConfiguration<T>) {
        self.configuration = configuration
    }

    func generateLabyrinth() -> T.Field {
        let superProvider = setupSuperProvider()
        let field = T.Field(size: configuration.size)
        field.allPoints().forEach {
            let nestsed = superProvider.instantiate()
            superpositions[$0] = TopologyBasedNodeSuperposition(point: $0, elementsSuperpositions: nestsed)
        }

        applyBorderConstraints(field)
        collapse(field)

        return field
    }

    private func applyBorderConstraints(_ field: T.Field) {
        superpositions.values.forEach { superposition in
            T.Edge.allCases.forEach { edge in
                let next = T.nextPoint(point: superposition.point, edge: edge)
                if !field.contains(next) {
                    let restriction = TopologyBasedElementRestriction<T>.wall(edge: edge)
                    superposition.applyRestriction(restriction)
                }
            }
        }
    }

    private func collapse(_ field: T.Field) {
        var uncollapsed = Array(superpositions.values)
        while !uncollapsed.isEmpty {
            collapsingStep(uncollapsed: &uncollapsed, field: field)
        }
    }

    private func collapsingStep(uncollapsed: inout Array<TopologyBasedNodeSuperposition<T>>, field: T.Field) {
        uncollapsed = uncollapsed.sorted { $0.entropy < $1.entropy }
        guard let superposition = uncollapsed.first else { return }
        let point = superposition.point
        // TODO: Try to avoid cast
        let solid = Solid<T>() as? T.Field.Element
        let element = superposition.waveFunctionCollapse() ?? solid
        guard let element = element else { return }
        field.setElement(at: point, element: element)

        let restrictions = element.outcomeRestrictions(point: point, field: field)
        restrictions.forEach { point, pointRestrictions in
            guard let superposition = superpositions[point] else { return }
            pointRestrictions.forEach {
                superposition.applyRestriction($0)
            }
        }

        uncollapsed.removeFirst()
    }

    private func postProcess(_ field: T.Field) {
        var unprocessed = field.allPoints().shuffled()
        var failed: [T.Point] = []
        let flowEdges = T.coverageFlowEdges()

        while !unprocessed.isEmpty {
            guard let point = unprocessed.first else { continue }
            unprocessed.removeFirst()
            let success = postProcessPoint(point, atField: field, flowEdges: flowEdges)
            if !success { failed.append(point) }
        }

        while !failed.isEmpty {
            guard let point = failed.first else { continue }
            failed.removeFirst()
            let success = postProcessPoint(point, atField: field, flowEdges: flowEdges)
            if !success {
                print("Labirynth generator: point postprocessing failed after second try: \(point)")
            }
        }
    }

    private func postProcessPoint(_ point: T.Point, atField field: T.Field, flowEdges: [T.Edge]) -> Bool {
        return true
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
