//
//  AnyObject+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 11/10/24.
//

import Foundation
import Combine

// RxSwift methodInvoked를 우회적으로 따라함
public extension CombineReactive where Base: AnyObject {
    func methodInvoked(_ selector: Selector) -> any Publisher<[Any], Never> {
        PassthroughSubject()
    }
}

extension CombineReactive where Base: AnyObject {
    
}
