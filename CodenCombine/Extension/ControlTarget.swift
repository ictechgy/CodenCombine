//
//  ControlTarget.swift
//  CodenCombine
//
//  Created by JINHONG AN on 11/3/24.
//

import UIKit
import Combine

/// RxSwift의 ControlTarget에 ControlEvent의 메인쓰레드 보장과 (Subscriber로의) element 직접 전송을 합친 형태
final class ControlTarget<Output, S: Subscriber>: Subscription where S.Input == Output, S.Failure == Never {
    typealias Callback = (UIControl) -> Output
    private var callback: Callback?
    private var subscriber: S?
    private let scheduler = MainScheduler.instance
    
    init(
        control: UIControl,
        controlEvents: UIControl.Event,
        callback: @escaping Callback,
        subscriber: S
    ) {
        self.callback = callback
        self.subscriber = subscriber

        control.addTarget(
            self,
            action: #selector(ControlTarget.eventHandler),
            for: controlEvents
        )
    }

    @objc private func eventHandler(_ sender: UIControl) {
        guard let output = callback?(sender) else { return }
        scheduler.schedule {
            _ = self.subscriber?.receive(output) // unlimited
        }
    }
    
    func request(_ demand: Subscribers.Demand) {
        // unlimited
    }
    
    func cancel() {
        self.callback = nil
        self.subscriber = nil
    }
}
