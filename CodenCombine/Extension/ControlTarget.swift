//
//  ControlTarget.swift
//  CodenCombine
//
//  Created by JINHONG AN on 11/3/24.
//

import UIKit
import Combine

final class ControlTarget: Subscription {
    typealias Callback = (UIControl) -> Void

    private var callback: Callback?
    
    init(control: UIControl, controlEvents: UIControl.Event, callback: @escaping Callback) {
        self.callback = callback

        control.addTarget(
            self,
            action: #selector(ControlTarget.eventHandler),
            for: controlEvents
        )
    }

    @objc private func eventHandler(_ sender: UIControl) {
        callback?(sender)
    }
    
    func request(_ demand: Subscribers.Demand) {
        // unlimited
    }
    
    func cancel() {
        self.callback = nil
    }
}
