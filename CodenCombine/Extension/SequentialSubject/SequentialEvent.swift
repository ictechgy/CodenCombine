//
//  SequentialEvent.swift
//  CodenCombine
//
//  Created by Coden on 9/14/25.
//

public protocol ConsumptionInformable {
    /// element가 소비되었음을 알림
    func notifyElementConsumed() async
}

public enum SequentialEventError: Error {
    /// element가 소비되지 않은 상태로 수신부가 비정상 종료된 경우 생기는 에러
    case unexpectedlyTerminated
    /// 일반적인 에러
    case thrown(error: Error) // TODO: Error 제네릭
}

actor ConsumptionNotification: ConsumptionInformable {
    private var continuation: UnsafeContinuation<Void, Error>?
    
    init(continuation: UnsafeContinuation<Void, Error>) {
        self.continuation = continuation
    }
    
    func notifyElementConsumed() {
        self.continuation?.resume(with: .success(()))
        self.continuation = nil
    }
    
    deinit {
        if self.continuation != nil {
            self.continuation?.resume(throwing: SequentialEventError.unexpectedlyTerminated)
            self.continuation = nil
        }
    }
}

/// SequentialSubject들의 데이터 타입
public struct SequentialEvent<Element> {
    public let element: Element
    public let notification: ConsumptionInformable
}
