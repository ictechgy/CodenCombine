//
//  DispatchQueue+Extension.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/9/24.
//

import Foundation

// 현재 실행중인 DispatchQueue context를 알아내기 위한 extension
extension DispatchQueue {
    private static let defaultKey = DispatchSpecificKey<UUID>()
    
    var id: UUID {
        if let uuid = getSpecific(key: Self.defaultKey) {
            return uuid
        } else {
            let uuid = UUID()
            setSpecific(key: Self.defaultKey, value: uuid)
            return uuid
        }
    }
    
    static var currentRunningQueueId: UUID? {
        getSpecific(key: Self.defaultKey)
    }
    
    static var isCurrentQueueMain: Bool {
        DispatchQueue.main.id == currentRunningQueueId
    }
}
