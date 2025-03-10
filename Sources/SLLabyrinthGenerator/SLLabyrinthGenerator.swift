//
//  SLLabyrinthGenerator.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 03.03.2025.
//

open class LabyrinthGenerator {
    let configuration: GeneratorConfiguration

    init(configuration: GeneratorConfiguration) {
        self.configuration = configuration
    }

    func generateLabyrinth() -> SquareField {
        let superProvider: SuperpositionsProvider<SquareTopology> = setupSuperProvider()
        let field = SquareField(superpositionsProvider: superProvider)
        field.applyBorderConstraints()

        collapse(field)

        return field
    }

    private func collapse<T: Topology>(_ field: Field<T>) {
        var uncollapsed = field.allSuperpositions()
        while !uncollapsed.isEmpty {
            collapsingStep(uncollapsed: &uncollapsed, field: field)
        }
    }

    private func collapsingStep<T: Topology>(
        uncollapsed: inout Array<NodeSuperposition<T>>,
        field: Field<T>
    ) {
        uncollapsed = uncollapsed.sorted { $0.entropy < $1.entropy }
        guard let superposition = uncollapsed.first else { return }
        let point = superposition.point
        let element = superposition.waveFunctionCollapse() ?? Solid<T>()
        field.nodeAt(point)?.element = element

        let restrictions = element.outcomeRestrictions(point: point, field: field)
        restrictions.forEach { point, pointRestrictions in
            guard let superposition = field.superpositionAt(point) else { return }
            pointRestrictions.forEach {
                superposition.applyRestriction($0)
            }
        }

        uncollapsed.removeFirst()
    }

    private func postProcess<T: Topology>(_ field: Field<T>) {
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

    private func postProcessPoint<T: Topology>(
        _ point: T.Point,
        atField field: Field<T>,
        flowEdges: [T.Edge]
    ) -> Bool {
        return true
    }

    private func setupSuperProvider<T>() -> SuperpositionsProvider<T> {
        let superProvider = SuperpositionsProvider<T>()

        superProvider.reqisterSuperposition(DeadendSuperposition<T>.self)
        superProvider.reqisterSuperposition(StraightPathSuperposition<T>.self)
        superProvider.reqisterSuperposition(CornerPathSuperposition<T>.self)
        superProvider.reqisterSuperposition(JunctionSuperposition<T>.self)

        return superProvider
    }
}
