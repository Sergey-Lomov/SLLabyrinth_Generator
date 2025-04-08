//
//  PassagesBasedSuperposition.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 28.03.2025.
//

class PassagesBasedSuperposition<T: Topology>: TopologyBasedElementSuperposition<T> {

    func filterInitialPassages(_ variant: [T.Edge]) -> Bool {
        fatalError("Should be overrided in derived classes")
    }

    private func initialPassages() -> [[T.Edge]] {
        let id = String(reflecting: Self.self) + "_initPassages"
        return GlobalCache.getValue(id: id) {
            T.Edge.allCases.combinations().filter {
                filterInitialPassages($0)
            }
        }
    }

    internal var passagesVariations: [[T.Edge]] = []

    required init() {
        super.init()
        passagesVariations = initialPassages()
    }

    init(variations: [[T.Edge]]) {
        super.init()
        self.passagesVariations = variations
    }

    override func copy() -> Self {
        let copy = Self.init()
        copy.passagesVariations = passagesVariations
        return copy
    }

    override var entropy: Int {
        passagesVariations.count
    }

    override func applyPassagesRestriction(_ restriction: PassagesElementRestriction<T>, at point: Point) -> Bool {
        switch restriction {
        case .wall(let edge):
            passagesVariations = passagesVariations.filter { !$0.contains(edge) }
        case .passage(let edge):
            passagesVariations = passagesVariations.filter { $0.contains(edge) }
        }

        return true
    }

    override func applyConnectionRestriction(_ restriction: ConnectionPreventRestriction<T>, at point: Point) -> Bool {
        if let edge = T.edge(from: point, to: restriction.target) {
            passagesVariations = passagesVariations.filter { !$0.contains(edge) }
        }

        return true
    }

    override func resetRestrictions() {
        passagesVariations = initialPassages()
    }
}

