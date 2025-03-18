//
//  CycledAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 18.03.2025.
//

import Foundation

public class CycledAreasStrategy<T: Topology> {
    @discardableResult
    func handle(area: PathsGraphArea<T>, generator: LabyrinthGenerator<T>) -> Bool {
        return false
    }
}
