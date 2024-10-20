//
//  Endpoint.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/20/24.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

enum DataType {
    case queryParameters([String: Any])
    case json(Data)
}

struct Endpoint {
    let urlString: String
    let method: HTTPMethod
    let headers: [String: String]?
    let dataType: DataType?
}

extension Endpoint {
    func toURLRequest() throws -> URLRequest {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        if let dataType {
            switch dataType {
            case .queryParameters(let parameters):
                let queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url?.append(queryItems: queryItems)
            case .json(let data):
                request.httpBody = data
            }
        }
        
        return request
    }
}
