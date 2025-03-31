//
//  PassagesInstantiableElement.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 29.03.2025.
//

class PassagesInstantiableElement<T: Topology>: PassagesBasedElement<T> {
    required override init(passages: [T.Edge]) {
        super.init(passages: passages)
    }
}
