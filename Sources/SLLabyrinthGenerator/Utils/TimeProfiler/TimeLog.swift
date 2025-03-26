//
//  TimeLog.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 12.03.2025.
//

import Dispatch
import Foundation

final class TimeLog: CustomDebugStringConvertible, CustomReflectable {
    var nodes: [TimeLogNode] = []
    private var current: [TimeLogNode] = []

    var time: Double { nodes
        .map { $0.time }
        .reduce(0, +)
    }

    var debugDescription: String {
        "\(time.readable()) total"
    }

    var customMirror: Mirror {
        return Mirror(self, children: ["nodes": nodes.map { $0.customMirror }])
    }

    func callAsFunction(_ title: String, closure: () -> Void) {
        callAsFunction(title) { _ in closure() }
    }

    func callAsFunction(_ title: String, closure: (TimeLog) -> Void) {
        let node = TimeLogNode(title: title)
        current.append(node)
        let start = DispatchTime.now()

        closure(self)

        let end = DispatchTime.now()
        node.time = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
        current.remove(node)
        if current.isEmpty {
            nodes.append(node)
        } else {
            current.last?.nested.append(node)
        }
    }

    func printReport() {
        print("Total time: \(time.readable())")
        for node in nodes {
            printReportNode(prefix: "-", node: node)
        }
    }

    private func printReportNode(prefix: String, node: TimeLogNode) {
        print("\(prefix) \(node.title) \(node.time.readable())")
        for node in node.nested {
            printReportNode(prefix: prefix + "-", node: node)
        }
    }
}

private extension Double {
    func readable() -> String {
        String(format: "%.3f sec", self)
    }
}
