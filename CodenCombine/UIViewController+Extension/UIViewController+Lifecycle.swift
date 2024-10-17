//
//  UIViewController+Lifecycle.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/6/24.
//

import UIKit
import Combine

extension UIViewController {
    public var viewDidLoadInvoked: AnyPublisher<Void, Never> {
        let key = LifeCycleAssociatedKeys.viewDidLoad
        if methodDidSwizzled(key) == false {
            Self.swizzle(key)
        }
        
        return self.publisher(identifiedBy: key)
    }
    
    public var viewWillAppearInvoked: AnyPublisher<Void, Never> {
        let key = LifeCycleAssociatedKeys.viewWillAppear
        if methodDidSwizzled(key) == false {
            Self.swizzle(key)
        }
        
        return self.publisher(identifiedBy: key)
    }
    
    public var viewDidAppearInvoked: AnyPublisher<Void, Never> {
        let key = LifeCycleAssociatedKeys.viewDidAppear
        if methodDidSwizzled(key) == false {
            Self.swizzle(key)
        }
        
        return self.publisher(identifiedBy: key)
    }
    
    public var viewWillDisappearInvoked: AnyPublisher<Void, Never> {
        let key = LifeCycleAssociatedKeys.viewWillDisappear
        if methodDidSwizzled(key) == false {
            Self.swizzle(key)
        }
        
        return self.publisher(identifiedBy: key)
    }
    
    public var viewDidDisappearInvoked: AnyPublisher<Void, Never> {
        let key = LifeCycleAssociatedKeys.viewWillDisappear
        if methodDidSwizzled(key) == false {
            Self.swizzle(key)
        }
        
        return self.publisher(identifiedBy: key)
    }
    
    private func publisher(identifiedBy associatedKey: LifeCycleAssociatedKeys) -> AnyPublisher<Void, Never> {
        switch associatedKey {
        case .viewDidLoad: return self[lifecycleKey: .viewDidLoad].eraseToAnyPublisher()
        case .viewWillAppear: return self[lifecycleKey: .viewWillAppear].eraseToAnyPublisher()
        case .viewDidAppear: return self[lifecycleKey: .viewDidAppear].eraseToAnyPublisher()
        case .viewWillDisappear: return self[lifecycleKey: .viewWillDisappear].eraseToAnyPublisher()
        case .viewDidDisappear: return self[lifecycleKey: .viewDidDisappear].eraseToAnyPublisher()
        default:
            fatalError("정의되지 않은 publisher 요청")
        }
    }
}

extension UIViewController {
    // TODO: 다른 프레임워크에 의해 스위즐링 되는 경우를 막거나 탐지해야 함
    private static func swizzle(_ associatedKey: LifeCycleAssociatedKeys) {
        let originalMethodSelector = associatedKey.originalMethodSelector
        let targetMethodSelector = associatedKey.targetMethodSelector
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalMethodSelector),
              let targetMethod = class_getInstanceMethod(UIViewController.self, targetMethodSelector) else {
            return
        }
        
        swizzledMethodsBasket.insert(originalMethodSelector)
        method_exchangeImplementations(originalMethod, targetMethod)
    }
    
    @objc private func interceptedViewDidLoad(animated: Bool) {
        self.interceptedViewDidLoad(animated: animated)
        self[lifecycleKey: .viewDidLoad].send(())
    }
    
    @objc private func interceptedViewWillAppear(animated: Bool) {
        self.interceptedViewWillAppear(animated: animated)
        self[lifecycleKey: .viewWillAppear].send(())
    }
    
    @objc private func interceptedViewDidAppear(animated: Bool) {
        self.interceptedViewDidAppear(animated: animated)
        self[lifecycleKey: .viewDidAppear].send(())
    }
    
    @objc private func interceptedViewWillDisappear(animated: Bool) {
        self.interceptedViewWillDisappear(animated: animated)
        self[lifecycleKey: .viewWillDisappear].send(())
    }
    
    @objc private func interceptedViewDidDisappear(animated: Bool) {
        self.interceptedViewDidDisappear(animated: animated)
        self[lifecycleKey: .viewDidDisappear].send(())
    }
}

