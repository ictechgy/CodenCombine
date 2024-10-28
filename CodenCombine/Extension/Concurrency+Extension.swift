//
//  Concurrency+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/19/24.
//

import Foundation
import Combine

public extension Publisher {
    func mapByTask<T>(_ transform: @escaping (Output) async throws -> T) -> Publishers.MapByTask<Self, T> where Self.Failure == Never {
        Publishers.MapByTask(upstream: self, transform: transform)
    }
    
    func mapByCancellableTask<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.MapByCancellableTask<Self, T> {
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
    struct MapByCancellableTask<Upstream: Publisher, T>: Publisher where Upstream.Failure == Error {
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
    actor TaskWarehouse {
        private var tasks: [UUID: Task<Void, Error>] = [:]
        
        func insert(_ task: Task<Void, Error>, identifying uuid: UUID) {
            tasks[uuid] = task
        }
        
        func removeTask(by uuid: UUID) {
            tasks[uuid]?.cancel()
            tasks[uuid] = nil
        }
        
        func removeAll() {
            tasks.forEach { $1.cancel() }
            tasks.removeAll(keepingCapacity: false)
        }
    }
    
    final class MapByCancellableTaskSubscription<S: Subscriber>: Subscription where S.Input == T {
        private let taskWarehouse = TaskWarehouse()
        // upstream element가 단시간에 많이 내려오면 여러개의 task가 실행될 수도 있는거고.. taskList with NSRecursiveLock?
        // 이게 순차적으로 하나씩만 동작되길 원한다면 actor 고려도 해야하고.. <- 외부에서 task closure에 부여해야 하는 부분 (global actor)
        // taskGroup / AsyncStream
        // sink / AnySubscriber
        // actor
        
        init(upstream: Upstream, subscriber: S, transform: @escaping (Upstream.Output) async throws -> T) where Upstream.Failure == S.Failure {
            upstream
                .withUnretained(self)
                .flatMap { subscription, output in
                    subscription.mapInFuture(output: output, transform: transform)
                }
                .subscribe(subscriber)
        }
        
        func request(_ demand: Subscribers.Demand) {
            // unlimited
        }
        
        func cancel() {
            Task {
                await taskWarehouse.removeAll()
            }
        }
    }
}

extension Publishers.MapByCancellableTask.MapByCancellableTaskSubscription {
    private func mapInFuture(output: Upstream.Output, transform: @escaping (Upstream.Output) async throws -> T) -> AnyPublisher<T, Error> {
        Future { promise in
            Task {
                let id = UUID()
                await self.taskWarehouse.insert(
                    Task { [promise] in
                        do {
                            try Task.checkCancellation()
                            
                            let result = try await transform(output)
                            
                            try Task.checkCancellation()
                            
                            promise(.success(result))
                        } catch {
                            promise(.failure(error))
                        }
                        
                        await self.taskWarehouse.removeTask(by: id)
                    },
                    identifying: id
                )
            }
        }
        .eraseToAnyPublisher()
    }
}
