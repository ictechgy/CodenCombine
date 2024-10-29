//
//  UIRefreshControl+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/29/24.
//

import UIKit
import Combine

public extension CombineReactive where Base: UIRefreshControl {
    var isRefreshing: Binder<Bool> {
        return Binder(self.base) { refreshControl, refresh in
            if refresh {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        }
    }
}
