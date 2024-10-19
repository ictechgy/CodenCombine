//
//  UITableView+Delegate.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/19/24.
//

import UIKit
import Combine

extension UITableView {
    public func itemSelected<Source: ValueAccessiblePublisher>(with source: Source, _ didSelectRowAt: @escaping (UITableView, IndexPath, Source.Output) -> Void) -> Cancellable {
        let delegateProxy: CombineUITableViewDelegateProxy<Source>
        
        if let delegate = self.delegate, type(of: delegate) != CombineUITableViewDelegateProxy<Source>.self {
            fatalError("이미 다른 delegate가 설정되어있습니다.")
            
        } else if let delegate = self.delegate as? CombineUITableViewDelegateProxy<Source> {
            delegateProxy = delegate
            delegateProxy.didSelectRowAt = didSelectRowAt
        } else {
            delegateProxy = CombineUITableViewDelegateProxy(valueAccessiblePublisher: source)
            delegateProxy.didSelectRowAt = didSelectRowAt
            self.delegate = delegateProxy
        }
        
        return AnyCancellable {
            // delegate를 캡쳐해야 함
            _ = delegateProxy
        }
    }
}

final class CombineUITableViewDelegateProxy<ValueAccessibleSource: ValueAccessiblePublisher>: NSObject, UITableViewDelegate {
    fileprivate var valueAccessiblePublisher: ValueAccessibleSource
    fileprivate var didSelectRowAt: ((UITableView, IndexPath, ValueAccessibleSource.Output) -> Void)?
    
    init(valueAccessiblePublisher: ValueAccessibleSource) {
        self.valueAccessiblePublisher = valueAccessiblePublisher
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAt?(tableView, indexPath, valueAccessiblePublisher.value)
    }
}
