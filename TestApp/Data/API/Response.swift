//
//  Response.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/20/24.
//

struct ResponseWrapper<WrappedData: Decodable>: Decodable {
    let statusCode: Int
    let data: WrappedData?
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case data
    }
}
