//
//  IsolatedAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 12.03.2025.
//

import Foundation

enum RecalcualtionLevel {
    case paths, isolatedAreas, none

}

public class IsolatedAreasStrategy<T: Topology> {
    var recalculation: RecalcualtionLevel { .none }

    func handle(area: PathsGraphArea<T>, generator: LabyrinthGenerator<T>) -> Bool {
        return false
    }
}
