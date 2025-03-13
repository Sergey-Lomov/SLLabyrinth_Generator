//
//  TimeLogNode.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 13.03.2025.
//

import Foundation

final class TimeLogNode: IdEquatable, CustomDebugStringConvertible, CustomReflectable {
    let id = UUID()

    var title: String
    var time: Double
    var nested: [TimeLogNode]

    init(title: String, time: Double = 0, nested: [TimeLogNode] = []) {
        self.title = title
        self.time = time
        self.nested = nested
    }

    var debugDescription: String {
        let time = String(format: "%.3f sec", time)
        let nested = self.nested.isEmpty ? " " : " \(self.nested.count) nested"
        return "\(title) \(time)\(nested)"
    }

    var customMirror: Mirror {
        return Mirror(self, children: ["nested": nested.map { $0.customMirror }])
    }
}
