//
//  UIDatePicker+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 11/10/24.
//

import UIKit
import Combine

public extension CombineReactive where Base: UIDatePicker {
    var value: ControlProperty<Date> {
        return base.cx.controlPropertyWithDefaultEvents(
            getter: { datePicker in
                datePicker.date
            }, setter: { datePicker, value in
                datePicker.date = value
            }
        )
    }
    
    var countDownDuration: ControlProperty<TimeInterval> {
        return base.cx.controlPropertyWithDefaultEvents(
            getter: { datePicker in
                datePicker.countDownDuration
            }, setter: { datePicker, value in
                datePicker.countDownDuration = value
            }
        )
    }
}
