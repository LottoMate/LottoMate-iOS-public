//
//  SignUpCompleteView.swift
//  LottoMate
//
//  Created by Mirae on 11/18/24.
//

import UIKit
import FlexLayout
import PinLayout
import RxGesture
import RxSwift


class SignUpCompleteViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    fileprivate let rootFlexContainer = UIView()
   
    private let statusBarHeight = DeviceMetrics.statusBarHeight
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "환영해요!"
        styleLabel(for: label, fontStyle: .title1, textColor: .black)
        return label
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "1등 당첨을 위해 행운을 모아볼까요?"
        styleLabel(for: label, fontStyle: .body1, textColor: .gray100)
        return label
    }()
    private let pochiImage = CommonImageView(imageName: "pochi_welcome")

    let startButton = StyledButton(
        title: "시작하기",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0)
    
    private let bannerContainer = UIView()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindStartButton()
        setupBanner()
        
        view.backgroundColor = .white
        view.addSubview(rootFlexContainer)
        
        let topMargin = (UIScreen.main.bounds.height - statusBarHeight) / 8.5909
        
        rootFlexContainer.flex
            .direction(.column)
            .alignItems(.center)
            .paddingHorizontal(20)
            .backgroundColor(.white)
            .paddingTop(statusBarHeight + topMargin)
            .define { flex in
                flex.addItem(titleLabel)
                    .marginBottom(4)
                
                flex.addItem(subTitleLabel)
                    .marginBottom(47)
                
                flex.addItem(pochiImage)
                    .size(UIScreen.main.bounds.width / 1.512)
//                    .marginBottom(101)
                
                flex.addItem()
//                    .backgroundColor(.red)
                    .width(100%)
                    .grow(1)
                
                flex.addItem(bannerContainer)
                    .width(100%)
                    .height(100)
                    .marginBottom(24)
                
                flex.addItem(startButton)
                    .width(100%)
                    .marginBottom(32)
            }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout()
    }
    
    private func bindStartButton() {
        startButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.navigateToMainViewController()
            })
            .disposed(by: disposeBag)
    }
    
    private func navigateToMainViewController() {
    }
}

#Preview {
    SignUpCompleteViewController()
}

extension SignUpCompleteViewController: BannerNavigationDelegate {
    private func setupBanner() {
        let banner = BannerManager.shared.createRandomBanner(navigationDelegate: self)
        self.bannerContainer.flex.addItem(banner)
    }
    
    func navigate(to bannerType: BannerType) {
        //
    }
}
