//
//  CombineReactive.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/20/24.
//

import Foundation

public struct CombineReactive<Base> {
    public let base: Base
}

// referenced by RxSwift Compatible
public protocol CombineCompatible {
    /// 확장하고자 하는 타입
    associatedtype ReactiveBase
    
    var cx: CombineReactive<ReactiveBase> { get }
}

extension CombineCompatible {
    public var cx: CombineReactive<Self> {
        CombineReactive(base: self)
    }
}

extension NSObject: CombineCompatible { }
