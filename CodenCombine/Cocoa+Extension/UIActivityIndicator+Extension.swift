//
//  UIActivityIndicator+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 11/10/24.
//

import UIKit
import Combine

extension CombineReactive where Base: UIActivityIndicatorView {
    public var isAnimating: Binder<Bool> {
        Binder(self.base) { indicator, isActive in
            if isActive {
                indicator.startAnimating()
            } else {
                indicator.stopAnimating()
            }
        }
    }
}
