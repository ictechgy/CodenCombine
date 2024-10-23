//
//  ImageService.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/20/24.
//

import Foundation

protocol ImageService {
    var imageSession: URLSession { get }
    
    func request(by urlString: String) async throws -> Data
}

extension ImageService {
    static var defaultConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: 1 * 1024 * 1024 * 3, diskCapacity: 1 * 1024 * 1024 * 10)
        
        return configuration
    }
}

final class DefaultImageService: ImageService {
    private(set) lazy var imageSession = URLSession(configuration: Self.defaultConfiguration)
    
    func request(by urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await imageSession.data(from: url)
        
        if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
            return data
        } else if let response = response as? HTTPURLResponse {
            throw NetworkError.abnormalHTTPStatusCode(code: response.statusCode)
        } else {
            throw NetworkError.unknown
        }
    }
}
