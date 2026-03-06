//
//  WithdrawalCompletionView.swift
//  LottoMate
//
//  Created on 3/10/25.
//

import UIKit
import FlexLayout
import PinLayout

class WithdrawalCompletionView: UIView {
    
    private let dimView = UIView()
    private let contentView = UIView()
    
    private let confirmButton = StyledButton(
        title: "확인",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    // 콜백
    var onConfirm: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // dim 뷰 설정
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        addSubview(dimView)
        
        // 콘텐츠 뷰 설정
        addSubview(contentView)
        
        // 레이블 생성
        let label = UILabel()
        label.text = "회원 탈퇴가 완료되었어요\r행운을 빌어요!"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black, alignment: .center)
        label.numberOfLines = 2
        
        // 콘텐츠 뷰 레이아웃 설정
        contentView.flex.direction(.column)
            .alignItems(.center)
            .gap(24)
            .paddingTop(28)
            .paddingHorizontal(20)
            .paddingBottom(20)
            .backgroundColor(.white)
            .cornerRadius(12)
            .define { flex in
                flex.addItem(label)
                flex.addItem(confirmButton)
                    .width(100%)
            }
            
        // 초기 상태 설정
        contentView.alpha = 0
        dimView.alpha = 0
    }
    
    private func setupActions() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    @objc private func confirmButtonTapped() {
        dismiss {
            self.onConfirm?()
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
        contentView.pin.width(310).height(180).center()
        contentView.flex.layout(mode: .adjustHeight)
    }
    
    // 윈도우에 표시하는 편리한 메서드
    static func show() -> WithdrawalCompletionView {
        let completionView = WithdrawalCompletionView()
        
        if let window = WindowManager.findKeyWindow() {
            window.addSubview(completionView)
            completionView.frame = window.bounds
            completionView.show()
        }
        
        return completionView
    }
} 
