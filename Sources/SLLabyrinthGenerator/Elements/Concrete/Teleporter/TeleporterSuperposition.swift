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
    private var requiredTargets: Set<T.Point> = []
    private var preventedTargets: Set<T.Point> = []

    // Additional option: generate an isolated portal with walls on every edge.
    // This approach should be used only if no valid combination of entrances is available.
    private var isIsolatedAvailable: Bool = true

    override var entropy: Int {
        guard !checkConflicts() else { return 0 }
        return super.entropy * entropyCoefficient
    }

    override func filterInitialPassages(_ variant: [T.Edge]) -> Bool {
        !variant.isEmpty
    }

    override func applySpecificRestriction(_ restriction: any ElementRestriction, at point: Point) -> Bool {
        switch restriction {
        case let restriction as TeleporterCoefficientRestriction:
            entropyCoefficient = restriction.coefficient
            return true
        case let restriction as TeleporterRestriction<T>:
            if let required = restriction.target {
                requiredTargets.insert(required)
            }
            types.formIntersection(restriction.types)
            return true
        default:
            return false
        }
    }

    override func applyConnectionRestriction(_ restriction: ConnectionPreventRestriction<T>, at point: Point) -> Bool {
        preventedTargets.insert(restriction.target)
        return super.applyConnectionRestriction(restriction, at: point)
    }

    override func applyPassagesRestriction(_ restriction: PassagesElementRestriction<T>, at point: PassagesBasedSuperposition<T>.Point) -> Bool {
        let success = super.applyPassagesRestriction(restriction, at: point)
        if case .passage = restriction, success {
            isIsolatedAvailable = false
        }
        return success
    }

    override func resetRestrictions() {
        super.resetRestrictions()
        isIsolatedAvailable = true
        types = TeleporterType.allCases.toSet()
        requiredTargets.removeAll()
        preventedTargets.removeAll()
    }

    override func waveFunctionCollapse(point: Point, field: Field) -> Field.Element? {
        var passages = passagesVariations.randomElement()
        if passages == nil && isIsolatedAvailable {
            passages = []
        }
        guard let passages = passages else { return nil }
        guard let type = types.randomElement() else { return nil }

        let target = target(point: point, field: field)
        guard let target = target else { return nil }

        let teleporter = Teleporter<T>(target: target, type: type, passages: passages)

        // TODO: Time to time generation fails and lead to solid element. This issue should be investigated. Comfortable to reproduce it with big amount of portals.
        return teleporter as? Field.Element
    }

    private func target(point: Point, field: Field) -> Point? {
        guard !checkConflicts() else { return nil }
        if let requiredTarget = requiredTargets.first { return requiredTarget }

        var available = field.undefinedPoints()
        available.remove(point)
        return available.randomElement()
    }

    private func checkConflicts() -> Bool {
        if requiredTargets.count > 1 { return true }
        if !requiredTargets.intersection(preventedTargets).isEmpty { return true }
        return false
    }
}
