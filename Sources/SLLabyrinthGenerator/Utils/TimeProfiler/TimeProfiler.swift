//
//  TimeProfiler.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 13.03.2025.
//

import Foundation

final class TimeProfiler {
    var logs: [TimeLog] = []

    var averageLog: TimeLog {
        let result = TimeLog()
        let nodes = logs.map { $0.nodes }
        result.nodes = averageNodes(nodes: nodes)
        return result
    }

    func execute(times: Int, closure: () -> TimeLog) {
        for _ in 0..<times {
            logs.append(closure())
        }
    }

    private func averageNodes(nodes: [[TimeLogNode]]) -> [TimeLogNode] {
        let versionsCount = nodes.count
        let flatNodes = nodes.flatMap { $0 }
        let grouped = Dictionary(grouping: flatNodes) { $0.title }
        return grouped.map { averageNode(title: $0, total: versionsCount, versions: $1) }
    }

    private func averageNode(title: String, total: Int, versions: [TimeLogNode]) -> TimeLogNode {
        let versionsTime = versions
            .map { $0.time }
            .reduce(0, +)
        let time = versionsTime / Double(total)

        let versionsNested = versions.map { $0.nested }
        let nested = averageNodes(nodes: versionsNested)

        return TimeLogNode(title: title, time: time, nested: nested)
    }
}
