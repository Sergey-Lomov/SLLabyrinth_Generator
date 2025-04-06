//
//  TeleportEdgeCuttingStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 04.04.2025.
//

import Foundation

final class TeleportEdgeCuttingStrategy<T: Topology>: EdgeCuttingStrategy<T> {
    override func tryToCut(_ edge: Edge, generator: Generator, provider: String) -> Bool {
        let restriction = ElementsAvailabilityRestriction(
            type: .denying,
            category: TeleporterSuperposition<T>.category
        )

        let points = [edge.from.point, edge.to.point]
        let restrictions = [
            edge.from.point: [restriction],
            edge.to.point: [restriction],
        ]
        let result = generator.regenerate(
            points: points,
            restrictions: restrictions,
            restrictionsProvider: provider
        )

        return result.isSuccess
    }
}
