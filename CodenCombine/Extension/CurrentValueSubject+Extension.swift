//
//  CurrentValueSubject+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/10/24.
//

import Combine

/// value에 접근 가능한 publisher 추상화
public protocol ValueAccessiblePublisher where Self: Publisher {
    var value: Output { get }
}

extension CurrentValueSubject: ValueAccessiblePublisher {
    /// value에 접근 가능한 AnyPublisher로 변환
    public func eraseToValueAccessibleAnyPublisher() -> ValueAccessibleAnyPublisher<CurrentValueSubject> {
        ValueAccessibleAnyPublisher(wrappedPublisher: self)
    }
}

/// ``eraseToAnyPublisher()`` 의 value 접근 가능 버전
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

// ValueAccessibleAnyPublisher는 그 자체로 `ValueAccessiblePublisher`
extension ValueAccessibleAnyPublisher: ValueAccessiblePublisher { }
