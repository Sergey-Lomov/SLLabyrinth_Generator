//
//  IdEquitable.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 12.03.2025.
//

import Foundation

protocol IdEquitable: Equatable {
    var id: UUID { get }
}

extension IdEquitable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
