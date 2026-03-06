//
//  SettingView.swift
//  LottoMate
//
//  Created by Mirae on 12/13/24.
//

import UIKit
import PinLayout
import FlexLayout

enum SocialLoginType: String, CaseIterable {
    case kakao = "카카오"
    case naver = "네이버"
    case google = "구글"
    case apple = "애플"
}

protocol SettingViewDelegate: AnyObject {
    func didTapMyAccount()
    func didTapLogin()
    func didTapLogout()
    func didUpdateNickname(nickname: String)
    func didTapSocialLogin(type: SocialLoginType)
}

class SettingView: UIView {
    weak var delegate: SettingViewDelegate?
    fileprivate let rootFlexContainer = UIView()
    
    // 로그인 상태를 관리하는 프로퍼티
    var isLoggedIn: Bool = false {
        didSet {
            updateUIForLoginState()
        }
    }
    
    // 유저 닉네임
    var userNickname: String = "무기력한코뿔소" {
        didSet {
            if isLoggedIn {
                rebuildProfileView()
            }
        }
    }
    
    // Nickname popup related properties
    private let dimView = UIView()
    private let nicknamePopupView = UIView()
    private let nicknameTextField = UITextField()
    private let nicknameCountLabel = UILabel()
    private var buttonsContainer: UIView?
    private var underlineView: UIView = UIView()
    private let validationFeedbackLabel = UILabel()
    
    // Validation state enum
    private enum ValidationState {
        case none
        case tooShort
        case validating
        case valid
        case invalid
    }
    
    private var validationState: ValidationState = .none {
        didSet {
            updateValidationFeedback()
        }
    }
    
    // Keyboard height tracking
    private var currentKeyboardHeight: CGFloat = 0
    
    let cancelButton: UIButton = {
        let button = StyledButton(
            title: "취소",
            buttonStyle: .assistive(.large, .active),
            cornerRadius: 8,
            verticalPadding: 12,
            horizontalPadding: 0
        )
        return button
    }()
    
    let confirmButton = StyledButton(
        title: "확인",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    let inactiveConfirmButton = StyledButton(
        title: "확인",
        buttonStyle: .solid(.large, .inactive),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    lazy var confirmButtonContainer: UIView = {
        let view = UIView()
        view.flex.define { flex in
            flex.addItem(confirmButton).width(100%).position(.absolute)
            flex.addItem(inactiveConfirmButton).width(100%).position(.absolute)
        }
        confirmButton.isHidden = false
        inactiveConfirmButton.isHidden = true
        return view
    }()
    
    private let cancelButton1 = UIButton(type: .system)
    private let confirmButton2 = UIButton(type: .system)
    
    private let topMargin: CGFloat = {
        let topMargin = DeviceMetrics.statusWithNavigationBarHeight
        return topMargin
    }()
    
    // 로그인 전 UI 요소
    private let socialLoginTitle: UILabel = {
        let label = UILabel()
        label.text = "소셜 로그인 하기"
        styleLabel(for: label, fontStyle: .body1, textColor: .gray100, alignment: .center)
        return label
    }()
    
    private let kakaoLoginButton = CommonImageView(imageName: "login_Kakao")
    private let naverLoginButton = CommonImageView(imageName: "login_Naver")
    private let googleLoginButton = CommonImageView(imageName: "login_Google")
    private let appleLoginButton = CircularAppleSignInButton()
    
    // 로그인 후 UI 요소
    private let profileContainer = UIView()
    
    private let helloLabel: UILabel = {
        let label = UILabel()
        label.text = "안녕하세요"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black, alignment: .left)
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let penIcon = CommonImageView(imageName: "icon_pen")
    
    private let optionsContainer = UIView()
    private let settingOptions = ["내 계정 관리", "공지사항", "약관 및 정책"]
    
    private let sendInquiryBannerView: UIView = {
        let view = UIView()
        let alertImage = CommonImageView(imageName: "alart_notice")
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "로또메이트에 문의사항이 있다면\r여기로 보내주세요"
        styleLabel(for: label, fontStyle: .body1, textColor: .black, alignment: .left)
        
        view.flex.direction(.row)
            .gap(16)
            .padding(20)
            .backgroundColor(.gray20)
            .cornerRadius(16)
            .define { flex in
                flex.addItem(alertImage)
                    .size(60)
                flex.addItem(label)
            }
        
        return view
    }()
    
    let tooltip = CustomTooltip(text: "최근 로그인했어요", position: .top)
    
    // 현재 표시중인 툴팁의 로그인 타입
    private var currentTooltipLoginType: SocialLoginType?
    
    init() {
        super.init(frame: .zero)
        setupViews()
        
        setupLayout()
        setupOptionRow()
//        setupSocialLoginButtons()
        
        setupNicknamePopup()
        setupKeyboardObservers()
        
        tooltip.setAutoHide(enabled: false)
        tooltip.alpha = 1
        tooltip.isHidden = true
        
        showTooltipForSocialLogin(type: .kakao) // 서버 데이터 연동 전 임시
    }
    
    deinit {
        // Remove keyboard observers when view is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupViews() {
        // Remove all existing subviews first
        rootFlexContainer.subviews.forEach { $0.removeFromSuperview() }
        profileContainer.subviews.forEach { $0.removeFromSuperview() }
        optionsContainer.subviews.forEach { $0.removeFromSuperview() }
        
        // 로그인 버튼에 탭 제스처 추가 (로그인 상태를 임시로 구현)
        [kakaoLoginButton, naverLoginButton, googleLoginButton, appleLoginButton].forEach { button in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLoginTap))
            button.isUserInteractionEnabled = true
            button.addGestureRecognizer(tapGesture)
        }
        
        // Add tap gesture to penIcon
        let penTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNicknameEditTap))
        penIcon.isUserInteractionEnabled = true
        penIcon.addGestureRecognizer(penTapGesture)
        
        // 프로필 컨테이너 설정
        profileContainer.flex
            .direction(.column)
            .paddingTop(36)
            .paddingBottom(20)
            .paddingHorizontal(20)
            .grow(1)
            .define { flex in
                
                flex.addItem(helloLabel)
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .justifyContent(.start)
                    .gap(12)
                    .define { flex in
                        flex.addItem(nicknameLabel)
                        flex.addItem(penIcon)
                            .size(18)
                    }
                
            }
        
        // Ensure we update the layout
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    /// 소셜 로그인 버튼에 탭 제스처 설정
//    private func setupSocialLoginButtons() {
//        // 각 버튼에 탭 제스처 추가
//        addTapGestureToLoginButton(kakaoLoginButton, for: .kakao)
//        addTapGestureToLoginButton(naverLoginButton, for: .naver)
//        addTapGestureToLoginButton(googleLoginButton, for: .google)
//        addTapGestureToLoginButton(appleLoginButton, for: .apple)
//    }
    
    /// 로그인 버튼에 탭 제스처 추가
