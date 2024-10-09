//
//  CurrentValueSubject+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/10/24.
//

import Combine

protocol ValueAccessiblePublisher: Publisher, AnyObject {
    associatedtype Output
    var value: Output { get }
}

extension CurrentValueSubject: ValueAccessiblePublisher { }
