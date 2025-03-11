//
//  UndefinedElement.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 11.03.2025.
//

import Foundation

final class UndefinedElement<T: Topology>: TopologyBasedLabyrinthElement<T> {
    override var isVisitable: Bool { false }
}
