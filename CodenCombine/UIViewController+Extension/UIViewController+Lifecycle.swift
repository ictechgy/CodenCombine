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
    // TODO: 다른 프레임워크에 의해 스위즐링 되는 경우를 막거나 탐지해야 함
    private static func swizzleViewWillAppear() {
        let originalMethodSelector = #selector(viewWillAppear)
        let targetMethodSelector = #selector(interceptedViewWillAppear)
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalMethodSelector),
              let targetMethod = class_getInstanceMethod(UIViewController.self, targetMethodSelector) else {
            return
        }
        
        swizzledMethodsBasket.insert(originalMethodSelector)
        method_exchangeImplementations(originalMethod, targetMethod)
    }
    
    @objc private func interceptedViewWillAppear(animated: Bool) {
        self.interceptedViewWillAppear(animated: animated)
        self.viewWillAppearSubject.send(())
    }
}

extension UIViewController {
    enum AssociatedKeys {
        static var swizzledMethodsBasket = -1
    }
    
    struct LifeCycleAssociatedKeys {
        private let rawValue: Int
        
        static var viewDidLoad = LifeCycleAssociatedKeys(rawValue: 0)
        static var viewWillAppear = LifeCycleAssociatedKeys(rawValue: 1)
        
        private init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        var methodSelector: Selector {
            switch self.rawValue {
            case Self.viewDidLoad.rawValue: return #selector(UIViewController.viewDidLoad)
            case Self.viewWillAppear.rawValue: return #selector(UIViewController.viewWillAppear)
            default: fatalError("정의되지 않은 메소드에 대한 동작")
            }
        }
    }
    
    var viewWillAppearSubject: PassthroughSubject<Void, Never> {
        get {
            if let associatedObject = objc_getAssociatedObject(self, &LifeCycleAssociatedKeys.viewWillAppear) as? PassthroughSubject<Void, Never> {
                return associatedObject
            } else {
                let viewWillAppearSubject = PassthroughSubject<Void, Never>()
                self.viewWillAppearSubject = viewWillAppearSubject
                return viewWillAppearSubject
            }
        }
        set {
            objc_setAssociatedObject(self, &LifeCycleAssociatedKeys.viewWillAppear, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static var swizzledMethodsBasket: Set<Selector> {
        get {
            if let associatedSet = objc_getAssociatedObject(self, &AssociatedKeys.swizzledMethodsBasket) as? Set<Selector> {
                return associatedSet
            } else {
                let associatedSet = Set<Selector>()
                self.swizzledMethodsBasket = associatedSet
                return associatedSet
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.swizzledMethodsBasket, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func methodDidSwizzled(_ associatedKey: LifeCycleAssociatedKeys) -> Bool {
        Self.swizzledMethodsBasket.contains(associatedKey.methodSelector)
    }
}

/*
 기록용 (아래가 아닌가 의심이 되어 기록), C언어 기준
 - selector: 함수의 이름
 - class_getInstanceMethod(<#T##cls: AnyClass?##AnyClass?#>, <#T##name: Selector##Selector#>) -> 함수의 정의
 - class_getMethodImplementation(<#T##cls: AnyClass?##AnyClass?#>, <#T##name: Selector##Selector#>) -> 함수의 구현
 
 swizzling을 했을 때 getInstanceMethod 주소는 그대로였으나 getMethodImplementation 주소는 맞바뀜
*/