//    private func addTapGestureToLoginButton(_ button: UIView, for loginType: SocialLoginType) {
//        // 이미 있는 제스처는 제거
//        button.gestureRecognizers?.forEach { button.removeGestureRecognizer($0) }
//
//        // 새로운 탭 제스처 추가
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSocialLoginTap(_:)))
//        button.isUserInteractionEnabled = true
//
//        // 제스처에 로그인 타입 정보 저장 (tag 활용)
//        switch loginType {
//        case .kakao: tapGesture.view?.tag = 0
//        case .naver: tapGesture.view?.tag = 1
//        case .google: tapGesture.view?.tag = 2
//        case .apple: tapGesture.view?.tag = 3
//        }
//
//        button.addGestureRecognizer(tapGesture)
//    }
    
    @objc private func handleSocialLoginTap(_ gesture: UITapGestureRecognizer) {
        guard let tag = gesture.view?.tag, let loginType = SocialLoginType.allCases[safe: tag] else { return }
        
        // 델리게이트에 로그인 이벤트 전달
        delegate?.didTapSocialLogin(type: loginType)
    }
    
    @objc private func handleOptionTap(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        
        switch index {
        case 0:  // "내 계정 관리" 인덱스
            delegate?.didTapMyAccount()
        default:
            break
        }
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
    
    // MARK: - Mock Method (임시 구현)
    
    /// 최근 로그인 정보 기반으로 툴팁 표시 (임시 구현)
    func showMockRecentLoginTooltip() {
        // 임시로 랜덤한 소셜 로그인 선택 (테스트용)
        let randomIndex = Int.random(in: 0..<SocialLoginType.allCases.count)
        let randomType = SocialLoginType.allCases[randomIndex]
        
        // 선택된 로그인 타입에 대한 툴팁 표시
        showTooltipForSocialLogin(type: randomType)
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
    
    private func rebuildProfileView() {
        // Clear previous content
        profileContainer.subviews.forEach { $0.removeFromSuperview() }
        
        // Configure nickname label for sizing
        nicknameLabel.text = "\(userNickname)님"
        nicknameLabel.sizeToFit()
        styleLabel(for: nicknameLabel, fontStyle: .headline1, textColor: .black, alignment: .left)
        
        // 프로필 컨테이너 설정
        profileContainer.flex
            .direction(.column)
            .paddingTop(36)
            .paddingBottom(20)
            .paddingHorizontal(20)
            .grow(1)
            .define { flex in
                
                flex.addItem(helloLabel)
                
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .justifyContent(.start)
                    .gap(12)
                    .define { flex in
                        flex.addItem(nicknameLabel)
                        flex.addItem(penIcon)
                            .size(18)
                    }
                
            }
        
        // Ensure we update the layout
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupLayout() {
        addSubview(rootFlexContainer)
        updateUIForLoginState()
    }
    
    private func updateUIForLoginState() {
        // 기존 하위 뷰 제거
        rootFlexContainer.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        // 로그인 상태에 따라 UI 업데이트
        if isLoggedIn {
            // 로그인 상태일 때 프로필 뷰 다시 그리기
            rebuildProfileView()
            
            rootFlexContainer.flex
                .direction(.column)
                .marginTop(topMargin)
                .justifyContent(.spaceBetween)
                .define { flex in
                    flex.addItem()
                        .direction(.column)
                        .define { flex in
                            flex.addItem(profileContainer)
                            flex.addItem()
                                .height(10)
                                .backgroundColor(.gray20)
                                .marginBottom(8)
                            
                            flex.addItem(optionsContainer)
                                .grow(1)
                        }
                    
                    flex.addItem(sendInquiryBannerView)
                        .marginHorizontal(20)
                        .marginBottom(32.29)
                }
        } else {
            // 로그인 전 상태
            rootFlexContainer.flex
                .direction(.column)
                .marginTop(topMargin)
                .justifyContent(.spaceBetween)
                .define { flex in
                    flex.addItem()
                        .direction(.column)
                        .define { flex in
                            flex.addItem(socialLoginTitle)
                                .marginBottom(12)
                            flex.addItem()
                                .direction(.row)
                                .gap(20)
                                .alignSelf(.center)
                                .marginBottom(28)
                                .define { flex in
                                    flex.addItem(kakaoLoginButton).size(40)
                                    flex.addItem(naverLoginButton).size(40)
                                    flex.addItem(googleLoginButton).size(40)
                                    flex.addItem(appleLoginButton).size(40)
                                }
                            flex.addItem()
                                .height(10)
                                .backgroundColor(.gray20)
                                .marginBottom(8)
                            
                            flex.addItem(tooltip)
                                .width(98)
                                .height(36)
                                .position(.absolute)
                            
                            flex.addItem(optionsContainer)
                                .grow(1)
                        }
                    
                    flex.addItem(sendInquiryBannerView)
                        .marginHorizontal(20)
                        .marginBottom(32.29)
                }
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout()
        
        // 툴팁 위치 업데이트 (현재 타입이 있는 경우)
        if let loginType = currentTooltipLoginType {
            updateTooltipPosition(for: loginType)
        } else {
            tooltip.isHidden = true // 로그인 타입이 없으면 툴팁 숨김
        }
    }
    
    private func setupOptionRow() {
        optionsContainer.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        settingOptions.enumerated().forEach { index, option in
            let rowView = UIView()
            
            let rightArrow = CommonImageView(imageName: "icon_arrow_right_svg")
            rightArrow.tintColor = .gray100
            
            let optionLabel = UILabel()
            optionLabel.text = option
            styleLabel(for: optionLabel, fontStyle: .body1, textColor: .black, alignment: .left)
            
            // Add tap gesture
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOptionTap(_:)))
            rowView.addGestureRecognizer(tapGesture)
            rowView.isUserInteractionEnabled = true
            rowView.tag = index
            
            rowView.flex.direction(.row)
                .justifyContent(.spaceBetween)
                .marginLeft(20)
                .marginRight(13)
                .marginVertical(18)
                .define { flex in
                    flex.addItem(optionLabel)
                    flex.addItem(rightArrow)
                        .size(24)
                }
            
            optionsContainer.flex
                .define { flex in
                    flex.addItem(rowView)
                        .grow(1)
                }
        }
        
        let versionInfoRow = UIView()
        let versionInfoLabel = UILabel()
        versionInfoLabel.text = "버전 정보"
        styleLabel(for: versionInfoLabel, fontStyle: .body1, textColor: .black, alignment: .left)
        
        let versionLabel = UILabel()
        versionLabel.text = "1.08" // version 정보로 교체
        styleLabel(for: versionLabel, fontStyle: .body1, textColor: .red50Default)
        
        let latestVersionLabel = UILabel()
        latestVersionLabel.text = "최신 버전입니다"
        styleLabel(for: latestVersionLabel, fontStyle: .label2, textColor: .red50Default)
        
        let updateButton = StyledButton(title: "업데이트", buttonStyle: .outline(.xs, .active), cornerRadius: 4, verticalPadding: 2, horizontalPadding: 8)
        
        
        versionInfoRow.flex
            .justifyContent(.spaceBetween)
            .direction(.row)
            .marginHorizontal(20)
            .marginVertical(18)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .gap(20)
                    .define { flex in
                        flex.addItem(versionInfoLabel)
                        flex.addItem(versionLabel)
                    }
                flex.addItem(latestVersionLabel)
//                flex.addItem(updateButton)
            }
    
        optionsContainer.flex
            .define { flex in
                flex.addItem(versionInfoRow)
                    .grow(1)
            }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    @objc private func handleLoginTap() {
        delegate?.didTapLogin()
        
        // 임시로 로그인 성공으로 가정
        isLoggedIn = true
        userNickname = "무기력한코뿔소"
    }
    
    @objc private func handleLogoutTap() {
        delegate?.didTapLogout()
        
        // 로그아웃 처리
        isLoggedIn = false
    }
    
    // MARK: - Nickname Popup
    private func setupNicknamePopup() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.alpha = 0
        
        let dimTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCancelTap))
        dimView.addGestureRecognizer(dimTapGesture)
        
        nicknamePopupView.backgroundColor = .white
        nicknamePopupView.layer.cornerRadius = 20 // Mixed로 나타나므로 확인 필요
        nicknamePopupView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        nicknamePopupView.alpha = 0
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        nicknamePopupView.addGestureRecognizer(panGesture)
        
        let titleLabel = UILabel()
        titleLabel.text = "닉네임 수정"
        styleLabel(for: titleLabel, fontStyle: .headline1, textColor: .black, alignment: .left)
        
        nicknameTextField.borderStyle = .none
        nicknameTextField.backgroundColor = .white
        nicknameTextField.font = Typography.body1.font()
        nicknameTextField.textColor = .black
        nicknameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 0))
        nicknameTextField.leftViewMode = .always
        nicknameTextField.placeholder = "2글자 이상 입력"
        nicknameTextField.returnKeyType = .default
        nicknameTextField.delegate = self
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Setup count label
        nicknameCountLabel.text = "0/10"
        styleLabel(for: nicknameCountLabel, fontStyle: .body1, textColor: .gray100, alignment: .right)
        // Prevent text from being truncated
        nicknameCountLabel.adjustsFontSizeToFitWidth = true
        nicknameCountLabel.minimumScaleFactor = 0.8
        nicknameCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Setup validation feedback label
        validationFeedbackLabel.numberOfLines = 1
        validationFeedbackLabel.isHidden = true
        styleLabel(for: validationFeedbackLabel, fontStyle: .label2, textColor: .gray100, alignment: .left)
        
        // Setup buttons
        
        cancelButton.addTarget(self, action: #selector(handleCancelButtonTap), for: .touchUpInside)
        confirmButton.isEnabled = false
        confirmButton.addTarget(self, action: #selector(handleConfirmTap), for: .touchUpInside)
        
        // 밑줄
        underlineView = UIView()
        underlineView.backgroundColor = .gray60
        
        nicknamePopupView.flex.direction(.column)
            .alignItems(.center)
            .width(100%)
            .paddingTop(32)
            .paddingHorizontal(20)
            .paddingBottom(28)  // 키보드 없을 때 기본값
            .define { flex in
                
                flex.addItem(titleLabel)
                    .alignSelf(.start)
                    .marginBottom(28)
                
                // Text field container with count label
                flex.addItem()
                    .direction(.row)
                    .justifyContent(.spaceBetween)
                    .width(100%)
                    .marginBottom(8)
                    .define { flex in
                        flex.addItem(nicknameTextField)
                            .grow(1)
                            .shrink(1)
                        
                        flex.addItem(nicknameCountLabel)
                            .width(50)
                            .shrink(0)
                    }
                
                // 밑줄
                flex.addItem(underlineView)
                    .height(1)
                    .width(100%)
                    .backgroundColor(.gray60)
                    .marginBottom(validationState == .none ? 36 : 12)
                
                // Validation feedback label (직접 추가, 컨테이너 없이)
                flex.addItem(validationFeedbackLabel)
                    .width(100%)
                    .isIncludedInLayout(!validationFeedbackLabel.isHidden)
                    .marginBottom(validationState == .none ? 0 : 36)
                
                // Buttons container
                let buttonsContainerView = UIView()
                self.buttonsContainer = buttonsContainerView
                
                buttonsContainerView.flex.direction(.row)
                    .gap(15)
                    .justifyContent(.spaceEvenly)
                    .width(100%)
                    .define { flex in
                        flex.addItem(cancelButton)
                            .grow(1)
                            .basis(0)
                        flex.addItem(confirmButtonContainer)
                            .grow(1)
                            .basis(0)
                    }
                
                flex.addItem(buttonsContainerView)
                    .width(100%)
            }
    }
    
    @objc private func handleSwipeDown() {
        dismissNicknamePopup()
    }
    
    @objc private func handleNicknameEditTap() {
        showNicknamePopup()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        // Update character count using utf16 for proper Korean character handling
        let characterCount = text.utf16.count
        nicknameCountLabel.text = "\(characterCount)/10"
        
        // Update confirm button state
        let isValidInput = characterCount >= 2
        confirmButton.isEnabled = isValidInput
        confirmButton.isHidden = !isValidInput
        inactiveConfirmButton.isHidden = isValidInput
        
        // Handle validation state based on character count
        if characterCount == 1 {
            // Set validation state to tooShort for single character
            if validationState != .tooShort {
                validationState = .tooShort
            }
        } else if characterCount == 0 || characterCount >= 2 {
            // Reset validation state if it was tooShort
            if validationState == .tooShort {
                validationState = .none
            }
        }
        
        // Handle 10-character limit: change colors to red40 when at max length
        if characterCount == 10 {
            underlineView.backgroundColor = .red40
            nicknameCountLabel.textColor = .red40
        } else if characterCount < 10 && characterCount != 1 {
            // Reset colors for normal state (not 1 character and not 10 characters)
            underlineView.backgroundColor = .gray60
            nicknameCountLabel.textColor = .gray100
        }
        
        // Reset validation state when text changes (except for tooShort which is handled above)
        if validationState != .none && validationState != .tooShort {
            validationState = .none
            
            // Apply layout changes and adjust popup height
            nicknamePopupView.flex.layout(mode: .adjustHeight)
            
            // Update popup position if it's currently visible
            if let window = WindowManager.findKeyWindow(), nicknamePopupView.superview != nil {
                let newHeight = nicknamePopupView.frame.height
                let currentY = nicknamePopupView.frame.origin.y
                
                // Check if keyboard is visible
                let isKeyboardVisible = currentY != window.bounds.height - newHeight
                
                if isKeyboardVisible {
                    // If keyboard is visible, recalculate position above keyboard
                    let keyboardHeight = getKeyboardHeight()
                    let newY = window.bounds.height - keyboardHeight - newHeight
                    let adjustedY = max(newY, window.safeAreaInsets.top + 20)
                    
                    nicknamePopupView.frame = CGRect(
                        x: 0,
                        y: adjustedY,
                        width: window.bounds.width,
                        height: newHeight
                    )
                } else {
                    // If keyboard is not visible, update both height and position
                    let newY = window.bounds.height - newHeight
                    nicknamePopupView.frame = CGRect(
                        x: 0,
                        y: newY,
                        width: window.bounds.width,
                        height: newHeight
                    )
                }
            }
        }
    }
    
    @objc private func handleCancelTap() {
        // 키보드가 열려있으면 키보드만 닫기, 이미 닫혀있으면 팝업 닫기
        if nicknameTextField.isFirstResponder {
            // 키보드만 닫기 (keyboardWillHide에서 팝업 위치가 자동으로 조정됨)
            nicknameTextField.resignFirstResponder()
        } else {
            // 키보드가 이미 닫혀있으면 팝업 전체 닫기
            dismissNicknamePopup()
        }
    }
    
    @objc private func handleCancelButtonTap() {
        // 취소 버튼을 탭하면 키보드와 팝업을 둘 다 한번에 닫기
        dismissNicknamePopup()
    }
    
    @objc private func handleConfirmTap() {
        guard let newNickname = nicknameTextField.text, newNickname.utf16.count >= 2 else { return }
        
        // Run validation
        validateNickname(newNickname)
    }
    
    // Simulate validation check
    private func validateNickname(_ nickname: String) {
        // Show validating state
        validationState = .validating
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            
            // Randomly determine if the nickname is valid (for demonstration)
            let isValid = Bool.random()
            
            if isValid {
                self.validationState = .valid
                // Update nickname and notify delegate after short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.userNickname = nickname
                    self.delegate?.didUpdateNickname(nickname: nickname)
                    self.dismissNicknamePopup()
                }
            } else {
                self.validationState = .invalid
            }
        }
    }
    
    private func updateValidationFeedback() {
        switch validationState {
        case .none:
            validationFeedbackLabel.isHidden = true
            // Exclude from layout when hidden
            validationFeedbackLabel.flex.isIncludedInLayout(false)
            // Set underline margin to 36 when validation is hidden
            underlineView.flex.marginBottom(36)
            validationFeedbackLabel.flex.marginBottom(0)
            
            // Reset colors based on text count
            if let text = nicknameTextField.text {
                let count = text.utf16.count
                if count == 10 {
                    // Keep red40 color for 10-character limit
                    underlineView.backgroundColor = .red40
                    nicknameCountLabel.textColor = .red40
                } else if count != 1 {
                    // Reset to gray for normal state (not 1 character and not 10 characters)
                    underlineView.backgroundColor = .gray60
                    nicknameCountLabel.textColor = .gray100
                }
            }
            
            // Reset confirm button state based on text length
            let isValidInput = nicknameTextField.text?.utf16.count ?? 0 >= 2
            confirmButton.isHidden = !isValidInput
            inactiveConfirmButton.isHidden = isValidInput
            
        case .tooShort:
            validationFeedbackLabel.text = "닉네임은 두 글자부터 가능해요"
            styleLabel(for: validationFeedbackLabel, fontStyle: .label2, textColor: .red40, alignment: .left)
            validationFeedbackLabel.isHidden = false
            // Include in layout when visible
            validationFeedbackLabel.flex.isIncludedInLayout(true)
            // Adjust margins when validation is shown
            underlineView.flex.marginBottom(12)
            validationFeedbackLabel.flex.marginBottom(36)
            // Set underline and count label colors to red40
            underlineView.backgroundColor = .red40
            nicknameCountLabel.textColor = .red40
            
            // Show inactive confirm button for too short state
            confirmButton.isHidden = true
            inactiveConfirmButton.isHidden = false
            
        case .validating:
            validationFeedbackLabel.text = "닉네임 확인 중..."
            styleLabel(for: validationFeedbackLabel, fontStyle: .label2, textColor: .gray100, alignment: .left)
            validationFeedbackLabel.isHidden = false
            // Include in layout when visible
            validationFeedbackLabel.flex.isIncludedInLayout(true)
            // Adjust margins when validation is shown
            underlineView.flex.marginBottom(12)
            validationFeedbackLabel.flex.marginBottom(36)
            
        case .valid:
            guard let nickname = nicknameTextField.text else { return }
            validationFeedbackLabel.text = "사용할 수 있는 닉네임이에요"
            styleLabel(for: validationFeedbackLabel, fontStyle: .label2, textColor: .green60, alignment: .left)
            validationFeedbackLabel.isHidden = false
            // Include in layout when visible
            validationFeedbackLabel.flex.isIncludedInLayout(true)
            // Adjust margins when validation is shown
            underlineView.flex.marginBottom(12)
            validationFeedbackLabel.flex.marginBottom(36)
            // Reset underline and count label colors to default
            underlineView.backgroundColor = .gray60
            nicknameCountLabel.textColor = .gray100
            
            // Enable confirm button for valid state
            confirmButton.isHidden = false
            inactiveConfirmButton.isHidden = true
            
        case .invalid:
            guard let nickname = nicknameTextField.text else { return }
            validationFeedbackLabel.text = "이미 사용 중인 닉네임이에요"
            styleLabel(for: validationFeedbackLabel, fontStyle: .label2, textColor: .red40, alignment: .left)
            validationFeedbackLabel.isHidden = false
            // Include in layout when visible
            validationFeedbackLabel.flex.isIncludedInLayout(true)
            // Adjust margins when validation is shown
            underlineView.flex.marginBottom(12)
            validationFeedbackLabel.flex.marginBottom(36)
            // Set underline and count label colors to red40 for invalid state
            underlineView.backgroundColor = .red40
            nicknameCountLabel.textColor = .red40
            
            // Show inactive confirm button for invalid state
            confirmButton.isHidden = true
            inactiveConfirmButton.isHidden = false
        }
        
        // Apply layout changes and adjust popup height
        nicknamePopupView.flex.layout(mode: .adjustHeight)
        
        // Update popup position if it's currently visible
        if let window = WindowManager.findKeyWindow(), nicknamePopupView.superview != nil {
            let newHeight = nicknamePopupView.frame.height
            let currentY = nicknamePopupView.frame.origin.y
            
            // Check if keyboard is visible by comparing current position
            let isKeyboardVisible = currentY != window.bounds.height - newHeight
            
            if isKeyboardVisible {
                // If keyboard is visible, get current keyboard height from notification center
                // and recalculate position above keyboard
                let keyboardHeight = getKeyboardHeight()
                let newY = window.bounds.height - keyboardHeight - newHeight
                let adjustedY = max(newY, window.safeAreaInsets.top + 20)
                
                nicknamePopupView.frame = CGRect(
                    x: 0,
                    y: adjustedY,
                    width: window.bounds.width,
                    height: newHeight
                )
            } else {
                // If keyboard is not visible, update both height and position
                let newY = window.bounds.height - newHeight
                nicknamePopupView.frame = CGRect(
                    x: 0,
                    y: newY,
                    width: window.bounds.width,
                    height: newHeight
                )
            }
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let window = WindowManager.findKeyWindow() else { return }
        
        let translation = gesture.translation(in: window)
        let velocity = gesture.velocity(in: window)
        
        switch gesture.state {
        case .began:
            // Hide keyboard when user starts dragging for better UX
            if nicknameTextField.isFirstResponder {
                nicknameTextField.resignFirstResponder()
            }
            
        case .changed:
            // Only allow dragging downward
            if translation.y > 0 {
                nicknamePopupView.frame.origin.y = window.bounds.height - nicknamePopupView.frame.height + translation.y
            }
            
        case .ended, .cancelled:
            // If dragged more than 100 points down or with high velocity, dismiss
            if translation.y > 100 || velocity.y > 500 {
                // Explicitly hide keyboard first to ensure it disappears with the popup
                nicknameTextField.resignFirstResponder()
                dismissNicknamePopup()
            } else {
                // Otherwise snap back to original position
                UIView.animate(withDuration: 0.3) {
                    self.nicknamePopupView.frame.origin.y = window.bounds.height - self.nicknamePopupView.frame.height
                }
            }
            
        default:
            break
        }
    }
    
    private func showNicknamePopup() {
        // Add popup and dim view to the window
        guard let window = WindowManager.findKeyWindow() else { return }
        
        window.addSubview(dimView)
        window.addSubview(nicknamePopupView)
        
        // Configure frames
        dimView.frame = window.bounds
        
        // Prepare the modal to slide up from bottom
        let modalHeight = 237
        nicknamePopupView.frame = CGRect(
            x: 0,
            y: window.bounds.height, // Start from below the screen
            width: window.bounds.width,
            height: CGFloat(modalHeight)
        )
        
        // Update bottom padding for initial state (no keyboard)
        currentKeyboardHeight = 0
        updatePopupBottomPadding()
        
        // Apply layout
        nicknamePopupView.flex.layout(mode: .adjustHeight)
        
        // Get final height (paddingBottom is already included in flex layout)
        let finalHeight = nicknamePopupView.frame.height
        nicknamePopupView.frame = CGRect(
            x: 0,
            y: window.bounds.height, // Still below screen
            width: window.bounds.width,
            height: finalHeight
        )
        
        // Prepare text field with current nickname (without "님")
        let currentNickname = userNickname
        nicknameTextField.text = currentNickname
        nicknameCountLabel.text = "\(currentNickname.utf16.count)/10"
        textFieldDidChange(nicknameTextField)
        
        // Show with animation
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.dimView.alpha = 1
            // Slide up from bottom
            self.nicknamePopupView.frame.origin.y = window.bounds.height - finalHeight
            self.nicknamePopupView.alpha = 1
        } completion: { _ in
            // Focus the text field
            self.nicknameTextField.becomeFirstResponder()
        }
    }
    
    private func dismissNicknamePopup() {
        // Hide keyboard
        nicknameTextField.resignFirstResponder()
        
        guard let window = WindowManager.findKeyWindow() else { return }
        
        // 애니메이션 시작 전 validationState가 valid인지 확인을 위한 플래그
        let shouldShowToast = validationState == .valid
        
        // Animate dismissal
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.dimView.alpha = 0
            // Slide down to bottom
            self.nicknamePopupView.frame.origin.y = window.bounds.height
        }) { _ in
            self.dimView.removeFromSuperview()
            self.nicknamePopupView.removeFromSuperview()
            
            // 바텀시트가 완전히 사라진 후 토스트 메시지 표시
            if shouldShowToast {
                ToastView.show(message: "닉네임을 변경했어요", horizontalPadding: 160)
            }
        }
    }
    
    // MARK: - Keyboard Handling
    private func getKeyboardHeight() -> CGFloat {
        return currentKeyboardHeight
    }
    
    private func updatePopupBottomPadding() {
        // 키보드가 있을 때는 36, 없을 때는 28로 설정
        let bottomPadding: CGFloat = currentKeyboardHeight > 0 ? 36 : 28
        nicknamePopupView.flex.paddingBottom(bottomPadding)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let window = WindowManager.findKeyWindow(),
              nicknamePopupView.superview != nil,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        // Get animation duration from notification
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        // Calculate the height of the keyboard in the window's coordinate space
        let keyboardHeight = keyboardFrame.height
        
        // Update current keyboard height
        currentKeyboardHeight = keyboardHeight
        
        // Update bottom padding based on keyboard state
        updatePopupBottomPadding()
        
        // Update layout first to ensure correct height
        nicknamePopupView.flex.layout(mode: .adjustHeight)
        
        // Get popup height (paddingBottom is already included in flex layout)
        let popupHeight = nicknamePopupView.frame.height
        
        // Calculate position above keyboard (directly on top)
        let finalY = window.bounds.height - keyboardHeight - popupHeight
        
        // Ensure we're not moving the sheet too high
        let adjustedY = max(finalY, window.safeAreaInsets.top + 20)
        
        // Animate the popup to its new position
        UIView.animate(withDuration: duration) {
            self.nicknamePopupView.frame = CGRect(
                x: 0,
                y: adjustedY,
                width: self.nicknamePopupView.frame.width,
                height: popupHeight
            )
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let window = WindowManager.findKeyWindow(),
              nicknamePopupView.superview != nil else {
            return
        }
        
        // Get animation duration from notification
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        // Update current keyboard height
        currentKeyboardHeight = 0
        
        // Update bottom padding based on keyboard state
        updatePopupBottomPadding()
        
        // Update layout first to ensure correct height
        nicknamePopupView.flex.layout(mode: .adjustHeight)
        
        // Get current popup height (paddingBottom is already included in flex layout)
        let finalHeight = nicknamePopupView.frame.height
        
        // Calculate final position at bottom of screen
        let finalY = window.bounds.height - finalHeight
        
        // Animate to original position
        UIView.animate(withDuration: duration) {
            self.nicknamePopupView.frame = CGRect(
                x: 0,
                y: finalY,
                width: self.nicknamePopupView.frame.width,
                height: finalHeight
            )
        }
    }
}

