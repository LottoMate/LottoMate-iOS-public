//
//  LottoMateEndpoint.swift
//  LottoMate
//
//  Created by Mirae on 8/11/24.
//

import Foundation
import Moya

enum NetworkMode: String {
    case live = "live"
    case mock = "mock"
}

enum NetworkModeManager {
    static var currentMode: NetworkMode {
        guard
            let rawValue = Bundle.main.object(forInfoDictionaryKey: "DataMode") as? String,
            let mode = NetworkMode(rawValue: rawValue.lowercased())
        else {
            return .mock
        }
        return mode
    }
    
    static var shouldUseMock: Bool {
        currentMode == .mock
    }
}

enum NetworkProviderFactory {
    static func makeProvider<T: TargetType>(plugins: [PluginType] = []) -> MoyaProvider<T> {
        let stubClosure: MoyaProvider<T>.StubClosure = NetworkModeManager.shouldUseMock
            ? MoyaProvider.immediatelyStub
            : MoyaProvider.neverStub
        
        return MoyaProvider<T>(
            stubClosure: stubClosure,
            plugins: plugins
        )
    }
}

enum LottoMateEndpoint {
    /// 로또 회차별 정보 조회
    case getLottoResult(round: Int)
    /// 최신 로또 정보 조회 (홈)
    case getLottoHome
    /// 연금 복권 회차별 정보 조회
    case getPensionLotteryResult(round: Int)
    /// 스피또 당첨 정보 조회
    case getSpeetoWinningInfo(lottoType: String, page: Int = 1, size: Int = 10)
    /// 테스트 용 - 삭제 필요
    case googleSigninStateTest
    /// 백엔드 서버에서 구글 로그인 토큰 검증 후 JWT 토큰을 가져옵니다.
    case googleTokenSignIn(idToken: String)
    /// 내 로또 번호 저장
    case createMyLottoNumbers(lottoNum: [Int], lottoType: String, lottoDrwNo: String)
}

extension LottoMateEndpoint: TargetType {
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
        case .getLottoResult(let round):
            return "lottoInfo/645/\(round)"
        case .getLottoHome:
            return "/lottoInfo/home"
        case .getPensionLotteryResult(let round):
            return "lottoInfo/720/\(round)"
        case .getSpeetoWinningInfo:
            return "/storeLottoDrw"
        case .googleSigninStateTest:
            return "/lottoInfo/home" // 테스트용 path로 수정 필요
        case .googleTokenSignIn:
            return "/login/oauth2/code/google"
        case .createMyLottoNumbers:
            return "/my-lotto-numbers"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getLottoResult(_):
            return .get
        case .getLottoHome:
            return .get
        case .getPensionLotteryResult(_):
            return .get
        case .getSpeetoWinningInfo:
            return .get
        case .googleSigninStateTest:
            return .get
        case .googleTokenSignIn:
            return .post
        case .createMyLottoNumbers:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getLottoResult(_):
            return .requestPlain
        
        case .getLottoHome:
            return .requestPlain
            
        case .getPensionLotteryResult(_):
            return .requestPlain
            
        case .getSpeetoWinningInfo(lottoType: let lottoType, page: let page, size: let size):
            let parameters: [String: Any] = [
                "lottoType": lottoType,
                "page": page,
                "size": size
            ]
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
            
        case .googleSigninStateTest:
            return .requestPlain
            
        case .googleTokenSignIn:
            return .requestPlain
//            let parameters: [String: Any] = ["idToken": idToken]
//            return .requestParameters(
//                parameters: parameters,
//                encoding: URLEncoding.queryString
//            )
            
