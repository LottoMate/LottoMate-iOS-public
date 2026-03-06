//
//  RemoteConfigManager.swift
//  LottoMate
//
//  Created by Mirae on 2025
//

import Foundation
import RxSwift


enum RemoteConfigKey: String {
    /// 강제 업데이트 버전
    case forceUpdateVersion
    /// 선택 업데이트 버전
    case recommendedVersion
}

/**
 * 공개용 버전에서는 로컬 설정값(Info.plist)을 기반으로 업데이트 버전을 관리합니다.
 */
class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    
    private let configValues: [String: String]
    
    private init() {
        let fallback = "1.0.0"
        configValues = [
            RemoteConfigKey.forceUpdateVersion.rawValue:
                (Bundle.main.object(forInfoDictionaryKey: "ForceUpdateVersion") as? String) ?? fallback,
            RemoteConfigKey.recommendedVersion.rawValue:
                (Bundle.main.object(forInfoDictionaryKey: "RecommendedUpdateVersion") as? String) ?? fallback
        ]
    }
    
    /// 공개용 구현에서는 로컬 값 사용으로 항상 성공합니다.
    func fetchAndActivate() -> Single<Bool> {
        return .just(true)
    }
    
    /// String 값 가져오기
    func getString(for key: RemoteConfigKey) -> String {
        let value = configValues[key.rawValue] ?? ""
        print("📱 Remote Config [\(key.rawValue)]: \(value)")
        return value
    }
    
    /// 강제 업데이트 버전
    var forceUpdateVersion: String {
        return getString(for: .forceUpdateVersion)
    }
    
    /// 권장 업데이트 버전
    var recommendedVersion: String {
        return getString(for: .recommendedVersion)
    }
}
