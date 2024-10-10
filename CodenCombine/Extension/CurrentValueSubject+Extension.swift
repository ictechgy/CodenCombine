//
//  CurrentValueSubject+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/10/24.
//

import Combine

public protocol ValueAccessiblePublisher where Self: Publisher {
    var value: Output { get }
}

extension CurrentValueSubject: ValueAccessiblePublisher {
    public func eraseToValueAccessibleAnyPublisher() -> ValueAccessibleAnyPublisher<CurrentValueSubject> {
        ValueAccessibleAnyPublisher(wrappedPublisher: self)
    }
}

public struct ValueAccessibleAnyPublisher<Wrapped: ValueAccessiblePublisher>: Publisher {
    public typealias Output = Wrapped.Output
    public typealias Failure = Wrapped.Failure
    
    private let wrappedPublisher: Wrapped
    
    init(wrappedPublisher: Wrapped) {
        self.wrappedPublisher = wrappedPublisher
    }
    
    public var value: Output {
        wrappedPublisher.value
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        wrappedPublisher.receive(subscriber: subscriber)
    }
}

extension ValueAccessibleAnyPublisher: ValueAccessiblePublisher { }
