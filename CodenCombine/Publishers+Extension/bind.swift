//
//  bind.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/11/24.
//

import Combine

public extension Publisher {
    func bind<Injectable: Subject>(to subjects: Injectable...) -> Cancellable where Output == Injectable.Output, Failure == Injectable.Failure {
        sink { completion in
            subjects.forEach {
                $0.send(completion: completion)
            }
        } receiveValue: { value in
            subjects.forEach {
                $0.send(value)
            }
        }
    }
}
