//
//  ImageService.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/20/24.
//

import Foundation

final class DefaultImageService {
    static let defaultConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: 1 * 1024 * 1024 * 1, diskCapacity: 1 * 1024 * 1024 * 1)
        
        return configuration
    }()
    
    func request(by urlString: String, with configuration: URLSessionConfiguration = defaultConfiguration) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession(configuration: Self.defaultConfiguration).data(from: url)
        
        if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
            return data
        } else if let response = response as? HTTPURLResponse {
            throw NetworkError.abnormalHTTPStatusCode(code: response.statusCode)
        } else {
            throw NetworkError.unknown
        }
    }
}
