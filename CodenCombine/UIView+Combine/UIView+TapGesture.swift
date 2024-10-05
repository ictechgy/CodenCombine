//
//  UIView+TapGesture.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/3/24.
//

import UIKit
import Combine

public extension UIView {
    var tapGesture: AnyPublisher<Void, Never> {
        UIViewTapGeturePublisher(view: self)
            .eraseToAnyPublisher()
    }
}

struct UIViewTapGeturePublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never
    
    let view: UIView
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = UIViewTapGestureSubscription(view: self.view, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

final class UIViewTapGestureSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
    private weak var view: UIView?
    private var subscriber: S?
    private var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    init(view: UIView, subscriber: S) {
        self.view = view
        self.subscriber = subscriber
        registerTapGesture()
    }
    
    func request(_ demand: Subscribers.Demand) {
        // unlimited
    }
    
    func cancel() {
        view?.removeGestureRecognizer(tapGestureRecognizer)
        view = nil
        subscriber = nil
    }
    
    private func registerTapGesture() {
        guard let view else { return }
        
        tapGestureRecognizer.addTarget(self, action: #selector(onViewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc
    private func onViewTapped() {
        _ = subscriber?.receive(Void()) // not receive demand
    }
}
