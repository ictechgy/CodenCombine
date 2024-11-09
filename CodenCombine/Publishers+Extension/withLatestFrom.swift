//
//  withLatestFrom.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/5/24.
//

import Combine
import Foundation

public extension Publisher {
    /// origin upstream의 element가 방출되었을 때 다른 stream의 맨 마지막 값을 가져와 downstream으로 전송합니다.
    /// 단, 다른 stream에 element가 전송된 적 없다면 origin upstream의 element가 수없이 방출되어도 downstream로는 아무것도 전달되지 않습니다.
    /// 이 함수는 두 stream의 element를 같이 downstream으로 전송합니다.
    func withLatestFrom<AnotherUpstream>(_ anotherUpstream: AnotherUpstream) -> Publishers.WithLatestFrom<Self, AnotherUpstream, (Output, AnotherUpstream.Output)> where AnotherUpstream: Publisher, Failure == AnotherUpstream.Failure {
        Publishers.WithLatestFrom(upstream: self, anotherUpstream: anotherUpstream) {
            ($0, $1)
        }
    }
    
    /// origin upstream의 element가 방출되었을 때 다른 stream의 맨 마지막 값을 가져와 downstream으로 전송합니다.
    /// 단, 다른 stream에 element가 전송된 적 없다면 origin upstream의 element가 수없이 방출되어도 downstream로는 아무것도 전달되지 않습니다.
    /// 이 함수는 두 stream의 element를 어떻게 downstream으로 전송할지 결정해야 합니다.
    func withLatestFrom<AnotherUpstream, FinalOutput>(_ anotherUpstream: AnotherUpstream, _ resultSelector: @escaping (Output, AnotherUpstream.Output) -> FinalOutput) -> Publishers.WithLatestFrom<Self, AnotherUpstream, FinalOutput> where AnotherUpstream: Publisher, Failure == AnotherUpstream.Failure {
        Publishers.WithLatestFrom(upstream: self, anotherUpstream: anotherUpstream, resultSelector: resultSelector)
    }
}

public extension Publishers {
    struct WithLatestFrom<Upstream, AnotherUpstream, FinalOutput>: Publisher where Upstream: Publisher, AnotherUpstream: Publisher, Upstream.Failure == AnotherUpstream.Failure {
        public typealias Output = FinalOutput
        public typealias Failure = Upstream.Failure
        
        let upstream: Upstream
        let anotherUpstream: AnotherUpstream
        let resultSelector: (Upstream.Output, AnotherUpstream.Output) -> FinalOutput
        
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == Output {
            let subscription = WithLatestFromSubscription(upstream: upstream, anotherUpstream: anotherUpstream, resultSelector: resultSelector, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.WithLatestFrom {
    final class WithLatestFromSubscription<S: Subscriber>: Subscription where Upstream.Failure == AnotherUpstream.Failure, S.Input == FinalOutput, S.Failure == Upstream.Failure {
        
        private let recursiveLock = NSRecursiveLock()
        private var latestData: AnotherUpstream.Output?
        private var cancellable = Set<AnyCancellable>()
        
        init(upstream: Upstream, anotherUpstream: AnotherUpstream, resultSelector: @escaping (Upstream.Output, AnotherUpstream.Output) -> FinalOutput, subscriber: S) {
            anotherUpstream
                .withUnretained(self)
                .sink { [weak self] in
                    subscriber.receive(completion: $0)
                    self?.cancel()
                } receiveValue: { subscriptionSelf, output in
                    subscriptionSelf.recursiveLock.lock()
                    subscriptionSelf.latestData = output
                    subscriptionSelf.recursiveLock.unlock()
                }
                .store(in: &cancellable)
            
            upstream
                .withUnretained(self)
                .sink { [weak self] in
                    subscriber.receive(completion: $0)
                    self?.cancel()
                } receiveValue: { subscriptionSelf, output in
                    subscriptionSelf.recursiveLock.lock()
                    
                    if let latestData = subscriptionSelf.latestData {
                        _ = subscriber.receive(resultSelector(output, latestData))
                    }
                    
                    subscriptionSelf.recursiveLock.unlock()
                }
                .store(in: &cancellable)
        }
        
        func request(_ demand: Subscribers.Demand) {
            // do nothing on demand request..
        }
        
        func cancel() {
            recursiveLock.lock()
            latestData = nil
            cancellable.removeAll()
            recursiveLock.unlock()
        }
    }
}
