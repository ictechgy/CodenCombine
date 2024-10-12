//
//  bind.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/11/24.
//

import Combine

public extension Publisher {
    func bind<Injectable: Subject>(to subjects: Injectable...) -> Cancellable where Output == Injectable.Output, Failure == Injectable.Failure {
        // subscription 전달은 없는 상태
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
    
    func bind<Receivable: Subscriber>(to subscribers: Receivable...) -> Cancellable where Output == Receivable.Input, Failure == Receivable.Failure {
        // subscription 전달은 없는 형태
        sink { completion in
            subscribers.forEach {
                $0.receive(completion: completion)
            }
        } receiveValue: { value in
            subscribers.forEach {
                _ = $0.receive(value)
            }
        }
    }
}
