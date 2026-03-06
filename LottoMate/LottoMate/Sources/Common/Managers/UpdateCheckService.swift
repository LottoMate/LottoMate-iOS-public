//
//  UpdateCheckService.swift
//  LottoMate
//
//  Created by Mirae on 2025
//

import UIKit
import RxSwift

struct UpdateVersionConfig {
    let forceUpdateVersion: String
    let recommendedVersion: String
    
    static var fallback: UpdateVersionConfig {
        let currentVersion = AppVersionManager.getCurrentAppVersion() ?? "1.0.0"
        return UpdateVersionConfig(
            forceUpdateVersion: currentVersion,
            recommendedVersion: currentVersion
        )
    }
}

protocol UpdateConfigProviding {
    func fetchUpdateConfig() -> Single<UpdateVersionConfig>
}

final class LocalUpdateConfigProvider: UpdateConfigProviding {
    func fetchUpdateConfig() -> Single<UpdateVersionConfig> {
        let forceVersion = Bundle.main.object(forInfoDictionaryKey: "ForceUpdateVersion") as? String
        let recommendedVersion = Bundle.main.object(forInfoDictionaryKey: "RecommendedUpdateVersion") as? String
        let fallback = UpdateVersionConfig.fallback
        
        return .just(
            UpdateVersionConfig(
                forceUpdateVersion: forceVersion ?? fallback.forceUpdateVersion,
                recommendedVersion: recommendedVersion ?? fallback.recommendedVersion
            )
        )
    }
}

class UpdateCheckService {
    static let shared = UpdateCheckService()
    
    private let disposeBag = DisposeBag()
    private let updateConfigProvider: UpdateConfigProviding
    private var currentUpdateType: UpdateType = .none
    private var currentUpdateConfig: UpdateVersionConfig = .fallback
    
    // TODO: App Store URL (실제 앱 ID로 변경 필요) - 애플 개발자 프로그램 결제 후 앱 등록하면 받을 수 있음
    private let appStoreURL = "itms-apps://itunes.apple.com/app/id123456789"
    
    /// 강제 업데이트 진행 중인지 여부
    private(set) var isForcedUpdateInProgress: Bool = false
    
    /// 선택적 업데이트가 필요한지 여부 (메인 화면 전환 후 팝업 표시용)
    private var shouldShowRecommendedUpdate: Bool = false
    
    private init(updateConfigProvider: UpdateConfigProviding = LocalUpdateConfigProvider()) {
        self.updateConfigProvider = updateConfigProvider
    }
    
    // MARK: - Public Methods
    
    /// 앱 시작 시 업데이트 체크 및 UI 표시
    func checkUpdateOnAppLaunch(window: UIWindow?, completion: ((Bool) -> Void)? = nil) {
        updateConfigProvider.fetchUpdateConfig()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] config in
                self?.currentUpdateConfig = config
                self?.handleUpdateCheck(window: window, isAppLaunch: true)
                // 강제 업데이트 여부를 completion으로 전달
                completion?(self?.isForcedUpdateInProgress ?? false)
            }, onFailure: { [weak self] error in
                print("❌ Update config load failed on app launch: \(error.localizedDescription)")
                // 에러 발생 시에도 completion 호출 (false로)
                self?.isForcedUpdateInProgress = false
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    /// 수동으로 업데이트 체크 (HomeView에서 사용)
    func checkUpdate() -> UpdateType {
        let updateType = AppVersionManager.shared.checkCurrentUpdateType(
            forceUpdateVersion: currentUpdateConfig.forceUpdateVersion,
            recommendedVersion: currentUpdateConfig.recommendedVersion
        )
        
        currentUpdateType = updateType
        return updateType
    }
    
    /// 현재 업데이트 타입 반환
    func getCurrentUpdateType() -> UpdateType {
        return currentUpdateType
    }
    
    /// 앱스토어로 이동
    func openAppStore() {
        guard let url = URL(string: appStoreURL),
              UIApplication.shared.canOpenURL(url) else {
            print("❌ Cannot open App Store URL")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    /// 메인 화면 전환 완료 후 선택적 업데이트 팝업 표시
    func showRecommendedUpdateIfNeeded() {
        if shouldShowRecommendedUpdate {
            shouldShowRecommendedUpdate = false
            // 메인 화면이 완전히 로드된 후 1초 뒤에 팝업 표시
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.showRecommendedUpdateAlert(window: nil)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleUpdateCheck(window: UIWindow?, isAppLaunch: Bool) {
        let updateType = checkUpdate()
        
        switch updateType {
        case .forced:
            // 강제 업데이트: ForcedAppUpdateVC 전체 화면 표시
            isForcedUpdateInProgress = true
            shouldShowRecommendedUpdate = false
            showForcedUpdateScreen(window: window)
            
        case .recommended:
            // 선택적 업데이트: 플래그만 설정 (메인 화면 전환 후 표시)
            isForcedUpdateInProgress = false
            if isAppLaunch {
                shouldShowRecommendedUpdate = true
            } else {
                // 앱 시작이 아닌 경우(포그라운드 복귀 등)는 바로 표시
                showRecommendedUpdateAlert(window: window)
            }
            
        case .none:
            // 업데이트 불필요
            isForcedUpdateInProgress = false
            shouldShowRecommendedUpdate = false
            break
        }
    }
    
    private func showForcedUpdateScreen(window: UIWindow?) {
        DispatchQueue.main.async {
            let forcedUpdateVC = ForcedAppUpdateVC()
            
            // 기존 rootViewController를 강제 업데이트 화면으로 교체
            if let window = window {
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = forcedUpdateVC
                })
            }
        }
    }
    
    private func showRecommendedUpdateAlert(window: UIWindow?) {
        DispatchQueue.main.async { [weak self] in
            guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                return
            }
            
            let alertView = OptionalUpdateAlertView.show(in: windowScene)
            
            // "이대로 사용" 버튼 클릭 시
            alertView.onSkip = {
                // 팝업이 자동으로 dismiss 되므로 추가 동작 없음
                print("✅ 선택적 업데이트 건너뜀")
            }
            
            // "스토어로 이동" 버튼 클릭 시
            alertView.onGoToStore = { [weak self] in
                self?.openAppStore()
            }
        }
    }
    
    /// 현재 최상위 ViewController 찾기
    private func getTopViewController(from rootViewController: UIViewController?) -> UIViewController? {
        guard let rootVC = rootViewController else { return nil }
        
        if let presented = rootVC.presentedViewController {
            return getTopViewController(from: presented)
        }
        
        if let navigationController = rootVC as? UINavigationController {
            return getTopViewController(from: navigationController.visibleViewController)
        }
        
        if let tabBarController = rootVC as? UITabBarController {
            return getTopViewController(from: tabBarController.selectedViewController)
        }
        
        return rootVC
    }
}
