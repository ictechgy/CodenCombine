//
//  Binder.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/12/24.
//

import Combine

struct Binder<Value>: Subscriber {
    typealias Input = Value
    typealias Failure = Never
    
    let combineIdentifier: CombineIdentifier = CombineIdentifier()
    private let binding: (Value) -> Void
    
    init<Target: AnyObject>(_ target: Target, scheduler: any Scheduler = MainScheduler.instance, action: @escaping (Target, Value) -> Void) {
        self.binding = { [weak target = target] value in
            guard let target else { return }
            
            scheduler.schedule {
                action(target, value)
            }
        }
    }
    
    func receive(subscription: any Subscription) {
        subscription.request(.unlimited)
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        self.binding(input)
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        // never end
    }
}
