//
//  DictionaryBasedField.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 11.03.2025.
//

import Foundation

protocol DictionaryBasedField: TopologyField {
    var nodes: Dictionary<Point, Element> { get set }
}

extension DictionaryBasedField {

    func allPoints() -> [Point] { Array(nodes.keys) }

    func element(at point: Point) -> Element? { nodes[point] }

    func contains(_ point: Point) -> Bool {
        nodes.keys.contains(point)
    }

    func copy() -> Self {
        var copy = Self(size: size)
        copy.nodes = self.nodes
        return copy
    }

    mutating func setElement(at point: Point, element: Element?) {
        guard contains(point) else { return }
        nodes[point] = element ?? Element.undefined()
    }
}
