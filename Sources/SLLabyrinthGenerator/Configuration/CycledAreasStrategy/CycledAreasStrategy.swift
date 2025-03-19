//
//  CycledAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 18.03.2025.
//

import Foundation

public class CycledAreasStrategy<T: Topology> {
    typealias Generator = LabyrinthGenerator<T>

    @discardableResult
    func handle(area: PathsGraphArea<T>, generator: Generator) -> Bool {
        fatalError("Should be implemented in derived class")
    }

    class func postprocessing(generator: Generator) {}
}
