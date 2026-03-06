//
//  SpeetoWinningInfoService.swift
//  LottoMate
//
//  Created by Mirae on 3/11/25.
//

import Moya
import RxSwift

class SpeetoWinningInfoService {
    
    static let shared = SpeetoWinningInfoService()
    
    private let provider: MoyaProvider<LottoMateEndpoint> = NetworkProviderFactory.makeProvider(plugins: [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    ])
    private let disposeBag = DisposeBag()
    
    private init() {}
    
    /// 스피또 당첨 정보를 조회합니다.
    /// - Parameters:
    ///   - lottoType: 스피또 유형 (S500, S1000, S2000)
    ///   - page: 페이지 번호 (기본값: 1)
    ///   - size: 페이지당 항목 수 (기본값: 10)
    /// - Returns: 스피또 당첨 정보 응답 Observable
    func getSpeetoWinningInfo(lottoType: String, page: Int, size: Int = 10) -> Observable<SpeetoWinningInfoResponse> {
        return provider.rx
            .request(.getSpeetoWinningInfo(lottoType: lottoType, page: page, size: size))
            .filterSuccessfulStatusCodes()
            .map(SpeetoWinningInfoResponse.self)
            .asObservable()
            .catch { error in
                print("스피또 당첨 정보 조회 실패: \(error.localizedDescription)")
                return Observable.error(error)
            }
    }
}
