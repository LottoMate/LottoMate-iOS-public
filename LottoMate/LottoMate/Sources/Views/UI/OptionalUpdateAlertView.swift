//
//  OptionalUpdateAlertView.swift
//  LottoMate
//
//  Created by Mirae on 10/13/25.
//

import UIKit
import FlexLayout
import PinLayout

class OptionalUpdateAlertView: UIView {
    
    private let dimView = UIView()
    private let contentView = UIView()
    
    private let skipButton = StyledButton(
        title: "이대로 사용",
        buttonStyle: .assistive(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    private let goToStoreButton = StyledButton(
        title: "스토어로 이동",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    // 콜백
    var onSkip: (() -> Void)?
    var onGoToStore: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // dim 뷰 설정 (탭해도 닫히지 않음 - 버튼만 눌러야 닫힘)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.isUserInteractionEnabled = true  // 터치 이벤트는 받지만 닫지 않음
        addSubview(dimView)
        
        // 콘텐츠 뷰 설정
        addSubview(contentView)
        
        // 타이틀 레이블 생성
        let titleLabel = UILabel()
        titleLabel.text = "신규 업데이트가 있어요\r새로운 로또메이트를 만나러 갈까요?"
        styleLabel(for: titleLabel, fontStyle: .headline1, textColor: .black, alignment: .center)
        titleLabel.numberOfLines = 2
        
        // 콘텐츠 뷰 레이아웃 설정
        contentView.flex.direction(.column)
            .alignItems(.center)
            .paddingTop(28)
            .paddingHorizontal(20)
            .paddingBottom(20)
            .backgroundColor(.white)
            .cornerRadius(12)
            .define { flex in
                flex.addItem(titleLabel)
                    .marginBottom(24)
                
                flex.addItem()
                    .direction(.row)
                    .gap(10)
                    .width(100%)
                    .define { flex in
                        flex.addItem(skipButton)
                            .grow(1)
                            .basis(0)
                        flex.addItem(goToStoreButton)
                            .grow(1)
                            .basis(0)
                    }
            }
        
        // 진입 애니메이션을 위한 초기 상태 설정
        contentView.alpha = 0
        dimView.alpha = 0
    }
    
    private func setupActions() {
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        goToStoreButton.addTarget(self, action: #selector(goToStoreButtonTapped), for: .touchUpInside)
    }
    
    @objc private func skipButtonTapped() {
        dismiss {
            self.onSkip?()
        }
    }
    
    @objc private func goToStoreButtonTapped() {
        dismiss {
            self.onGoToStore?()
        }
    }
    
    func show() {
        layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.dimView.alpha = 1
            self.contentView.alpha = 1
        })
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.dimView.alpha = 0
            self.contentView.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            completion?()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // dim 뷰가 전체 화면을 덮도록 설정
        dimView.pin.all()
        
        // 콘텐츠 뷰 레이아웃 구성
        contentView.pin.horizontally(32).height(180).vCenter()
        contentView.flex.layout(mode: .adjustHeight)
    }
    
    // 윈도우에 표시하는 편리한 메서드
    static func show(in windowScene: UIWindowScene? = nil) -> OptionalUpdateAlertView {
        let alertView = OptionalUpdateAlertView()
        
        if let window = WindowManager.findKeyWindow() {
            window.addSubview(alertView)
            alertView.frame = window.bounds
            alertView.show()
        }
        
        return alertView
    }
}

