//
//  ControlEvent.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/31/24.
//

import Combine

public struct ControlEvent<PropertyType> : Publisher {
    public typealias Output = PropertyType
    public typealias Failure = Never

    let events: any Publisher<Output, Failure>

    public init<Upstream: Publisher>(events: Upstream) where Upstream.Output == Output, Upstream.Failure == Failure {
        self.events = events.subscribe(on: MainScheduler.instance)
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, PropertyType == S.Input {
        self.events.receive(subscriber: subscriber)
    }
}
