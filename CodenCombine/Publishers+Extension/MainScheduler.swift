//
//  MainScheduler.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/8/24.
//

import Foundation
import Combine

public struct MainScheduler: Scheduler {
    public typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    public typealias SchedulerOptions = DispatchQueue.SchedulerOptions
    
    public static let instance = MainScheduler(alwaysAync: false)
    public static let asyncInstance = MainScheduler(alwaysAync: true)
    
    private let alwaysAync: Bool
    
    public var now: DispatchQueue.SchedulerTimeType {
        DispatchQueue.main.now
    }
    public var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
        DispatchQueue.main.minimumTolerance
    }
    
    private init(alwaysAync: Bool) {
        self.alwaysAync = alwaysAync
    }
    
    // FIXME: 재귀 방어 필요
    public func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
        if DispatchQueue.isCurrentQueueMain && alwaysAync == false {
            action()
        } else {
            DispatchQueue.main.schedule(options: options, action)
        }
    }
    
    public func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
        DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
    }
    
    public func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> any Cancellable {
        DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
    }
}
