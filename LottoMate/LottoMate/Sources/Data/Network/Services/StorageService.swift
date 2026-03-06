//
//  StorageService.swift
//  LottoMate
//
//  Created by Mirae on 6/29/25.
//

import Foundation
import Moya
import RxSwift

class StorageService {
    
    static let shared = StorageService()
    
    private let provider: MoyaProvider<LottoMateEndpoint> = NetworkProviderFactory.makeProvider(plugins: [
        NetworkLoggerPlugin(configuration: .init(
            formatter: .init(
                requestData: { data in
                    if let jsonString = String(data: data, encoding: .utf8) {
                        return "🔵 Request Body:\n\(jsonString)"
                    }
                    return "🔵 Request Body: \(data)"
                },
                responseData: { data in
                    if let jsonString = String(data: data, encoding: .utf8) {
                        return "🟢 Response Body:\n\(jsonString)"
                    }
                    return "🟢 Response Body: \(data)"
                }
            ),
            logOptions: .verbose
        ))
    ])
    private let disposeBag = DisposeBag()
    
    private init() {}
    
    /// 내 로또 번호를 저장합니다.
    /// - Parameters:
    ///   - lottoNum: 로또 번호 배열 [1, 2, 3, 4, 5, 6]
    ///   - lottoType: 로또 타입 ("L645" 등)
    ///   - lottoDrwNo: 로또 회차 번호
    /// - Returns: 저장 결과 Observable
    func createMyLottoNumbers(lottoNum: [Int], lottoType: String, lottoDrwNo: String) -> Observable<Void> {
        return provider.rx
            .request(.createMyLottoNumbers(lottoNum: lottoNum, lottoType: lottoType, lottoDrwNo: lottoDrwNo))
            .do(onSuccess: { response in
                print("[StorageService] createMyLottoNumbers status: \(response.statusCode)")
            }, onError: { error in
                print("[StorageService] request failed: \(error.localizedDescription)")
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .statusCode(let response):
                        print("[StorageService] status code: \(response.statusCode)")
                    case .underlying(let underlyingError, let response):
                        print("[StorageService] underlying error: \(underlyingError.localizedDescription)")
                        if let response = response {
                            print("[StorageService] status code: \(response.statusCode)")
                        }
                    default:
                        print("[StorageService] moya error: \(moyaError.localizedDescription)")
                    }
                }
            })
            .filterSuccessfulStatusCodes()
            .map { _ in () } // 성공 시 Void 반환
            .asObservable()
            .catch { error in
                print("내 로또 번호 저장 실패: \(error.localizedDescription)")
                return Observable.error(error)
            }
    }
}
