//
//  Cacheable.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 13.03.2025.
//

import Foundation

@propertyWrapper
final class Cached<T: ZeroRepresentable> {
    var compute: () -> T
    private var cached: T? = nil

    init(compute: @escaping () -> T = T.getZero) {
        self.compute = compute
    }

    var wrappedValue: T {
        let result = cached ?? compute()
        cached = result
        return result
    }

    func invaliade() {
        cached = nil
    }

    func copyFrom(_ obj: Cached<T>) {
        compute = obj.compute
        cached = obj.cached
    }
}