#Preview {
    let view = SettingView()
    // 2초 후에 툴팁 표시 (미리보기용)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        view.showMockRecentLoginTooltip()
    }
    return view
}

// MARK: - UITextFieldDelegate
extension SettingView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        
        // 띄어쓰기 불가
        if string.contains(" ") {
            return false
        }
        
        // 특수문자 사용 불가
        if string.containsSpecialCharacters {
            return false
        }
        
        let maxLength = 10 // 원하는 글자 수를 설정해 줍니다.
        let oldText = textField.text ?? "" // 입력하기 전 textField에 표시되어있던 text 입니다.
        let addedText = string // 입력한 text 입니다.
        let newText = oldText + addedText // 입력하기 전 text와 입력한 후 text를 합칩니다.
        let newTextLength = newText.count // 합쳐진 text의 길이 입니다.
        
        // 글자수 제한
        if newTextLength <= maxLength {
            return true
        }
        
        let lastWordOfOldText = String(oldText[oldText.index(before: oldText.endIndex)]) // 입력하기 전 text의 마지막 글자 입니다.
        let separatedCharacters = lastWordOfOldText.decomposedStringWithCanonicalMapping.unicodeScalars.map{ String($0) } // 입력하기 전 text의 마지막 글자를 자음과 모음으로 분리해줍니다.
        let separatedCharactersCount = separatedCharacters.count // 분리된 자음, 모음의 개수입니다.
        
        if separatedCharactersCount == 1 && !addedText.isConsonant {
            return true
        }
        
        if separatedCharactersCount == 2 && addedText.isConsonant {
            return true
        }
        
        if separatedCharactersCount == 3 && addedText.isConsonant {
            return true
        }
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Handle Enter key press
        guard let text = textField.text, text.utf16.count >= 2 else {
            // If input is invalid, just hide keyboard but don't take action
            textField.resignFirstResponder()
            return true
        }
        
        // Perform validation instead of immediate update
        validateNickname(text)
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        var text = textField.text ?? "" // textField에 수정이 반영된 후의 text 입니다.
        let maxLength = 10 // 원하는 글자 수를 설정해 줍니다. (위 함수에서 설정한 값과 동일하게 해주세요.)
        if text.count > maxLength {
            let startIndex = text.startIndex
            let endIndex = text.index(startIndex, offsetBy: maxLength - 1)
            let fixedText = String(text[startIndex...endIndex])
            textField.text = fixedText
        }
    }
}

extension String {
    // 글자가 자음인지 체크
    var isConsonant: Bool {
        guard let scalar = UnicodeScalar(self)?.value else {
            return false
        }
        
        let consonantScalarRange: ClosedRange<UInt32> = 12593...12622
        
        return consonantScalarRange ~= scalar
    }
    
    // 특수문자 체크
    var containsSpecialCharacters: Bool {
        // 영문 알파벳, 숫자, 한글, 자음 및 모음을 제외한 문자는 특수문자로 간주
        let validCharSet = CharacterSet.alphanumerics
            .union(CharacterSet(charactersIn: "가-힣ㄱ-ㅎㅏ-ㅣ")) // 한글, 자음, 모음
        
        return self.unicodeScalars.contains { !validCharSet.contains($0) }
    }
}
