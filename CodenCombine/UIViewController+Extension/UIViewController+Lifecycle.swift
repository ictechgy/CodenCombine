//
//  UIViewController+Lifecycle.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/6/24.
//

import UIKit
import Combine

extension UIViewController {
    public var viewWillAppearInvoked: AnyPublisher<Void, Never> {
        if methodDidSwizzled(.viewWillAppear) == false {
            Self.swizzleViewWillAppear()
        }
        
        return self.viewWillAppearSubject.eraseToAnyPublisher()
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
        self.interceptedViewWillAppear(animated: animated)
        self.viewWillAppearSubject.send(())
    }
}

extension UIViewController {
    struct AssociatedKeys {
        private let rawValue: Int
        
        static var viewDidLoad = AssociatedKeys(rawValue: 0)
        static var viewWillAppear = AssociatedKeys(rawValue: 1)
        
        private init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        var originalMethod: Selector? {
            switch self.rawValue {
            case 0:
                return #selector(UIViewController.viewDidLoad)
            case 1:
                return #selector(UIViewController.viewWillAppear)
            default:
                return nil
            }
        }
        
        var swizzledMethod: Selector? {
            switch self.rawValue {
            case 0:
                fatalError("아직 구현되지 않음")
            case 1:
                return #selector(UIViewController.interceptedViewWillAppear)
            default:
                return nil
            }
        }
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
    
    private func methodDidSwizzled(_ associatedKey: AssociatedKeys) -> Bool {
        guard let originalMethodSelector = associatedKey.originalMethod,
              let swizzledMethodSelctor = associatedKey.swizzledMethod else { return false }
        
        return true
    }
}

/*
 기록용 (아래가 아닌가 의심이 되어 기록), C언어 기준
 - selector: 함수의 이름
 - class_getInstanceMethod(<#T##cls: AnyClass?##AnyClass?#>, <#T##name: Selector##Selector#>) -> 함수의 정의
 - class_getMethodImplementation(<#T##cls: AnyClass?##AnyClass?#>, <#T##name: Selector##Selector#>) -> 함수의 구현
 
 swizzling을 했을 때 getInstanceMethod 주소는 그대로였으나 getMethodImplementation 주소는 맞바뀜
*/
