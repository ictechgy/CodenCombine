//
//  API.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/20/24.
//

protocol APIProtocol {
    var baseURL: String { get }
    var defaultHeaders: [String: String] { get }
    var additionalPath: String { get }
    var httpMethod: HTTPMethod { get }
    var additionalHeaders: [String: String] { get }
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
    case example
    
    var additionalPath: String {
        switch self {
        case .example: return ""
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .example: return .get
        }
    }
    
    var additionalHeaders: [String : String] {
        [:]
    }
}

extension API {
    func toEndpoint(with dataType: DataType? = nil) -> Endpoint {
        Endpoint(
            urlString: baseURL + additionalPath,
            method: httpMethod,
            headers: defaultHeaders.merging(additionalHeaders, uniquingKeysWith: { $1 }),
            dataType: dataType
        )
    }
}
