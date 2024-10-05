//
//  UIControl+Event.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/3/24.
//

import UIKit
import Combine

@MainActor
public extension UIControl {
    var onTouchUpInside: AnyPublisher<Void, Never> {
        UIControlEventPublisher(control: self, event: .touchUpInside)
            .eraseToAnyPublisher()
    }
}

struct UIControlEventPublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never
    
    let control: UIControl
    let event: UIControl.Event
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        if control.subscriptionProxy == nil {
            let subscriptionProxy = UIControlEventSubscriptionProxy()
            control.subscriptionProxy = subscriptionProxy
        }
        
        let subscription = UIControlEventSubscription(subscriber: subscriber, control: control, event: event)
        subscriber.receive(subscription: subscription)
        control.subscriptionProxy?.addSubscription(subscription, on: event)
    }
}

final class UIControlEventSubscriptionProxy {
    private var subscriptionMap: [UIControl.Event: any Subscription] = [:]
    
    func addSubscription(_ subscription: any Subscription, on event: UIControl.Event) {
        subscriptionMap[event] = subscription
    }
    
    func removeSubscription(on event: UIControl.Event) {
        subscriptionMap[event] = nil
    }
}

final class UIControlEventSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
    private var subscriber: S?
    
    init(subscriber: S, control: UIControl, event: UIControl.Event) {
        self.subscriber = subscriber
        control.addTarget(self, action: #selector(onEventOccured), for: event)
    }
    
    func request(_ demand: Subscribers.Demand) {
        // unlimited
    }
    
    func cancel() {
        subscriber = nil
    }
    
    @objc
    private func onEventOccured() {
        _ = subscriber?.receive(())
    }
}

extension UIControl.Event: @retroactive Hashable { }

extension UIControl {
    enum AssociatedKeys {
        static var controlSubscriptionProxy = 0
    }
    
    var subscriptionProxy: UIControlEventSubscriptionProxy? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.controlSubscriptionProxy) as? UIControlEventSubscriptionProxy
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.controlSubscriptionProxy, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
