//
//  IdEquatable.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 12.03.2025.
//

import Foundation

protocol IdEquatable: Equatable {
    var id: String { get }
}

extension IdEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
