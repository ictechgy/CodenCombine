//
//  NetworkService.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/20/24.
//

import Foundation

final class DefaultNetworkService {
    func request<ResponseType: Decodable>(by urlRequest: URLRequest, responseType: ResponseType.Type) -> ResponseWrapper<ResponseType> {
        fatalError()
    }
}
