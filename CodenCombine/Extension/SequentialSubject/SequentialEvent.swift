//
//  SequentialEvent.swift
//  CodenCombine
//
//  Created by Coden on 9/14/25.
//

public protocol ConsumptionInformable {
    /// 데이터가 소비되었음을 알림
    func notifyEventConsumed() async
}

actor ConsumptionNotification: ConsumptionInformable {
    private var continuation: UnsafeContinuation<Void, Never>?
    
    init(continuation: UnsafeContinuation<Void, Never>) {
        self.continuation = continuation
    }
    
    func notifyEventConsumed() {
        self.continuation?.resume(with: .success(()))
        self.continuation = nil
    }
}

/// SequentialSubject들의 데이터 타입
public struct SequentialEvent<Element> {
    public let element: Element
    public let notification: ConsumptionInformable
}
