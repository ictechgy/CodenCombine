//
//  SequentialPassSubject.swift
//  CodenCombine
//
//  Created by Coden on 9/14/25.
//

import Combine

/// 데이터를 순차적으로 발송하는 Subject
/// PassThroughSubject 성격
public final class SequentialPassSubject<Element, Failure: Error>: Publisher {
    public typealias Output = SequentialEvent<Element>
    public typealias Failure = Failure
    
    private var conveyorStream: AsyncThrowingStream<Element, Error>?
    private var conveyorStreamContinuation: AsyncThrowingStream<Element, Error>.Continuation?
    
    public init() {
        self.conveyorStream = AsyncThrowingStream { continuation in
            self.conveyorStreamContinuation = continuation
        }
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = SequentialPassSubscription<S>(
            subscriber: subscriber,
            conveyorStream: conveyorStream
        )
        subscriber.receive(subscription: subscription)
    }
    
    public func send(_ value: Element) {
        conveyorStreamContinuation?.yield(value)
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .finished:
            conveyorStreamContinuation?.finish()
        case .failure(let error):
            conveyorStreamContinuation?.finish(throwing: error)
        }
    }
    
    deinit {
        conveyorStreamContinuation?.finish()
    }
}

extension SequentialPassSubject {
    final class SequentialPassSubscription<S: Subscriber>: Subscription where S.Failure == Failure, S.Input == SequentialEvent<Element> {
        private var subscriber: S?
        private var conveyorStream: AsyncThrowingStream<Element, Error>?
        
        init(
            subscriber: S,
            conveyorStream: AsyncThrowingStream<Element, Error>?
        ) {
            self.subscriber = subscriber
            self.conveyorStream = conveyorStream
            
            bind()
        }
        
        func request(_ demand: Subscribers.Demand) {
            // unlimited..
        }
        
        func cancel() {
            self.conveyorStream = nil
            self.subscriber = nil
        }
    }
}

extension SequentialPassSubject.SequentialPassSubscription {
    private func bind() {
        guard let conveyorStream else { return }
        
        Task {
            do {
                for try await event in conveyorStream {
                    await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                        let notification = ConsumptionNotification(continuation: continuation)
                        let event = SequentialEvent(
                            element: event,
                            notification: notification
                        )
                        _ = subscriber?.receive(event)
                    }
                }
            } catch {
                guard let error = error as? Failure else { return }
                subscriber?.receive(completion: .failure(error))
            }
        }
    }
}
