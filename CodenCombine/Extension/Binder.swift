//
//  Binder.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/12/24.
//

import Combine

public struct Binder<Value>: Subscriber {
    public typealias Input = Value
    public typealias Failure = Never
    
    public let combineIdentifier: CombineIdentifier = CombineIdentifier()
    private let binding: (Value) -> Void
    
    init<Target: AnyObject>(_ target: Target, scheduler: any Scheduler = MainScheduler.instance, action: @escaping (Target, Value) -> Void) {
        self.binding = { [weak target = target] value in
            guard let target else { return }
            
            scheduler.schedule {
                action(target, value)
            }
        }
    }
    
    public func receive(subscription: any Subscription) {
        subscription.request(.unlimited)
    }
    
    public func receive(_ input: Input) -> Subscribers.Demand {
        self.binding(input)
        return .none
    }
    
    public func receive(completion: Subscribers.Completion<Failure>) {
        // never end
    }
}
