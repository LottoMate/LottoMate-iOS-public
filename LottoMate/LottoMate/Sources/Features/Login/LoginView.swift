//
//  LoginView.swift
//  LottoMate
//
//  Created by Mirae on 10/3/24.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxGesture

class LoginView: UIView {
    fileprivate let rootFlexContainer = UIView()
    let viewModel = LoginViewModel.shared
    let disposeBag = DisposeBag()
    
    let titleLabel = UILabel()
    let titleImage = UIImageView()
    let bodyLabel = UILabel()
    let kakaoLoginButton = UIImageView()
    let naverLoginButton = UIImageView()
    let googleLoginButton = UIImageView()
    var appleLoginButton = CircularAppleSignInButton()
    
    let tooltip = CustomTooltip(text: "최근 로그인했어요", position: .top)
    // 현재 표시중인 툴팁의 로그인 타입
    private var currentTooltipLoginType: SocialLoginType?
    
    init() {
        super.init(frame: .zero)
        signInButtonTapped()
        
        backgroundColor = .white
        
        titleLabel.text = "로또 당첨을 위해\r로또메이트와 함께!"
        titleLabel.numberOfLines = 2
        styleLabel(for: titleLabel, fontStyle: .title2, textColor: .black)
        
        bodyLabel.text = "가장 편한 방법으로 로그인하고\r로또메이트에서 더 많은 행운을 불러오세요."
        bodyLabel.numberOfLines = 2
        styleLabel(for: bodyLabel, fontStyle: .body1, textColor: .gray100)
        
        
        if let image = UIImage(named: "ch_loginView") {
            titleImage.image = image
            titleImage.contentMode = .scaleAspectFit
        }
        
        if let kakaoBtnImage = UIImage(named: "login_Kakao") {
            kakaoLoginButton.image = kakaoBtnImage
            kakaoLoginButton.contentMode = .scaleAspectFit
        }
        if let naverBtnImage = UIImage(named: "login_Naver") {
            naverLoginButton.image = naverBtnImage
            naverLoginButton.contentMode = .scaleAspectFit
        }
        if let googleBtnImage = UIImage(named: "login_Google") {
            googleLoginButton.image = googleBtnImage
            googleLoginButton.contentMode = .scaleAspectFit
        }
        
        tooltip.setAutoHide(enabled: false)
        tooltip.alpha = 1
        tooltip.isHidden = true
        
        showTooltipForSocialLogin(type: .kakao) // 서버 데이터 연동 전 임시
        
        addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.column).define { flex in
            flex.addItem(titleLabel)
                .marginTop(82)
            flex.addItem(titleImage)
                .width(317)
                .height(200)
                .marginTop(118)
                .marginHorizontal(29)
            flex.addItem(bodyLabel)
                .marginTop(64)
            flex.addItem().direction(.row)
                .gap(20)
                .marginTop(20)
                .alignSelf(.center)
                .define { flex in
                    flex.addItem(kakaoLoginButton).size(40)
                    flex.addItem(naverLoginButton).size(40)
                    flex.addItem(googleLoginButton).size(40)
                    flex.addItem(appleLoginButton).size(40)
                }
            flex.addItem(tooltip)
                .width(98)
                .height(36)
                .position(.absolute)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        // 툴팁 위치 업데이트 (현재 타입이 있는 경우)
        if let loginType = currentTooltipLoginType {
            updateTooltipPosition(for: loginType)
        } else {
            tooltip.isHidden = true // 로그인 타입이 없으면 툴팁 숨김
        }
    }
    
    func signInButtonTapped() {
        googleLoginButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.viewModel.googleSignIn()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Tooltip Methods
    /// 특정 소셜 로그인 타입에 대한 툴팁 표시
    func showTooltipForSocialLogin(type: SocialLoginType) {
        currentTooltipLoginType = type
        
        // 툴팁 텍스트 업데이트 - 통일된 메시지 사용
        tooltip.setText("최근 로그인했어요")
        
        // 위치 업데이트
        updateTooltipPosition(for: type)
        
        // 툴팁 표시
        tooltip.isHidden = false
    }
    
    /// 툴팁 숨기기
    func hideTooltip() {
        currentTooltipLoginType = nil
        tooltip.isHidden = true
    }
    
    /// 소셜 로그인 타입에 따라 툴팁 위치 업데이트
    private func updateTooltipPosition(for loginType: SocialLoginType) {
        switch loginType {
        case .kakao:
            tooltip.pin.below(of: kakaoLoginButton, aligned: .center).marginTop(12)
        case .naver:
            tooltip.pin.below(of: naverLoginButton, aligned: .center).marginTop(12)
        case .google:
            tooltip.pin.below(of: googleLoginButton, aligned: .center).marginTop(12)
        case .apple:
            tooltip.pin.below(of: appleLoginButton, aligned: .center).marginTop(12)
        }
    }
}

#Preview {
    let view = LoginView()
    return view
}
