//
//  CancellableBag.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/26/24.
//

import Foundation
import Combine

/// Thread safe한 CancellableBag
/// ``Set<AnyCancellable>`` 과 같은 형태로 Collection에 Cancellable을 그냥 저장하는 경우 -> data race 문제가 발생할 수 있음
public extension Cancellable {
    func store(in bag: CancellableBag) {
        bag.insert(self)
    }
}

public final class CancellableBag {
    private var cancellables: [Cancellable] = []
    private var isCancelled = false
    private let lock = NSRecursiveLock()
    
    public func insert(_ cancellable: Cancellable) {
        self._insert(cancellable)?.cancel()
    }
    
    private func _insert(_ cancellable: Cancellable) -> Cancellable? {
        lock.lock()
        defer { lock.unlock() }
        
        if self.isCancelled {
            return cancellable
        } else {
            cancellables.append(cancellable)
            
            return nil
        }
    }
    
    private func cancel() {
        self._cancel().forEach { $0.cancel() }
    }
    
    private func _cancel() -> [Cancellable] {
        lock.lock()
        defer { lock.unlock() }
        
        let cancellables = self.cancellables
        
        self.cancellables.removeAll(keepingCapacity: false)
        self.isCancelled = true
        
        return cancellables
    }
    
    deinit {
        self.cancel()
    }
}
