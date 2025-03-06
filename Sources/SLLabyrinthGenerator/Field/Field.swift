//
//  Field.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

protocol Field {
    associatedtype Topology: SLLabyrinthGenerator.Topology

    func node(_ point: Topology.Point) -> Node<Topology>?
    func superposition(_ point: Topology.Point) -> NodeSuperposition<Topology>?
}
