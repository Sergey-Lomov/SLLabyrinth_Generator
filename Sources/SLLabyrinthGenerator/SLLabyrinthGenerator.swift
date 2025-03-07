//
//  SLLabyrinthGenerator.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 03.03.2025.
//

public func generateLabrinth() {
    let superProvider: SuperpositionsProvider<SquareTopology> = setupSuperProvider()
    let field = SquareField(superpositionsProvider: superProvider)
    field.applyBorderConstraints()

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

private func setupSuperProvider<T>() -> SuperpositionsProvider<T> {
    let superProvider = SuperpositionsProvider<T>()

    superProvider.reqisterSuperposition(DeadendSuperposition<T>.self)
    superProvider.reqisterSuperposition(StraightPathSuperposition<T>.self)
    superProvider.reqisterSuperposition(CornerPathSuperposition<T>.self)
    superProvider.reqisterSuperposition(JunctionSuperposition<T>.self)

    return superProvider
}
