//
//  UITableView+Delegate.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/19/24.
//

import UIKit
import Combine

extension UITableView {
    public func itemSelected(_ didSelectRowAt: @escaping (UITableView, IndexPath) -> Void) -> Cancellable {
        let delegateProxy: CombineUITableViewDelegateProxy
        
        if let delegate = self.delegate, type(of: delegate) != CombineUITableViewDelegateProxy.self {
            fatalError("이미 다른 delegate가 설정되어있습니다.")
            
        } else if let delegate = self.delegate as? CombineUITableViewDelegateProxy {
            delegateProxy = delegate
            delegateProxy.didSelectRowAt = didSelectRowAt
        } else {
            delegateProxy = CombineUITableViewDelegateProxy()
            delegateProxy.didSelectRowAt = didSelectRowAt
            self.delegate = delegateProxy
        }
        
        return AnyCancellable {
            // delegate를 캡쳐해야 함
            _ = delegateProxy
        }
    }
}

final class CombineUITableViewDelegateProxy: NSObject, UITableViewDelegate {
    fileprivate var didSelectRowAt: ((UITableView, IndexPath) -> Void)?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAt?(tableView, indexPath)
    }
}
