//
//  IdHashable.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 20.03.2025.
//

import Foundation

public protocol IdHashable: IdEquatable, Hashable {

}

extension IdHashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
