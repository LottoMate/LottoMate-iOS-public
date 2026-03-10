//
//  BaseViewController.swift
//  LottoMate
//
//  Created by Mirae on 10/24/24.
//  커스텀 상단 네비게이션

import UIKit
import FlexLayout
import PinLayout

protocol SlideAnimatible {
    func changeStatusBarBgColor(bgColor: UIColor?)
}

enum NavBarStyle {
    case backButtonOnly
    case backButtonWithTitle
    case backButtonWithTitleAndSetting
    case closeButtonOnly
    case closeButtonWithTitle
    case custom
    case logoAndSetting
    case titleAndSetting
    case titleOnly
}

class BaseViewController: UIViewController, SlideAnimatible {
    // MARK: - Properties
    private let statusBarTag = 987654
    private var navBarConfiguration: NavBarConfiguration?
    
    // MARK: - UI Components
    let rootFlexContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let navBarContainer: UIView = {
        let view = UIView()
        return view
    }()
    /// 네비게이션 아이템 타이틀
    let navTitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let leftButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    let rightButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeStatusBarBgColor(bgColor: .commonNavBar)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var statusBarHeight: CGFloat = 0.0
        
        if let windowScene = view.window?.windowScene {
            statusBarHeight = windowScene.statusBarManager?.statusBarFrame.height ?? 0
        }
        
