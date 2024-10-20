//
//  API.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/20/24.
//

protocol APIProtocol {
    var baseURL: String { get }
    var defaultHeaders: [String: String] { get }
}

extension APIProtocol {
    var baseURL: String {
        "https://"
    }
    
    var defaultHeaders: [String: String] {
        [:]
    }
}

enum API: APIProtocol {
    
}