extension UIViewController {
    enum AssociatedKeys {
        static var swizzledMethodsBasket = -1
        static var lifecycleSubjectCollection = -2
    }
    
    struct LifeCycleAssociatedKeys: Hashable {
        private let rawValue: Int
        
        static var viewDidLoad = LifeCycleAssociatedKeys(rawValue: 0)
        static var viewWillAppear = LifeCycleAssociatedKeys(rawValue: 1)
        static var viewDidAppear = LifeCycleAssociatedKeys(rawValue: 2)
        static var viewWillDisappear = LifeCycleAssociatedKeys(rawValue: 3)
        static var viewDidDisappear = LifeCycleAssociatedKeys(rawValue: 4)
        
        
        private init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        var originalMethodSelector: Selector {
            switch self.rawValue {
            case Self.viewDidLoad.rawValue: return #selector(UIViewController.viewDidLoad)
            case Self.viewWillAppear.rawValue: return #selector(UIViewController.viewWillAppear)
            case Self.viewDidAppear.rawValue: return #selector(UIViewController.viewDidAppear)
            case Self.viewWillDisappear.rawValue: return #selector(UIViewController.viewWillDisappear)
            case Self.viewDidDisappear.rawValue: return #selector(UIViewController.viewDidDisappear)
            default: fatalError("정의되지 않은 메소드에 대한 동작")
            }
        }
        
        var targetMethodSelector: Selector {
            switch self.rawValue {
            case Self.viewDidLoad.rawValue: return #selector(UIViewController.interceptedViewDidLoad)
            case Self.viewWillAppear.rawValue: return #selector(UIViewController.interceptedViewWillAppear)
            case Self.viewDidAppear.rawValue: return #selector(UIViewController.interceptedViewDidAppear)
            case Self.viewWillDisappear.rawValue: return #selector(UIViewController.interceptedViewWillDisappear)
            case Self.viewDidDisappear.rawValue: return #selector(UIViewController.interceptedViewDidDisappear)
            default: fatalError("정의되지 않은 메소드에 대한 동작")
            }
        }
    }
    
    private var lifecycleSubjectCollection: [LifeCycleAssociatedKeys: PassthroughSubject<Void, Never>] {
        get {
            if let associatedObject = objc_getAssociatedObject(self, &AssociatedKeys.lifecycleSubjectCollection) as? [LifeCycleAssociatedKeys: PassthroughSubject<Void, Never>] {
                return associatedObject
            } else {
                let lifecycleSubjectCollection = [LifeCycleAssociatedKeys: PassthroughSubject<Void, Never>]()
                self.lifecycleSubjectCollection = lifecycleSubjectCollection
                return lifecycleSubjectCollection
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lifecycleSubjectCollection, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    subscript (lifecycleKey associatedKey: LifeCycleAssociatedKeys) -> PassthroughSubject<Void, Never> {
        get {
            if let subject = lifecycleSubjectCollection[associatedKey] {
                return subject
            } else {
                let subject = PassthroughSubject<Void, Never>()
                lifecycleSubjectCollection[associatedKey] = subject
                return subject
            }
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
        Self.swizzledMethodsBasket.contains(associatedKey.originalMethodSelector)
    }
}

/*
 기록용 (아래가 아닌가 의심이 되어 기록), C언어 기준
 - selector: 함수의 이름
 - class_getInstanceMethod(<#T##cls: AnyClass?##AnyClass?#>, <#T##name: Selector##Selector#>) -> 함수의 정의
 - class_getMethodImplementation(<#T##cls: AnyClass?##AnyClass?#>, <#T##name: Selector##Selector#>) -> 함수의 구현
 
 swizzling을 했을 때 getInstanceMethod 주소는 그대로였으나 getMethodImplementation 주소는 맞바뀜
*/
