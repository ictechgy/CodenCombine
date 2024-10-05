//
//  withLatestFrom.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/5/24.
//

import Combine

public extension Publisher {
    func withLatestFrom<AnotherUpstream>(_ anotherUpstream: AnotherUpstream) -> Publishers.WithLatestFrom<Self, AnotherUpstream> where AnotherUpstream: Publisher, Failure == AnotherUpstream.Failure {
        Publishers.WithLatestFrom(upstream: self, anotherUpstream: anotherUpstream)
    }
}

public extension Publishers {
    struct WithLatestFrom<Upstream, AnotherUpstream>: Publisher where Upstream: Publisher, AnotherUpstream: Publisher, Upstream.Failure == AnotherUpstream.Failure {
        public typealias Output = (Upstream.Output, AnotherUpstream.Output)
        public typealias Failure = Upstream.Failure
        
        let upstream: Upstream
        let anotherUpstream: AnotherUpstream
        
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == Output {
            let upstreamElementHolder = upstream
                .map { LatestDataType.upstreamData($0) }
            
            let anotherUpstreamElementHolder = anotherUpstream
                .map { LatestDataType.anotherUpstreamData($1) }
            
            Publishers.CombineLatest(upstreamElementHolder, anotherUpstreamElementHolder)
                .compactMap { upstreamDataType, anotherUpstreamDataType in
                    switch (upstreamDataType, anotherUpstreamDataType) {
                    case (.upstreamData(let upstreamOutput), .anotherUpstreamData(let anotherUpstreamOutput)):
                        return (upstreamOutput, anotherUpstreamOutput)
                    default:
                        return nil
                    }
                }
                .subscribe(subscriber)
        }
    }
}

extension Publishers.WithLatestFrom {
    private enum LatestDataType {
        case upstreamData(Upstream.Output)
        case anotherUpstreamData(AnotherUpstream.Output)
    }
}
