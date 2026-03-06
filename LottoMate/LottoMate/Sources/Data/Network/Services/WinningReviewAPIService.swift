//
//  ReviewAPIService.swift
//  LottoMate
//
//  Created by Mirae on 12/27/24.
//

import Moya
import RxSwift

struct WinningReviewAPIService {
    private let provider: MoyaProvider<WinningReviewEndpoint> = NetworkProviderFactory.makeProvider(plugins: [NetworkLoggerPlugin()])
    
    func fetchWinningReviewList(reviewNos: [Int]) -> Observable<[WinningReviewListResponse]> {
        return provider.rx.request(.getWinningReviewList(reviewNos: reviewNos))
            .do(onSuccess: { response in
                print("fetchReviewList → Status Code: \(response.statusCode)")
            }, onError: { error in
                print("fetchReviewList → Error: \(error)")
            })
            .filterSuccessfulStatusCodes()
            .map([WinningReviewListResponse].self)
            .asObservable()
    }
    
    /// 당첨 후기 최신 번호 조회
    func fetchWinningReviewMaxNumber() -> Observable<Int> {
        return provider.rx.request(.getWinningReviewMaxNumber)
            .do(onSuccess: { response in
                print("fetchWinningReviewMaxNumber → Status Code: \(response.statusCode)")
            }, onError: { error in
                print("fetchWinningReviewMaxNumber → Error: \(error)")
            })
            .filterSuccessfulStatusCodes()
            .map(Int.self)
            .asObservable()
    }
    
    func fetchWinningReviewDetail(reviewNo: Int) -> Observable<WinningReviewDetailResponse> {
        return provider.rx.request(.getReviewDetail(reviewNumber: reviewNo))
            .do(onSuccess: { response in
                print("fetchReviewDetail → Status Code: \(response.statusCode)")
            }, onError: { error in
                print("fetchReviewDetail → Error: \(error)")
            })
            .filterSuccessfulStatusCodes()
            .map(WinningReviewDetailResponse.self)
            .asObservable()
    }
}