        rootFlexContainer.pin
            .top(statusBarHeight)
            .horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        
        view.addSubview(rootFlexContainer)
    }
    
    private func setupLayout() {
        rootFlexContainer.flex.define { flex in
            flex.addItem()
                .direction(.row)
                .justifyContent(.spaceBetween)
//                .paddingVertical(14)
                .alignItems(.center)
                .height(56)
                .define { row in
                    // Left button
                    row.addItem(leftButton)
                    
                    // Title
                    row.addItem(navTitleLabel)
                        .grow(1)
                        .alignSelf(.center)
//                        .marginHorizontal(10)
                    
                    // Right button
                    row.addItem(rightButton)
//                        .size(24)
//                        .marginRight(18)
                }
        }
    }
    
    func configureNavBar(_ configuration: NavBarConfiguration) {
        self.navBarConfiguration = configuration
        
        rootFlexContainer.backgroundColor = configuration.backgroundColor
        navTitleLabel.text = configuration.title
        navTitleLabel.textColor = configuration.titleColor
        styleLabel(for: navTitleLabel, fontStyle: .headline1, textColor: configuration.titleColor)
        
        switch configuration.style {
        case .backButtonOnly:
            setupBackButtonOnly(configuration)
        case .backButtonWithTitle:
            setupBackButtonWithTitle(configuration)
        case .backButtonWithTitleAndSetting:
            setupBackButtonWithTitleAndSetting(configuration)
        case .closeButtonOnly:
            setupCloseButtonOnly(configuration)
        case .closeButtonWithTitle:
            setupCloseButtonWithTitle(configuration)
        case .custom:
            setupCustomNavBar(configuration)
        case .logoAndSetting:
            setupLogoAndSetting(configuration)
        case .titleAndSetting:
            setupTitleAndSetting(configuration)
        case .titleOnly:
            setupTitleOnly(configuration)
        }
    }
    
    // MARK: - Private Setup Methods
    
    private func setupTitleOnly(_ config: NavBarConfiguration) {
        leftButton.isHidden = true
        rightButton.isHidden = true
        navTitleLabel.isHidden = false
    }
    
    private func setupBackButtonOnly(_ config: NavBarConfiguration) {
        leftButton.isHidden = false
        rightButton.isHidden = true
        navTitleLabel.isHidden = true
        
        leftButton.setImage(config.leftButtonImage, for: .normal)
        leftButton.tintColor = config.buttonTintColor
        
        // 터치 범위 확장을 위한 설정
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 10)
        
        // 기본 크기 설정 (44x44는 Apple의 권장 터치 영역 크기)
        leftButton.flex.width(44).height(44)
    }
    
    private func setupBackButtonWithTitle(_ config: NavBarConfiguration) {
        leftButton.isHidden = false
        rightButton.isHidden = true
        navTitleLabel.isHidden = false
        
        leftButton.setImage(config.leftButtonImage, for: .normal)
        leftButton.tintColor = config.buttonTintColor
        
        // 터치 범위 확장을 위한 설정
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 10)
        
        if let leftButtonSize = config.leftButtonSize {
            leftButton.flex.width(leftButtonSize.width).height(leftButtonSize.height)
        } else {
            // 기본 크기 설정 (44x44는 Apple의 권장 터치 영역 크기)
            leftButton.flex.width(44).height(44)
        }
    }
    
    private func setupBackButtonWithTitleAndSetting(_ config: NavBarConfiguration) {
        leftButton.isHidden = false
        rightButton.isHidden = false
        navTitleLabel.isHidden = false
        
        leftButton.setImage(config.leftButtonImage, for: .normal)
        rightButton.setImage(config.rightButtonImage, for: .normal)
        
        // 터치 범위 확장을 위한 설정
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 10)
//        rightButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        if let leftButtonSize = config.leftButtonSize {
            leftButton.flex.width(leftButtonSize.width).height(leftButtonSize.height)
        } else {
            // 기본 크기 설정 (44x44는 Apple의 권장 터치 영역 크기)
            leftButton.flex.width(44).height(44)
        }
        
        leftButton.tintColor = config.buttonTintColor
        leftButton.flex.backgroundColor(.white)
        rightButton.tintColor = config.buttonTintColor
    }
    
    private func setupTitleAndSetting(_ config: NavBarConfiguration) {
//        rightButton.isHidden = false
        rightButton.isHidden = true // v1.0.0 제외하여 hidden 처리
        navTitleLabel.isHidden = false
        
        rightButton.setImage(config.rightButtonImage, for: .normal)
        rightButton.tintColor = config.buttonTintColor
        
        // 터치 범위 확장을 위한 설정
//        rightButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // 기본 크기 설정 (44x44는 Apple의 권장 터치 영역 크기)
        rightButton.flex.width(44).height(44)
    }
    
    private func setupCloseButtonOnly(_ config: NavBarConfiguration) {
        leftButton.isHidden = true
        rightButton.isHidden = false
        navTitleLabel.isHidden = true
        
        rightButton.setImage(config.rightButtonImage, for: .normal)
        rightButton.tintColor = config.buttonTintColor
        
        // 터치 범위 확장을 위한 설정
//        rightButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // 기본 크기 설정 (44x44는 Apple의 권장 터치 영역 크기)
        rightButton.flex.width(44).height(44)
    }
    
    private func setupCloseButtonWithTitle(_ config: NavBarConfiguration) {
        leftButton.isHidden = true
        rightButton.isHidden = false
        navTitleLabel.isHidden = false
        
        rightButton.setImage(config.rightButtonImage, for: .normal)
        rightButton.tintColor = config.buttonTintColor
        
        // 터치 범위 확장을 위한 설정
//        rightButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // 기본 크기 설정 (44x44는 Apple의 권장 터치 영역 크기)
        rightButton.flex.width(44).height(44)
    }
    
    private func setupLogoAndSetting(_ config: NavBarConfiguration) {
        leftButton.isHidden = false
//        rightButton.isHidden = false
        rightButton.isHidden = true // 설정 아이콘 v1.0.0 에서 제외
        navTitleLabel.isHidden = true
        
        leftButton.setImage(config.leftButtonImage, for: .normal)
        leftButton.tintColor = .black
        
//        var configuration = UIButton.Configuration.plain()
//        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
//        leftButton.configuration = configuration
        
        leftButton.flex.marginLeft(20)
        
        if let logoSize = config.logoSize {
            leftButton.flex.width(logoSize.width).height(logoSize.height)
        }
        
        rightButton.setImage(config.rightButtonImage, for: .normal)
        rightButton.tintColor = config.buttonTintColor
        
        // 터치 범위 확장을 위한 설정
//        rightButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // 기본 크기 설정 (44x44는 Apple의 권장 터치 영역 크기)
        rightButton.flex.width(44).height(44)
    }
    
    private func setupCustomNavBar(_ config: NavBarConfiguration) {
        // Custom configuration can be implemented by subclasses
    }
    
    // MARK: - Actions
    @objc func leftButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func rightButtonTapped() {
        // Override this method in subclass to handle right button tap
    }
    
    func changeStatusBarBgColor(bgColor: UIColor?) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let tag = 987654
            
            if let existingStatusBarView = window.viewWithTag(tag) {
                existingStatusBarView.backgroundColor = bgColor
            } else {
                let statusBarManager = windowScene.statusBarManager
                let statusBarFrame = statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: statusBarFrame)
                statusBarView.backgroundColor = bgColor
                statusBarView.tag = tag
                window.addSubview(statusBarView)
            }
        }
    }
    
    func removeStatusBarBgColor() {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        if let existingStatusBarView = window.viewWithTag(statusBarTag) {
            existingStatusBarView.removeFromSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Public Methods
    func setNavigationTitle(_ title: String) {
        navTitleLabel.text = title
        styleLabel(for: navTitleLabel, fontStyle: .headline1, textColor: .black)
    }
}

struct NavBarConfiguration {
    let style: NavBarStyle
    var title: String?
    var leftButtonImage: UIImage?
    var rightButtonImage: UIImage?
    var backgroundColor: UIColor
    var titleColor: UIColor
    var buttonTintColor: UIColor
    var logoSize: CGSize?
    var leftButtonSize: CGSize?
    var isLogoButton: Bool = false
    
    init(
        style: NavBarStyle,
        title: String? = nil,
        leftButtonImage: UIImage? = UIImage(named: "backArrow"),
        rightButtonImage: UIImage? = nil,
        backgroundColor: UIColor = .commonNavBar,
        titleColor: UIColor = .black,
        buttonTintColor: UIColor = .black,
        logoSize: CGSize? = nil,
        leftButtonSize: CGSize? = nil,
        isLogoButton: Bool = false
    ) {
        self.style = style
        self.title = title
        self.leftButtonImage = leftButtonImage
        self.rightButtonImage = rightButtonImage
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.buttonTintColor = buttonTintColor
        self.logoSize = logoSize
        self.leftButtonSize = leftButtonSize
        self.isLogoButton = isLogoButton
    }
}
