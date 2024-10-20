//
//  Error.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/20/24.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case decodingFailed
    case abnormalHTTPStatusCode(code: Int)
    case abnormalResponse(code: Int, message: String?)
    case unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 요청 주소입니다."
        case .decodingFailed:
            return "데이터 변환에 실패하였습니다."
        case .abnormalHTTPStatusCode(code: let code):
            return "불완전한 HTTP 응답 코드입니다. (\(code))"
        case .abnormalResponse(code: let code, message: let message):
            return "요청이 실패하였습니다. (\(code)) - \(message ?? "")"
        case .unknown:
            return "알 수 없는 오류가 발생하였습니다."
        }
    }
}
