//
//  WinningReviewService.swift
//  LottoMate
//
//  Created by Mirae on 12/26/24.
//

import Moya
import Alamofire

enum WinningReviewEndpoint {
    case getWinningReviewList(reviewNos: [Int])
    case getWinningReviewMaxNumber
    case getReviewDetail(reviewNumber: Int)
}

extension WinningReviewEndpoint: TargetType {
    var baseURL: URL {
        if NetworkModeManager.shouldUseMock {
            return URL(string: "https://mock.lottomate.local")!
        }
        
        guard
            let scheme = Bundle.main.object(forInfoDictionaryKey: "ApiServerScheme") as? String,
            let host = Bundle.main.object(forInfoDictionaryKey: "ApiServerHost") as? String,
            let port = Bundle.main.object(forInfoDictionaryKey: "ApiServerPort") as? String,
            let url = URL(string: "\(scheme)://\(host):\(port)")
        else {
            fatalError("API base URL is not set correctly in Info.plist")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getWinningReviewList:
            return "/review/list"
        case .getWinningReviewMaxNumber:
            return "/review/max"
        case .getReviewDetail(reviewNumber: let reviewNumber):
            return "/review/\(reviewNumber)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getWinningReviewList:
            return .get
        case .getWinningReviewMaxNumber:
            return .get
        case .getReviewDetail(reviewNumber: let reviewNumber):
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getWinningReviewList(let reviewNos):
            let parameters = ["reviewNoList": reviewNos]
            return .requestParameters(
                parameters: parameters,
                encoding: ArrayEncoding())
        
        case .getWinningReviewMaxNumber:
            return .requestPlain
        case .getReviewDetail(reviewNumber: let reviewNumber):
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    var sampleData: Data {
        switch self {
        case .getWinningReviewList:
            return Data(
                """
                [
                  {
                    "reviewNo": 1201,
                    "reviewHref": 1201,
                    "reviewTitle": "꾸준히 샀던 로또가 1등 됐어요",
                    "reviewThumb": "https://example.com/review-1201.jpg",
                    "intrvDate": "2026-02-20",
                    "reviewPlace": "로또 1등"
                  },
                  {
                    "reviewNo": 1200,
                    "reviewHref": 1200,
                    "reviewTitle": "연금복권 1,2등 동시 당첨 후기",
                    "reviewThumb": "https://example.com/review-1200.jpg",
                    "intrvDate": "2026-02-13",
                    "reviewPlace": "연금복권 1등"
                  },
                  {
                    "reviewNo": 1199,
                    "reviewHref": 1199,
                    "reviewTitle": "스피또 당첨 인터뷰",
                    "reviewThumb": null,
                    "intrvDate": "2026-02-07",
                    "reviewPlace": "스피또 1등"
                  }
                ]
                """.utf8
            )
        case .getWinningReviewMaxNumber:
            return Data("1201".utf8)
        case .getReviewDetail(let reviewNumber):
            return Data(
                """
                {
                  "reviewNo": \(reviewNumber),
                  "reviewHref": \(reviewNumber),
                  "reviewTitle": "Mock 당첨 후기 상세 \(reviewNumber)",
                  "reviewCont": "<div><span>Mock 데이터 기반 상세 내용입니다.</span></div>",
                  "reviewThumb": "https://example.com/review-\(reviewNumber).jpg",
                  "reviewImg": [
                    "https://example.com/review-\(reviewNumber)-1.jpg",
                    "https://example.com/review-\(reviewNumber)-2.jpg"
                  ],
                  "intrvDate": "2026-02-20",
                  "reviewDate": "2026-02-21",
                  "lottoDrwNo": 1160,
                  "storeNo": 1001,
                  "storeAddr": "서울 강남구 테헤란로 100"
                }
                """.utf8
            )
        }
    }
}

struct ArrayEncoding: ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try URLEncoding().encode(urlRequest, with: parameters)
        
        guard let parameters = parameters else { return request }
        guard let url = request.url else { return request }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            let queryItems = parameters.flatMap { (key, value) -> [URLQueryItem] in
                if let array = value as? [Any] {
                    return array.map { URLQueryItem(name: key, value: "\($0)") }
                }
                return [URLQueryItem(name: key, value: "\(value)")]
            }
            urlComponents.queryItems = queryItems
            request.url = urlComponents.url
        }
        
        return request
    }
}
