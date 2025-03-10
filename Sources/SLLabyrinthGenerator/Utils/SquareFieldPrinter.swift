//
//  SquareFieldPrinter.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

final class SquareFieldPrinter {
    func print(_ field: SquareField) -> String {
        var result: Array<String> = []
        for y in (0..<field.size.1).reversed() {
            var lines: Array<String> = ["", "", ""]

            for x in 0..<field.size.0 - 1 {
                let point = SquarePoint(x: x, y: y)
                guard let element = field.element(at: point) else {
                    printUndefined(&lines)
                    continue
                }

                switch element {
                case let element as EdgeBasedElement<SquareTopology>:
                    printEdgeBased(element, lines: &lines)
                default: break
                }
            }

            result.append(contentsOf: lines)
        }

        return result.joined(separator: "\n")
    }

    private func printUndefined(_ lines: inout Array<String>) {
        lines[0] += "???"
        lines[1] += "???"
        lines[2] += "???"
    }

    private func boolString(_ value: Bool) -> String {
        value ? " " : "█"
    }

    private func printEntrances(_ entrances: Array<SquareEdge>, lines: inout Array<String>)
    {
        let arr = [
            false,
            entrances.contains(.top),
            false,
            entrances.contains(.left),
            !entrances.isEmpty,
            entrances.contains(.right),
            false,
            entrances.contains(.bottom),
            false]

        lines[0] += boolString(arr[0]) + boolString(arr[1]) + boolString(arr[2])
        lines[1] += boolString(arr[3]) + boolString(arr[4]) + boolString(arr[5])
        lines[2] += boolString(arr[6]) + boolString(arr[7]) + boolString(arr[8])
    }

    private func printEdgeBased(_ element: EdgeBasedElement<SquareTopology>, lines: inout Array<String>) {
        printEntrances(element.passages, lines: &lines)
    }
}
