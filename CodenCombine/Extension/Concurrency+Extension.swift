//
//  Concurrency+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/19/24.
//

import Combine

public extension Publisher {
    // TODO: 취소 가능한 map도 만들어보는건 어떨까? 
    func mapByTask<T>(_ transform: @escaping (Output) async throws -> T) -> Publishers.MapByTask<Self, T> where Self.Failure == Never {
        Publishers.MapByTask(upstream: self, transform: transform)
    }
}

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
