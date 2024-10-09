//
//  observeOn.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/5/24.
//

import Combine
import Foundation

public extension Publisher {
    /// 실행이 dispatchqueue에서 이미 실행되고 있었다면 그대로 synchronous하게 실행, 그렇지 않다면 asynchronous하게 실행 (해당 큐의 맨 뒤로 작업 hopping)
    func observe(on dispatchQueue: DispatchQueue) -> Publishers.ObserveOn<Self> {
        Publishers.ObserveOn(upstream: self, dispatchQueue: dispatchQueue)
    }
}

public extension Publishers {
    struct ObserveOn<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure
        
        let upstream: Upstream
        let dispatchQueue: DispatchQueue
        
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let subscriberProxy = ObserveOnSubscriberProxy(downstream: subscriber, dispatchQueue: dispatchQueue)
            upstream.subscribe(subscriberProxy)
        }
    }
}

extension Publishers.ObserveOn {
    // Subscription이 아닌 Subscriber로 구현
    final class ObserveOnSubscriberProxy<DownStream: Subscriber>: Subscriber where DownStream.Input == Upstream.Output, DownStream.Failure == Upstream.Failure {
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        private let downstream: DownStream
        private let dispatchQueue: DispatchQueue
        
        private let lock = NSRecursiveLock()
        
        init(downstream: DownStream, dispatchQueue: DispatchQueue) {
            self.downstream = downstream
            self.dispatchQueue = dispatchQueue
        }
        
        func receive(subscription: Subscription) {
            downstream.receive(subscription: subscription)
        }
        
        func receive(_ input: Upstream.Output) -> Subscribers.Demand {
            if dispatchQueue.id == DispatchQueue.currentRunningQueueId, lock.try() {
                _ = downstream.receive(input)
                lock.unlock()
            } else {
                dispatchQueue.async {
                    _ = self.downstream.receive(input)
                }
            }
            
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Upstream.Failure>) {
            if dispatchQueue.id == DispatchQueue.currentRunningQueueId {
                downstream.receive(completion: completion)
            } else {
                dispatchQueue.async {
                    self.downstream.receive(completion: completion)
                }
            }
        }
    }
}