        case .createMyLottoNumbers(let lottoNum, let lottoType, let lottoDrwNo):
            let parameters: [String: Any] = [
                "lottoNum": lottoNum,
                "lottoType": lottoType,
                "lottoDrwNo": lottoDrwNo
            ]
            return .requestParameters(
                parameters: parameters,
                encoding: JSONEncoding.default
            )
        }
    }
    
    var headers: [String : String]? {
        var headers = ["Content-type": "application/json"]
        
        switch self {
        case .googleSigninStateTest:
            if let token = TokenManager.shared.getToken() {
                headers["Authorization"] = "Bearer \(token)"
            }
        case .googleTokenSignIn(idToken: let idToken):
            headers = ["Authorization": "Bearer \(idToken)"]
        default:
            break
        }
        return headers
    }
    
    var sampleData: Data {
        switch self {
        case .getLottoHome, .googleSigninStateTest:
            let model = LatestLotteryWinningInfoModel(
                the645: The645(
                    lottoDrwNo: 1160,
                    lottoType: "L645",
                    lottoNum: [3, 11, 15, 29, 35, 44],
                    lottoBonusNum: [10],
                    drwDate: "2026-03-01",
                    drwNum: 1160,
                    totalSalesPrice: 83500000000,
                    p1Jackpot: 23450000000,
                    p1WinnrCnt: 12,
                    p2Jackpot: 4560000000,
                    p2WinnrCnt: 78,
                    p3Jackpot: 5670000000,
                    p3WinnrCnt: 3200,
                    p4Jackpot: 1200000000,
                    p4WinnrCnt: 145000,
                    p5Jackpot: 800000000,
                    p5WinnrCnt: 2400000
                ),
                the720: The720(
                    lottoDrwNo: 260,
                    lottoType: "L720",
                    lottoNum: [5, 2, 1, 8, 7, 4, 9],
                    lottoBonusNum: [],
                    drwDate: "2026-03-01",
                    drwNum: 260,
                    p1WinnrCnt: 1,
                    p2WinnrCnt: 4,
                    p3WinnrCnt: 12,
                    p4WinnrCnt: 120,
                    p5WinnrCnt: 1220,
                    p6WinnrCnt: 11200,
                    p7WinnrCnt: 48000,
                    p8WinnrCnt: 130000
                ),
                message: "Success",
                code: 200
            )
            return encodeMockData(model)
            
        case .getLottoResult(let round):
            let result = LottoResultModel(
                lottoResult: LottoResult(
                    lottoDrwNo: round,
                    lottoType: "L645",
                    lottoNum: [3, 11, 15, 29, 35, 44],
                    lottoBonusNum: [10],
                    drwDate: "2026-03-01",
                    drwNum: round,
                    totalSalesPrice: 83500000000,
                    p1Jackpot: 23450000000,
                    p1WinnrCnt: 12,
                    p1PerJackpot: 1954166666,
                    p2Jackpot: 4560000000,
                    p2WinnrCnt: 78,
                    p2PerJackpot: 58461538,
                    p3Jackpot: 5670000000,
                    p3WinnrCnt: 3200,
                    p3PerJackpot: 1771875,
                    p4Jackpot: 1200000000,
                    p4WinnrCnt: 145000,
                    p4PerJackpot: 50000,
                    p5Jackpot: 800000000,
                    p5WinnrCnt: 2400000,
                    p5PerJackpot: 5000
                ),
                message: "Success",
                code: 200
            )
            return encodeMockData(result)
            
        case .getPensionLotteryResult(let round):
            let result = PensionLotteryResultModel(
                pensionLotteryResult: PensionLotteryResult(
                    lottoDrwNo: round,
                    lottoType: "L720",
                    lottoNum: [5, 2, 1, 8, 7, 4, 9],
                    lottoBonusNum: [],
                    drwDate: "2026-03-01",
                    drwNum: round,
                    p1WinnrCnt: 1,
                    p2WinnrCnt: 4,
                    p3WinnrCnt: 12,
                    p4WinnrCnt: 120,
                    p5WinnrCnt: 1220,
                    p6WinnrCnt: 11200,
                    p7WinnrCnt: 48000,
                    p8WinnrCnt: 130000
                ),
                message: "Success",
                code: 200
            )
            return encodeMockData(result)
            
        case .getSpeetoWinningInfo:
            let result = SpeetoWinningInfoResponse(
                message: "Success",
                code: 200,
                storeLottoDrwInfoSpeeto: StoreLottoDrwInfoSpeeto(
                    pageNum: 1,
                    pageSize: 10,
                    totalPages: 1,
                    totalElements: 3,
                    content: [
                        SpeetoWinningStore(payDate: "2026-02-20", drwNum: 63, reviewHref: "1234", place: 1, storeNm: "행운복권방"),
                        SpeetoWinningStore(payDate: "2026-02-13", drwNum: 63, reviewHref: "1235", place: 2, storeNm: "로또명당"),
                        SpeetoWinningStore(payDate: "2026-02-09", drwNum: 62, reviewHref: nil, place: 2, storeNm: "행복스토어")
                    ]
                )
            )
            return encodeMockData(result)
            
        case .googleTokenSignIn:
            return Data("mock-jwt-token".utf8)
            
        case .createMyLottoNumbers:
            return Data("{}".utf8)
        }
    }
}

private func encodeMockData<T: Encodable>(_ model: T) -> Data {
    (try? JSONEncoder().encode(model)) ?? Data()
}
