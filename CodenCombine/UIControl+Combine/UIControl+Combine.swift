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
    
    func controlProperty<T>(
        editingEvents: UIControl.Event,
        getter: @escaping (Base) -> T,
        setter: @escaping (Base, T) -> Void
    ) -> ControlProperty<T> {
        // RxSwift와는 다르게 ControlEvent 재사용
        let source = ControlEvent(
            control: self.base,
            controlEvents: editingEvents,
            callback: { _ in getter(self.base) } // TODO: CombineReactive에 대한 복사 및 base에 대한 참조복사가 당장은 필요 없으나 [weak control = self.base] 를 하려면 옵셔널에 대한 처리 필요
        )
        
        let binder = Binder(base, action: setter)

        return ControlProperty<T>(outbound: source, inbound: binder)
    }
}
