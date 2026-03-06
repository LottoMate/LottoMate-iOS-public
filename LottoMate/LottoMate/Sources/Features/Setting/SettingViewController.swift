//
//  SettingViewController.swift
//  LottoMate
//
//  Created by Mirae on 12/13/24.
//

import UIKit

class SettingViewController: BaseViewController {
    
    private let settingView: SettingView = {
        let view = SettingView()
        return view
    }()
    
    override func loadView() {
        view = settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupNavBar()
        setupDelegate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 화면이 나타날 때 최근 로그인 정보를 확인하고 툴팁 표시
        fetchAndShowRecentLoginTooltip()
    }
    
    private func setupDelegate() {
        settingView.delegate = self
    }
    
    private func setupNavBar() {
        let config = NavBarConfiguration(
            style: .backButtonWithTitle,
            title: "설정",
            buttonTintColor: .gray100
        )
        configureNavBar(config)
    }
    
    /// 최근 로그인 정보를 가져와 툴팁 표시
    private func fetchAndShowRecentLoginTooltip() {
        // 로컬에서 바로 가져오기 (임시 구현, 나중에는 서버에서 가져올 예정)
        if let recentLoginType = SocialLoginManager.shared.getRecentLoginType() {
            // 로컬에 저장된 최근 로그인 정보가 있으면 바로 표시
            settingView.showTooltipForSocialLogin(type: recentLoginType)
        } else {
            // 로컬에 저장된 정보가 없는 경우 서버에서 가져오기 (현재는 모의 구현)
            SocialLoginManager.shared.fetchRecentLoginFromServer { [weak self] loginType in
                guard let self = self else { return }
                
                if let loginType = loginType {
                    // 최근 로그인 정보가 있으면 툴팁 표시
                    self.settingView.showTooltipForSocialLogin(type: loginType)
                } else {
                    // 최근 로그인 정보가 없으면 툴팁 숨김
                    self.settingView.hideTooltip()
                }
            }
        }
    }
    
    /// 소셜 로그인 동작 수행 (실제 로그인 구현은 추후에 구현될 예정)
    private func performSocialLogin(type: SocialLoginType) {
        // TODO: 실제 소셜 로그인 로직 구현 (SDK 호출 등)
        
        // 로그인 성공 가정 (임시 구현)
        // 실제 구현에서는 로그인 성공 콜백에서 아래 로직을 수행해야 함
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // 최근 로그인 정보 저장
            SocialLoginManager.shared.setRecentLoginType(type)
            
            // 툴팁 표시
            self.settingView.showTooltipForSocialLogin(type: type)
        }
    }
    
    @objc override func leftButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // 로그아웃 처리 공통 함수
    private func handleLogout() {
        // 로그인 상태 업데이트
        settingView.isLoggedIn = false
        
        // 추가적인 로그아웃 로직이 필요하다면 여기에 구현
        print("로그아웃 처리 완료")
    }
}

// MARK: - SettingViewDelegate
extension SettingViewController: SettingViewDelegate {
    func didTapLogin() {
        print("didTapLogin")
    }
    
    func didTapLogout() {
        handleLogout()
    }
    
    func didTapMyAccount() {
        let myAccountVC = MyAccountViewController()
        navigationController?.pushViewController(myAccountVC, animated: true)
    }
    
    func didTapSocialLogin(type: SocialLoginType) {
        // 소셜 로그인 수행
        performSocialLogin(type: type)
    }
    
    func didUpdateNickname(nickname: String) {
        // Handle nickname update
        print("Nickname updated to: \(nickname)")
        
        // Here you would typically update the nickname in your user model or API
        // For example:
        // UserManager.shared.updateUserNickname(nickname)
    }
    
}

#Preview {
    SettingViewController()
}
