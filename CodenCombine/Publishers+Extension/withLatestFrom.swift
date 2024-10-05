//
//  withLatestFrom.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/5/24.
//

import Combine

public extension Publisher {
    
}

public extension Publishers {
    struct WithLatestFrom<Upstream, AnotherUpstream>: Publisher where Upstream: Publisher, AnotherUpstream: Publisher {
        public typealias Output = (Upstream.Output, AnotherUpstream.Output)
        public typealias Failure = Upstream.Failure
        
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == Output {
            
        }
    }
}
