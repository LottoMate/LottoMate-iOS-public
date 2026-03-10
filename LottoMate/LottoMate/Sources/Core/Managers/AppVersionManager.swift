//
//  AppVersionManager.swift
//  LottoMate
//
//  Created by Mirae on 10/13/25.
//

import Foundation

enum UpdateType {
    case none           // 업데이트 불필요
    case recommended    // 선택적 업데이트
    case forced         // 강제 업데이트
}

class AppVersionManager {
    static let shared = AppVersionManager()
    private init() {}
    
    /// 테스트용 버전으로 사용 후 nil 로 되돌리기
    static let testVersion: String? = nil
    
    /*
     테스트 시나리오:
     기준 업데이트 데이터 - forceUpdateVersion: "1.0.1", recommendedVersion: "1.0.3"
     
     testVersion
     1. 강제 업데이트 테스트: "1.0.0" (1.0.1보다 낮음)
     2. 선택 업데이트 테스트: "1.0.2" (1.0.3보다 낮지만 1.0.1보다 높음)
     3. 업데이트 없음 테스트: "1.0.4" (둘 다보다 높음)
     4. 실제 앱 버전 사용: nil (Bundle에서 가져옴)
     */
    
    static func getCurrentAppVersion() -> String? {
        if let testVersion = testVersion {
            // 테스트용 버전이 설정되어 있으면 테스트용 버전 사용
            return testVersion
        }
        
        // 실제 앱 버전 정보 사용
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    // MARK: - Version Comparison
    
    /// 버전 비교: version1 < version2 이면 true
    static func isVersion(_ version1: String, lessThan version2: String) -> Bool {
        return version1.compare(version2, options: .numeric) == .orderedAscending
    }
    
    /// 업데이트 타입 확인
    static func checkUpdateType(
        currentVersion: String,
        forceUpdateVersion: String,
        recommendedVersion: String
    ) -> UpdateType {
        // 강제 업데이트 체크
        if isVersion(currentVersion, lessThan: forceUpdateVersion) {
            print("🔴 강제 업데이트 필요: 현재 \(currentVersion) < 강제 \(forceUpdateVersion)")
            return .forced
        }
        
        // 선택적 업데이트 체크
        if isVersion(currentVersion, lessThan: recommendedVersion) {
            print("🟡 선택적 업데이트 권장: 현재 \(currentVersion) < 권장 \(recommendedVersion)")
            return .recommended
        }
        
        // 업데이트 불필요
        print("🟢 업데이트 불필요: 현재 \(currentVersion)")
        return .none
    }
    
    /// 현재 앱 버전으로 업데이트 타입 확인
    func checkCurrentUpdateType(
        forceUpdateVersion: String,
        recommendedVersion: String
    ) -> UpdateType {
        guard let currentVersion = Self.getCurrentAppVersion() else {
            print("⚠️ 현재 앱 버전을 가져올 수 없습니다.")
            return .none
        }
        
        return Self.checkUpdateType(
            currentVersion: currentVersion,
            forceUpdateVersion: forceUpdateVersion,
            recommendedVersion: recommendedVersion
        )
    }
}
