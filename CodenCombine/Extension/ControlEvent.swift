//
//  ControlEvent.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/31/24.
//

import UIKit
import Combine

public struct ControlEvent<PropertyType> : Publisher {
    public typealias Output = PropertyType
    public typealias Failure = Never
    
    let control: UIControl
    let controlEvents: UIControl.Event
    let callback: (UIControl) -> Output
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, PropertyType == S.Input {
        // RxSwift의 ControlEvent 생성형태를 맞추기 위해 Subscription을 ControlEvent 외부에서 생성해서 주입받을 수도 있겠지만 Subscription 생성에 대한 부분은 내부 캡슐화가 좋다고 판단하여 아래와 같이 구현
        let subscription = ControlTarget(
            control: control,
            controlEvents: controlEvents,
            callback: callback,
            subscriber: subscriber
        )
        
        subscriber.receive(subscription: subscription)
    }
}
