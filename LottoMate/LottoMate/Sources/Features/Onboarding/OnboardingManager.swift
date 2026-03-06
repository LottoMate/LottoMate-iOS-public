//
//  OnboardingManager.swift
//  LottoMate
//
//  Created by Cursor on 6/14/24.
//

import UIKit

class OnboardingManager {
    // 싱글톤 인스턴스
    static let shared = OnboardingManager()
    
    // UserDefaults 키 상수
    private let onboardingCompletedKey = "hasCompletedOnboarding"
    private let permissionGuideCompletedKey = "permissionGuideCompleted"
    
    private init() {}
    
    // 온보딩이 완료되었는지 확인
    func isOnboardingCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingCompletedKey)
    }
    
    // 온보딩 완료 상태 설정
    func setOnboardingCompleted(_ completed: Bool) {
        UserDefaults.standard.set(completed, forKey: onboardingCompletedKey)
    }
    
    // 권한 안내가 완료되었는지 확인
    func isPermissionGuideCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: permissionGuideCompletedKey)
    }

    // 권한 안내 완료 상태 설정
    func setPermissionGuideCompleted(_ completed: Bool) {
        UserDefaults.standard.set(completed, forKey: permissionGuideCompletedKey)
    }
    
    // 온보딩 상태 리셋 (테스트 용도)
    func resetOnboardingState() {
        UserDefaults.standard.set(false, forKey: onboardingCompletedKey)
        UserDefaults.standard.set(false, forKey: permissionGuideCompletedKey)
    }
    
    // 필요시 온보딩 화면 표시
    func showOnboardingIfNeeded(from viewController: UIViewController, completion: (() -> Void)? = nil) {
        // 온보딩이 완료되지 않았다면 온보딩 화면 표시
        if !isOnboardingCompleted() {
            let onboardingVC = OnboardingViewController()
            onboardingVC.modalPresentationStyle = .fullScreen
            viewController.present(onboardingVC, animated: true, completion: completion)
            return
        }
        
        // 이미 온보딩은 완료했지만 권한 안내가 완료되지 않았다면 권한 안내 화면 표시
        else if !isPermissionGuideCompleted() {
            let permissionVC = PermissionGuideVC()
            permissionVC.modalPresentationStyle = .fullScreen
            viewController.present(permissionVC, animated: true, completion: completion)
            return
        }
        
        // 이미 모든 과정이 완료되었다면 completion 호출
        completion?()
    }
} 
