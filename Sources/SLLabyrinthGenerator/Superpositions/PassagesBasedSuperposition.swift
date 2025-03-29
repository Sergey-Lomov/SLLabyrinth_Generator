//
//  PassagesBasedSuperposition.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 28.03.2025.
//

class PassagesBasedSuperposition<T, E>: TopologyBasedElementSuperposition<T> where T: Topology, E: PassagesBasedElement<T> {
    func filterInitial(_ variant: [T.Edge]) -> Bool { return true }

    func initialVariations() -> [[T.Edge]] {
        let id = String(reflecting: Self.self) + "_initVariations"
        return GlobalCache.getValue(id: id) {
            T.Edge.allCases.combinations().filter { filterInitial($0) }
        }
    }

    private var passagesVariations: [[T.Edge]] = []

    required init() {
        super.init()
        passagesVariations = initialVariations()
    }

    required init(variations: [[T.Edge]]) {
        super.init()
        self.passagesVariations = variations
    }

    override func copy() -> Self {
        Self.init(variations: passagesVariations)
    }

    override var entropy: Int {
        passagesVariations.count
    }

    override func applyCommonRestriction(_ restriction: TopologyBasedElementRestriction<T>) -> Bool {
        switch restriction {
        case .wall(let edge), .fieldEdge(let edge):
            passagesVariations = passagesVariations.filter { !$0.contains(edge) }
        case .passage(let edge):
            passagesVariations = passagesVariations.filter { $0.contains(edge) }
        @unknown default:
            return false
        }

        return true
    }

    override func resetRestrictions() {
        passagesVariations = initialVariations()
    }

    override func waveFunctionCollapse() -> T.Field.Element? {
        guard let variation = passagesVariations.randomElement() else { return nil }
        return E.init(passages: variation) as? T.Field.Element
    }
}

