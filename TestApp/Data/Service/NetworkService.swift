//
//  NetworkService.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/20/24.
//

import Foundation

protocol NetworkService {
    func request<ResponseType: Decodable>(by urlRequest: URLRequest, responseType: ResponseType.Type) async throws -> ResponseWrapper<ResponseType>
}

final class DefaultNetworkService: NetworkService {
    func request<ResponseType: Decodable>(by urlRequest: URLRequest, responseType: ResponseType.Type) async throws -> ResponseWrapper<ResponseType> {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
            return try JSONDecoder().decode(ResponseWrapper<ResponseType>.self, from: data)
        } else if let response = response as? HTTPURLResponse {
            throw NetworkError.abnormalHTTPStatusCode(code: response.statusCode)
        } else {
            throw NetworkError.unknown
        }
    }
}
