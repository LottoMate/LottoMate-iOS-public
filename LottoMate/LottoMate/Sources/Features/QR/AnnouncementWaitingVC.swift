//
//  AnnouncementWaitingVC.swift
//  LottoMate
//
//  Created by Mirae on 3/19/25.
//

import UIKit
import FlexLayout
import PinLayout

enum AnnouncementWaitingState {
    case daysBeforeAnnouncement(daysRemaining: Int)
    case sameDayBeforeAnnouncement
}

class AnnouncementWaitingVC: UIViewController {
    // MARK: - Enums
    
    // MARK: - UI Elements
    fileprivate let rootFlexContainer = UIView()
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let illustrationImageView = UIImageView()
    private let goHomeButton = StyledButton(
        title: "로또메이트 홈으로 이동하기",
        buttonStyle: .assistive(.medium, .active),
        cornerRadius: 8,
        verticalPadding: 8,
        horizontalPadding: 22
    )
    private let bannerContainer = UIView()
    private let confirmButton = StyledButton(
        title: "확인",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    private let statusBarHeight = DeviceMetrics.statusBarHeight
    
    // MARK: - Properties
    private var state: AnnouncementWaitingState
    var dismissCompletion: (() -> Void)?
    
    // MARK: - Initialization
    init(state: AnnouncementWaitingState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        updateUI(for: state)
        setupBanner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        titleLabel.text = "아직 당첨 발표 전이에요"
        styleLabel(for: titleLabel, fontStyle: .title2, textColor: .black)
        illustrationImageView.image = UIImage(named: "ch_announcementWaiting")

        // Add action to buttons
        goHomeButton.addTarget(self, action: #selector(goHomeButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup Layout
    private func setupLayout() {
        view.addSubview(rootFlexContainer)
        
        let topMargin = (UIScreen.main.bounds.height - statusBarHeight) / 8.3478
        
        rootFlexContainer.flex
            .direction(.column)
            .alignItems(.center)
            .paddingHorizontal(20)
            .backgroundColor(.white)
            .paddingTop(statusBarHeight + topMargin)
            .define { flex in
                flex.addItem(titleLabel)
                    .marginBottom(2)
                
                flex.addItem(statusLabel)
                    .marginBottom(40)
                
                flex.addItem(illustrationImageView)
                    .height(UIScreen.main.bounds.width / 1.7857)
                    .marginBottom(32)
                
                flex.addItem(goHomeButton)
                    .marginBottom(66)
                
                flex.addItem(bannerContainer)
                    .width(100%)
                    .height(100)
                    .marginBottom(36)
                
                flex.addItem(confirmButton)
                    .width(100%)
                    .marginBottom(36)
            }
    }
    
    // MARK: - UI Update
    func updateUI(for state: AnnouncementWaitingState) {
        self.state = state
        
        switch state {
        case .daysBeforeAnnouncement(let daysRemaining):
            let fullText = "당첨 발표일까지 \(daysRemaining)일 남았어요"
            let attributedString = NSMutableAttributedString(string: fullText)
            
            let baseAttributes: [NSAttributedString.Key: Any] = Typography.headline1.attributes()
            attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: fullText.count))
            
            let specialText = "\(daysRemaining)일"
            
            if let range = fullText.range(of: specialText) {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttribute(.foregroundColor, value: UIColor.red50Default, range: nsRange)
            }
            
            statusLabel.attributedText = attributedString
            
        case .sameDayBeforeAnnouncement:
            styleLabel(for: statusLabel, fontStyle: .headline1, textColor: .gray110)
            
            let fullText = "오늘 오후 7시 30분 이후에 확인해보세요"
            let attributedString = NSMutableAttributedString(string: fullText)
            
            let baseAttributes: [NSAttributedString.Key: Any] = Typography.headline1.attributes()
            attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: fullText.count))
            
            let specialText = "7시 30분 이후에"
            
            if let range = fullText.range(of: specialText) {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttribute(.foregroundColor, value: UIColor.red50Default, range: nsRange)
            }
            
            statusLabel.attributedText = attributedString
        }
    }
    
    // 필요에 따라 상태를 업데이트하는 메서드
    func updateState(_ newState: AnnouncementWaitingState) {
        updateUI(for: newState)
    }
    
    // MARK: - Actions
    @objc private func goHomeButtonTapped() {
        // Dismiss current view and navigate to home tab
        if let window = WindowManager.findKeyWindow(),
           let tabBarController = window.rootViewController as? TabBarViewController {
            // Dismiss current view first
            if let presentingVC = self.presentingViewController {
                presentingVC.dismiss(animated: true) {
                    // Navigate to home tab (first tab)
                    tabBarController.selectedIndex = 0
                }
            } else {
                self.dismiss(animated: true) {
                    // Navigate to home tab (first tab)
                    tabBarController.selectedIndex = 0
                }
            }
        }
    }

    @objc private func confirmButtonTapped() {
        // Try multiple dismissal methods to ensure it works
        if let presentingVC = self.presentingViewController {
            presentingVC.dismiss(animated: true) { [weak self] in
                self?.dismissCompletion?()
            }
        } else if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
            self.dismissCompletion?()
        } else {
            // Fallback with a more forceful dismissal if needed
            self.dismiss(animated: true) { [weak self] in
                self?.dismissCompletion?()
                // If we're still on screen somehow, attempt modal dismissal with completion
                self?.view.window?.rootViewController?.dismiss(animated: true) {
                    self?.dismissCompletion?()
                }
            }
        }
    }
}

extension AnnouncementWaitingVC: BannerNavigationDelegate {
    private func setupBanner() {
        let banner = BannerManager.shared.createBanner(type: .winnerGuide, navigationDelegate: self)
        self.bannerContainer.flex.addItem(banner)
    }
    
    func navigate(to bannerType: BannerType) {
        if bannerType == .winnerGuide {
            showWinnerGuide()
        }
    }
    
    func showWinnerGuide() {
        let winnerGuideVC = WinnerGuideVC()
        if let window = WindowManager.findKeyWindow(),
           let rootViewController = window.rootViewController {
            winnerGuideVC.view.frame = window.bounds
            
            rootViewController.addChild(winnerGuideVC)
            rootViewController.view.addSubview(winnerGuideVC.view)
            
            winnerGuideVC.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                winnerGuideVC.view.transform = .identity
            } completion: { _ in
                winnerGuideVC.didMove(toParent: rootViewController)
            }

            winnerGuideVC.changeStatusBarBgColor(bgColor: .commonNavBar)
        }
    }
}
