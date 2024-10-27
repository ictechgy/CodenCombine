//
//  Concurrency+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/19/24.
//

import Combine

public extension Publisher {
    func mapByTask<T>(_ transform: @escaping (Output) async throws -> T) -> Publishers.MapByTask<Self, T> where Self.Failure == Never {
        Publishers.MapByTask(upstream: self, transform: transform)
    }
    
    func mapByCancellableTask<T>(_ transform: @escaping (Output) async throws -> T) -> Publishers.MapByCancellableTask<Self, T> {
        Publishers.MapByCancellableTask(upstream: self, transform: transform)
    }
}

// MARK: - MapByTask
public extension Publishers {
    struct MapByTask<Upstream: Publisher, T>: Publisher where Upstream.Failure == Never {
        public typealias Output = T
        public typealias Failure = Error
        
        let upstream: Upstream
        let transform: (Upstream.Output) async throws -> T
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            upstream
                .flatMap(mappingByTask)
                .receive(subscriber: subscriber)
        }
    }
}

extension Publishers.MapByTask {
    private func mappingByTask(upstreamOutput: Upstream.Output) -> AnyPublisher<Output, Failure> {
        Future { promise in
            Task { [promise] in
                do {
                    let result = try await transform(upstreamOutput)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - MapByCancellableTask
public extension Publishers {
    struct MapByCancellableTask<Upstream: Publisher, T>: Publisher {
        public typealias Output = T
        public typealias Failure = Error
        
        let upstream: Upstream
        let transform: (Upstream.Output) async throws -> T
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = MapByCancellableTaskSubscription(upstream: upstream, subscriber: subscriber, transform: transform)
            
            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: - MapByCancellableTask - Subscription
extension Publishers.MapByCancellableTask {
    final class MapByCancellableTaskSubscription<S: Subscriber>: Subscription where S.Input == T {
        private var task: Task<Void, Error>? // upstream element가 단시간에 많이 내려오면 여러개의 task가 실행될 수도 있는거고.. taskList with NSRecursiveLock?
        // 이게 순차적으로 하나씩만 동작되길 원한다면 actor 고려도 해야하고..
        // taskGroup / AsyncStream
        // sink / AnySubscriber
        // actor
        private var cancellable: Cancellable?
        
        init(upstream: Upstream, subscriber: S, transform: @escaping (Upstream.Output) async throws -> T) {
            mapBind(from: upstream, to: subscriber, with: transform)
        }
        
        func request(_ demand: Subscribers.Demand) {
            // unlimited
        }
        
        func cancel() {
            cancellable?.cancel()
            cancellable = nil
        }
    }
}

extension Publishers.MapByCancellableTask.MapByCancellableTaskSubscription {
    private func mapBind(from upstream: Upstream, to subscriber: S, with transform: (Upstream.Output) async throws -> T) {
        
    }
    
    private func mapInFuture(output: Upstream.Output, transform: @escaping (Upstream.Output) async throws -> T) -> AnyPublisher<T, Error> {
        Future { promise in
            Task { [promise] in
                do {
                    try Task.checkCancellation()
                    
                    let result = try await transform(output)
                    
                    try Task.checkCancellation()
                    
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
