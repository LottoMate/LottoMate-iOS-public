//
//  LottoMateClient.swift
//  LottoMate
//
//  Created by Mirae on 8/19/24.
//

import Moya
import RxSwift

class LottoMateAPIService {
    let provider: MoyaProvider<LottoMateEndpoint> = NetworkProviderFactory.makeProvider()

    /// 최신 로또 정보 조회 (홈)
    func getLottoHome() -> Observable<LatestLotteryWinningInfoModel> {
//        return provider.rx.request(.googleSigninStateTest)
        return provider.rx.request(.getLottoHome)
            .do(onSuccess: { response in
//                print("Status Code: \(response.statusCode)")
//                print("Response: \(String(describing: try? response.mapJSON()))")
            }, onError: { error in
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .statusCode(let response):
                        print("Error Status Code: \(response.statusCode)")
                        print("Error Response: \(String(describing: try? response.mapJSON()))")
                    default:
                        print("Network Error: \(error.localizedDescription)")
                    }
                }
            })
            .filterSuccessfulStatusCodes()
            .map(LatestLotteryWinningInfoModel.self)
            .asObservable()
    }
    
    /// 로또 회차별 정보 조회 (645)
    func getLottoResult(round: Int) -> Observable<LottoResultModel> {
        return provider.rx.request(.getLottoResult(round: round))
            .filterSuccessfulStatusCodes()
            .map(LottoResultModel.self)
            .asObservable()
    }
    
    /// 연금복권 회차별 정보 조회
    func getPensionLotteryResult(round: Int) -> Observable<PensionLotteryResultModel> {
        return provider.rx.request(.getPensionLotteryResult(round: round))
            .filterSuccessfulStatusCodes()
            .map(PensionLotteryResultModel.self)
            .asObservable()
    }
}
