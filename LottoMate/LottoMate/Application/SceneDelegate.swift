//
//  SceneDelegate.swift
//  LottoMate
//
//  Created by Mirae on 7/23/24.
//

import UIKit
import RxSwift
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let disposeBag = DisposeBag()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        // 스플래시 화면을 초기 화면으로 설정
        let splashViewController = SplashViewController()
        window?.rootViewController = splashViewController
        window?.makeKeyAndVisible()
        
        // 앱 시작 시간 기록
        let startTime = Date()
        
        // 앱 업데이트 체크 (Remote Config 가져오기)
        UpdateCheckService.shared.checkUpdateOnAppLaunch(window: window) { [weak self] isForcedUpdate in
            // Remote Config 체크 완료 후, 강제 업데이트가 아닐 때만 메인 화면으로 전환
            if !isForcedUpdate {
                // 최소 2.8초는 스플래시 화면을 보여주되, 이미 2.8초가 지났으면 바로 전환
                let elapsedTime = Date().timeIntervalSince(startTime)
                let remainingTime = max(0, 2.8 - elapsedTime)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + remainingTime) { [weak self] in
                    self?.showMainScreen()
                }
            }
            // 강제 업데이트인 경우, showMainScreen()을 호출하지 않음
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let tag = 987654
            let statusBarManager = windowScene.statusBarManager
            let statusBarFrame = statusBarManager?.statusBarFrame ?? .zero
            let statusBarView = UIView(frame: statusBarFrame)
            statusBarView.backgroundColor = .commonNavBar
            statusBarView.tag = tag
            window.addSubview(statusBarView)
        }
        
        // 맵 로딩 뷰 (MapViewController로 이동)
        // LoadingViewManager.shared.showLoading()
    }
    
    // 메인 화면으로 전환하는 메소드
    private func showMainScreen() {
        let onboardingManager = OnboardingManager.shared
        
        if !onboardingManager.isOnboardingCompleted() {
            // 온보딩이 완료되지 않았으면 온보딩 화면 표시
            let onboardingVC = OnboardingViewController()
            
            // 애니메이션과 함께 화면 전환
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.window?.rootViewController = onboardingVC
            }, completion: { [weak self] _ in
                self?.setupStatusBar(true)
                // 화면 전환 완료 후 선택적 업데이트 팝업 표시
                UpdateCheckService.shared.showRecommendedUpdateIfNeeded()
            })
            
        } else if !onboardingManager.isPermissionGuideCompleted() {
            // 온보딩은 완료했지만 권한 안내가 완료되지 않았으면 권한 안내 화면 표시
            let permissionVC = PermissionGuideVC()
            
            // 애니메이션과 함께 화면 전환
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.window?.rootViewController = permissionVC
            }, completion: { [weak self] _ in
                self?.setupStatusBar(true)
                // 화면 전환 완료 후 선택적 업데이트 팝업 표시
                UpdateCheckService.shared.showRecommendedUpdateIfNeeded()
            })
            
        } else {
            // 온보딩, 권한 안내 모두 완료되었으면 메인 탭바로 이동
            let tabBarController = TabBarViewController()
//            let tabBarController = NumberEntryViewController()
            
            // 네비게이션 컨트롤러 설정
            let navigationController = UINavigationController(rootViewController: tabBarController)
            navigationController.setNavigationBarHidden(true, animated: false)
            navigationController.navigationBar.isTranslucent = false
            
            // 애니메이션과 함께 화면 전환
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.window?.rootViewController = navigationController
            }, completion: { [weak self] _ in
                self?.setupStatusBar(true)
                // 화면 전환 완료 후 선택적 업데이트 팝업 표시
                UpdateCheckService.shared.showRecommendedUpdateIfNeeded()
            })
        }
    }
    
    // 상태바 설정을 위한 메소드 (코드 중복 제거)
    private func setupStatusBar(_ completed: Bool) {
        // 상태바 설정을 위한 딜레이
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let tag = 987654
            
            // 기존 상태바 뷰가 있으면 제거
            if let existingStatusBarView = window.viewWithTag(tag) {
                existingStatusBarView.removeFromSuperview()
            }
            
            // 새로운 상태바 뷰 추가
            let statusBarManager = windowScene.statusBarManager
            let statusBarFrame = statusBarManager?.statusBarFrame ?? .zero
            let statusBarView = UIView(frame: statusBarFrame)
            statusBarView.backgroundColor = .commonNavBar
            statusBarView.tag = tag
            window.addSubview(statusBarView)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        LocationManager.shared.checkAuthorizationStatus()
        
        // 앱이 포어그라운드로 돌아올 때 업데이트 체크
        // (강제 업데이트가 아닐 때만 - 이미 강제 업데이트 화면이면 다시 체크하지 않음)
        if !UpdateCheckService.shared.isForcedUpdateInProgress {
            UpdateCheckService.shared.checkUpdateOnAppLaunch(window: window)
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

