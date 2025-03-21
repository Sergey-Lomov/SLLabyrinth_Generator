//
//  IsolatedAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 12.03.2025.
//

import Foundation

public class IsolatedAreasStrategy<T: Topology> {
    func handle(area: PathsGraphArea<T>,
                incomes: [AreasGraphEdge<T>],
                outgoings: [AreasGraphEdge<T>],
                generator: LabyrinthGenerator<T>) -> Bool {
        return false
    }
}
