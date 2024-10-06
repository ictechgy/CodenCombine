//
//  observeOn.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/5/24.
//

import Combine
import Foundation

public extension Publisher {
    /// 실행이 scheduler에서 이미 실행되고 있었다면 그대로 synchronous하게 실행, 그렇지 않다면 asynchronous하게 실행 (해당 큐의 맨 뒤로 작업 hopping)
    func observe(on scheduler: any Scheduler) -> Publishers.ObserveOn<Self> {
        Publishers.ObserveOn(upstream: self, scheduler: scheduler)
    }
}

public extension Publishers {
    struct ObserveOn<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure
        
        let upstream: Upstream
        let scheduler: any Scheduler
        
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let subscriberProxy = ObserveOnSubscriberProxy(downstream: subscriber, scheduler: scheduler)
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
        private let scheduler: any Scheduler
        
        init(downstream: DownStream, scheduler: any Scheduler) {
            self.downstream = downstream
            self.scheduler = scheduler
        }
        
        func receive(subscription: Subscription) {
            downstream.receive(subscription: subscription)
        }
        
        func receive(_ input: Upstream.Output) -> Subscribers.Demand {
            // 현재 해당 scheduler면 동기적으로 실행하고
            // 해당 scheduler가 아니면 비동기적으로 receive 시켜야 함
            ImmediateScheduler.shared
            
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Upstream.Failure>) {
            downstream.receive(completion: completion)
        }
    }
}
