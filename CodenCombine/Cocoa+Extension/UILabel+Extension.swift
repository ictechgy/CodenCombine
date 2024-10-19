//
//  UILabel+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/20/24.
//

import UIKit

public extension CombineReactive where Base: UILabel {
    var text: Binder<String> {
        Binder(self.base) { uiLabel, text in
            uiLabel.text = text
        }
    }
}
