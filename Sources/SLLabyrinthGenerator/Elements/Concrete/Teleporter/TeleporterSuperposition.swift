//
//  TeleporterSuperposition.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 29.03.2025.
//

import Foundation

final class TeleporterSuperposition<T: Topology>: PassagesBasedSuperposition<T>, CategorizedSuperposition {

    static var category: String { "teleporter" }

    private var entropyCoefficient: Int = 1
    private var types = TeleporterType.allCases.toSet()
    private var prefeinedTarget: T.Point?

    override var entropy: Int {
        super.entropy * entropyCoefficient
    }

    override func filterInitialPassages(_ variant: [T.Edge]) -> Bool {
        !variant.isEmpty
    }

    override func applySpecificRestriction(_ restriction: any ElementRestriction) -> Bool {
        switch restriction {
        case let restriction as TeleporterCoefficientRestriction:
            entropyCoefficient = restriction.coefficient
            return true
        case let restriction as TeleporterRestriction<T>:
            prefeinedTarget = restriction.target ?? prefeinedTarget
            types.formIntersection(restriction.types)
            return true
        default:
            return false
        }
    }

    override func resetRestrictions() {
        super.resetRestrictions()
        types = TeleporterType.allCases.toSet()
    }

    override func waveFunctionCollapse(point: Point, field: Field) -> Field.Element? {
        guard let passages = passagesVariations.randomElement() else { return nil }
        guard let type = types.randomElement() else { return nil }

        let target = target(point: point, field: field)
        guard let target = target else { return nil }

        let teleporter = Teleporter<T>(target: target, type: type, passages: passages)
        return teleporter as? Field.Element
    }

    private func target(point: Point, field: Field) -> Point? {
        if prefeinedTarget != nil { return prefeinedTarget }

        var available = field.undefinedPoints()
        available.remove(point)
        return available.randomElement()
    }
}
