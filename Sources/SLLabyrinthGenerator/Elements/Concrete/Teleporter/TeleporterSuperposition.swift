//
//  TeleporterSuperposition.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 29.03.2025.
//

import Foundation

final class TeleporterSuperposition<T: Topology>: PassagesBasedSuperposition<T>, CategorizedSuperposition {

    private struct TargetTypeTuple: Hashable {
        let target: T.Point
        let type: TeleporterType
    }

    static var category: String { "teleporter" }

    private var entropyCoefficient: Int = 1
    private var types = TeleporterType.allCases.toSet()
    private var requiredTargets: Set<T.Point> = []
    private var preventedTargets: Set<T.Point> = []
    private var preventedTargetTypes: Set<TargetTypeTuple> = []

    // Additional option: generate an isolated portal with walls on every edge.
    // This approach should be used only if no valid combination of entrances is available.
    private var isIsolatedAvailable: Bool = true

    override var entropy: Int {
        guard !checkConflicts() else { return 0 }
        let isolatedEntropy = isIsolatedAvailable ? 1 : 0
        let passagesEntropy = max(super.entropy, isolatedEntropy)
        return passagesEntropy * entropyCoefficient
    }

    override func absoluteEntropy(point: T.Point, field: T.Field) -> Int {
        let targets = field.undefinedPoints().toSet().subtracting(preventedTargets)
        return entropy * targets.count * types.count - preventedTargetTypes.count
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

    override func preventSpecificRestriction(_ restriction: any ElementRestriction) {
        guard let restriction = restriction as? TeleporterRestriction<T> else { return }
        guard let target = restriction.target else { return }

        restriction.types.forEach {
            addTargetTypePrevention(target: target, type: $0)
        }
    }

    override func resetRestrictions() {
        super.resetRestrictions()
        isIsolatedAvailable = true
        types = TeleporterType.allCases.toSet()
        requiredTargets.removeAll()
        preventedTargets.removeAll()
        preventedTargetTypes.removeAll()
    }

    override func waveFunctionCollapse(point: Point, field: Field) -> Field.Element? {
        var passages = passagesVariations.randomElement()
        if passages == nil && isIsolatedAvailable {
            passages = []
        }
        guard let passages = passages else { return nil }

        let target = target(point: point, field: field)
        guard let target = target else { return nil }

        let preventedTypes = preventedTargetTypes
            .filter { $0.target == target }
            .map { $0.type }
            .toSet()
        let availableTypes = types.subtracting(preventedTypes)
        guard let type = availableTypes.randomElement() else { return nil }

        let teleporter = Teleporter<T>(target: target, type: type, passages: passages)

        // TODO: Time to time generation fails and lead to solid element. This issue should be investigated. Comfortable to reproduce it with big amount of portals.
        return teleporter as? Field.Element
    }

    private func addTargetTypePrevention(target: T.Point, type: TeleporterType) {
        // No additional actions are required if the target is already prevented for all types.
        guard !preventedTargets.contains(target) else { return }

        let tuple = TargetTypeTuple(target: target, type: type)
        preventedTargetTypes.insert(tuple)
        let preventionsCount = preventedTargetTypes
            .filter { $0.target == target }
            .count

        // If all types are prevented for a target, these limitations should be moved from preventedTargetTypes to preventedTargets.
        if preventionsCount == TeleporterType.allCases.count {
            preventedTargetTypes = preventedTargetTypes.filter { $0.target != target }
            preventedTargets.insert(target)
        }
    }

    private func target(point: Point, field: Field) -> Point? {
        guard !checkConflicts() else { return nil }
        if let requiredTarget = requiredTargets.first { return requiredTarget }

        var available = field.undefinedPoints().subtracting(preventedTargets)
        available.remove(point)
        return available.randomElement()
    }

    private func checkConflicts() -> Bool {
        if requiredTargets.count > 1 { return true }
        if !requiredTargets.intersection(preventedTargets).isEmpty { return true }
        return false
    }
}
