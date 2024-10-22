//
//  UIView+TapGesture.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/3/24.
//

import UIKit
import Combine

enum GestureRecognizerType {
    case tap
    case pan
    case swipe
    
    var instance: UIGestureRecognizer {
        switch self {
        case .tap:
            return UITapGestureRecognizer()
        case .pan:
            return UIPanGestureRecognizer()
        case .swipe:
            return UISwipeGestureRecognizer()
        }
    }
}

public extension UIView {
    // TODO: 함수로 구현하여 커스터마이징의 가능성을 열어주는게 좋아보임 
    var tapGesture: AnyPublisher<Void, Never> {
        UIViewGeturePublisher(view: self, gestureRecognizerType: .tap)
            .eraseToAnyPublisher()
    }
    
    var panGesture: AnyPublisher<Void, Never> {
        UIViewGeturePublisher(view: self, gestureRecognizerType: .pan)
            .eraseToAnyPublisher()
    }
    
    var swipeGesture: AnyPublisher<Void, Never> {
        UIViewGeturePublisher(view: self, gestureRecognizerType: .swipe)
            .eraseToAnyPublisher()
    }
}

struct UIViewGeturePublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never
    
    let view: UIView
    let gestureRecognizerType: GestureRecognizerType
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = UIViewGestureSubscription(view: self.view, gestureRecognizerType: gestureRecognizerType, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

final class UIViewGestureSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
    private weak var view: UIView?
    private var subscriber: S?
    private var gestureRecognizer: UIGestureRecognizer
    
    init(view: UIView, gestureRecognizerType: GestureRecognizerType, subscriber: S) {
        self.view = view
        self.gestureRecognizer = gestureRecognizerType.instance
        self.subscriber = subscriber
        registerTapGesture()
    }
    
    func request(_ demand: Subscribers.Demand) {
        // unlimited
    }
    
    func cancel() {
        view?.removeGestureRecognizer(gestureRecognizer)
        view = nil
        subscriber = nil
    }
    
    private func registerTapGesture() {
        guard let view else { return }
        
        gestureRecognizer.addTarget(self, action: #selector(onViewTapped))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc
    private func onViewTapped() {
        _ = subscriber?.receive(Void()) // not receive demand
    }
}
