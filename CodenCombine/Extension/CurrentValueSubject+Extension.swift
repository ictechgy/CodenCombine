//
//  CurrentValueSubject+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/10/24.
//

import Combine

public protocol ValueAccessiblePublisher<Output>: Publisher, AnyObject {
    var value: Output { get }
}

extension CurrentValueSubject: ValueAccessiblePublisher {
    public func eraseToValueAccessiblePublisher() -> ValueAccessiblePublisher<Output> {
        self
    }
}
