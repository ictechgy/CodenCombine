//
//  SequentialPassSubject.swift
//  CodenCombine
//
//  Created by Coden on 9/14/25.
//

import Combine

/// 데이터를 순차적으로 발송하는 Subject
/// PassThroughSubject 성격
public final class SequentialPassSubject<Element>: Publisher { // TODO: Publisher가 아닌 별도 프로토콜 만들어서 Subject처럼 몇가지 기본 함수 정의
    public typealias Output = SequentialEvent<Element>
    // TODO: 가능하다면 Failure를 SequentialEventError의 제네릭으로 주입 가능하도록 수정
    public typealias Failure = SequentialEventError
    
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
                    try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
                        let notification = ConsumptionNotification(continuation: continuation)
                        let event = SequentialEvent(
                            element: event,
                            notification: notification
                        )
                        _ = subscriber?.receive(event)
                    }
                }
                subscriber?.receive(completion: .finished)
            } catch SequentialEventError.unexpectedlyTerminated {
                subscriber?.receive(completion: .failure(SequentialEventError.unexpectedlyTerminated))
            } catch {
                subscriber?.receive(completion: .failure(.thrown(error: error)))
            }
        }
    }
}
