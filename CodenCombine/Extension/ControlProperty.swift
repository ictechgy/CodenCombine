//
//  ControlProperty.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/30/24.
//

import Combine

public struct ControlProperty<PropertyType>: Publisher, Subscriber {
    public typealias Input = PropertyType
    public typealias Output = PropertyType
    public typealias Failure = Never

    public let combineIdentifier = CombineIdentifier()
    
    let outbound: any Publisher<Output, Never>
    let inbound: any Subscriber<Output, Never>

    public init<Outbound: Publisher, Inbound: Subscriber>(outbound: Outbound, inbound: Inbound) where Outbound.Output == Output, Outbound.Failure == Failure, Inbound.Input == Output, Inbound.Failure == Failure {
        self.outbound = outbound.subscribe(on: MainScheduler.instance)
        self.inbound = inbound
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        outbound.receive(subscriber: subscriber)
    }
    
    public func receive(_ input: Input) -> Subscribers.Demand {
        inbound.receive(input)
    }
    
    public func receive(completion: Subscribers.Completion<Never>) {
        inbound.receive(completion: completion)
    }
    
    public func receive(subscription: any Subscription) {
        inbound.receive(subscription: subscription)
    }
}
