import Foundation

/// 소셜 로그인 관련 기능을 관리하는 클래스
class SocialLoginManager {
    // 싱글톤 인스턴스
    static let shared = SocialLoginManager()
    
    // UserDefaults에 저장할 키
    private let recentLoginTypeKey = "recentSocialLoginType"
    
    private init() {}
    
    /// 최근 로그인 타입 가져오기
    func getRecentLoginType() -> SocialLoginType? {
        // UserDefaults에서 저장된 로그인 타입 문자열 가져오기
        guard let loginTypeString = UserDefaults.standard.string(forKey: recentLoginTypeKey) else {
            return nil
        }
        
        // 문자열을 SocialLoginType으로 변환
        return SocialLoginType(rawValue: loginTypeString) ?? mockRecentLoginType()
    }
    
    /// 최근 로그인 타입 설정
    func setRecentLoginType(_ type: SocialLoginType) {
        // UserDefaults에 로그인 타입 저장
        UserDefaults.standard.set(type.rawValue, forKey: recentLoginTypeKey)
    }
    
    /// 저장된 로그인 정보 삭제
    func clearRecentLoginType() {
        UserDefaults.standard.removeObject(forKey: recentLoginTypeKey)
    }
    
    // MARK: - Temporary Mock Implementation
    
    /// 임시 구현: 랜덤한 소셜 로그인 타입 반환 (테스트용)
    func mockRecentLoginType() -> SocialLoginType {
        let types = SocialLoginType.allCases
        let randomIndex = Int.random(in: 0..<types.count)
        return types[randomIndex]
    }
    
    /// 임시 구현: 서버에서 최근 로그인 정보 가져오기 (향후 실제 API로 대체)
    func fetchRecentLoginFromServer(completion: @escaping (SocialLoginType?) -> Void) {
        // 실제로는 서버 API를 호출하여 최근 로그인 정보를 가져올 예정
        // 임시로 1초 딜레이 후 랜덤 데이터 반환
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // 50% 확률로 로그인 정보 있음, 50% 확률로 없음 (테스트용)
            let hasLoginInfo = Bool.random()
            
            if hasLoginInfo {
                let loginType = self.mockRecentLoginType()
                self.setRecentLoginType(loginType) // 정보 저장
                completion(loginType)
            } else {
                completion(nil)
            }
        }
    }
} 