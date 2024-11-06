//
//  UIControl+Combine.swift
//  CodenCombine
//
//  Created by JINHONG AN on 11/4/24.
//

import Combine
import UIKit

public extension CombineReactive where Base: UIControl {
    func controlEvent(_ controlEvents: UIControl.Event) -> ControlEvent<()> {
        // RxSwift의 Observable.create를 따라하지 않고 책임을 재분배하여 구현
        ControlEvent(
            control: self.base,
            controlEvents: controlEvents) { _ in
                ()
            }
    }
}
