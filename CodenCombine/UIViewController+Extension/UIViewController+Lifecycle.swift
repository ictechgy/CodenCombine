//
//  UIViewController+Lifecycle.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/6/24.
//

import UIKit
import Combine

extension UIViewController {
    public var viewWillAppearPublisher: AnyPublisher<Void, Never> {
        self.viewWillAppearSubject.eraseToAnyPublisher()
    }
}

extension UIViewController {
    private static func swizzleViewWillAppear() {
        let originalMethodSelector = #selector(viewWillAppear)
        let targetMethodSelector = #selector(interceptedViewWillAppear)
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalMethodSelector),
              let targetMethod = class_getInstanceMethod(UIViewController.self, targetMethodSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, targetMethod)
    }
    
    @objc private func interceptedViewWillAppear(animated: Bool) {
        self.viewWillAppear(animated)
        self.viewWillAppearSubject.send(())
    }
}

extension UIViewController {
    enum AssociatedKeys {
        static var viewDidLoad = 0
        static var viewWillAppear = 1
    }
    
    var viewWillAppearSubject: PassthroughSubject<Void, Never> {
        get {
            if let associatedObject = objc_getAssociatedObject(self, &AssociatedKeys.viewWillAppear) as? PassthroughSubject<Void, Never> {
                return associatedObject
            } else {
                let viewWillAppearSubject = PassthroughSubject<Void, Never>()
                self.viewWillAppearSubject = viewWillAppearSubject
                return viewWillAppearSubject
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.viewWillAppear, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

