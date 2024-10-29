//
//  UIButton+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/29/24.
//

import UIKit
import Combine

extension CombineReactive where Base: UIButton {
    public func title(for controlState: UIControl.State = []) -> Binder<String?> {
        Binder(self.base) { button, title in
            button.setTitle(title, for: controlState)
        }
    }

    public func image(for controlState: UIControl.State = []) -> Binder<UIImage?> {
        Binder(self.base) { button, image in
            button.setImage(image, for: controlState)
        }
    }

    public func backgroundImage(for controlState: UIControl.State = []) -> Binder<UIImage?> {
        Binder(self.base) { button, image in
            button.setBackgroundImage(image, for: controlState)
        }
    }
    
    public func attributedTitle(for controlState: UIControl.State = []) -> Binder<NSAttributedString?> {
        return Binder(self.base) { button, attributedTitle -> Void in
            button.setAttributedTitle(attributedTitle, for: controlState)
        }
    }
}
