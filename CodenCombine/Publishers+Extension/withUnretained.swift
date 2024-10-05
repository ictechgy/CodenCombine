//
//  withUnretained.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/4/24.
//

import Combine

public extension Publisher {
    func withUnretained<T: AnyObject>(_ captureTarget: T) -> Publishers.WithUnretained<Self, T> {
        Publishers.WithUnretained(upstream: self, captureTarget: captureTarget)
    }
}

public extension Publishers {
    struct WithUnretained<UpStream, CaptureTarget>: Publisher where UpStream: Publisher, CaptureTarget: AnyObject {
        public typealias Output = (CaptureTarget, UpStream.Output)
        public typealias Failure = UpStream.Failure
        
        let upstream: UpStream
        let captureTarget: CaptureTarget
        
        public func receive<S>(subscriber: S) where S : Subscriber, UpStream.Failure == S.Failure, S.Input == Output {
            let withUnretainedPublisher = upstream.compactMap { [weak target = captureTarget] output -> Output? in
                guard let target else { return nil }
                return (target, output)
            }
            
            withUnretainedPublisher.receive(subscriber: subscriber)
        }
    }
}
