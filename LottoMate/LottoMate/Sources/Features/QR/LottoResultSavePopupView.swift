//
//  LottoResultSavePopupView.swift
//  LottoMate
//
//  Created by Cursor on 5/2/25.
//

import UIKit
import FlexLayout
import PinLayout

class LottoResultSavePopupView: UIView {
    
    private let dimView = UIView()
    private let contentView = UIView()
    
    private let noButton = StyledButton(
        title: "아니오",
        buttonStyle: .assistive(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    private let saveButton = StyledButton(
        title: "저장하기",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    // 콜백
    var onNo: (() -> Void)?
    var onSave: (() -> Void)?
    
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
        
        // 타이틀 레이블 생성
        let titleLabel = UILabel()
        titleLabel.text = "로또 당첨 결과를 저장하시겠어요?"
        styleLabel(for: titleLabel, fontStyle: .headline1, textColor: .black, alignment: .center)
        titleLabel.numberOfLines = 1
        
        // 본문 레이블 생성
        let bodyLabel = UILabel()
        bodyLabel.text = "'로또 보관소 > 내 로또'에서\r확인할 수 있어요"
        styleLabel(for: bodyLabel, fontStyle: .label1, textColor: .gray100, alignment: .center)
        bodyLabel.numberOfLines = 2
        
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
                    .marginBottom(8)
                flex.addItem(bodyLabel)
                    .marginBottom(20)
                
                flex.addItem()
                    .direction(.row)
                    .gap(10)
                    .width(100%)
                    .define { flex in
                        flex.addItem(noButton)
                            .grow(1)
                            .basis(0)
                        flex.addItem(saveButton)
                            .grow(1)
                            .basis(0)
                    }
            }
            
        // 진입 애니메이션을 위한 초기 상태 설정
        contentView.alpha = 0
        dimView.alpha = 0
    }
    
    private func setupActions() {
        noButton.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func noButtonTapped() {
        dismiss {
            self.onNo?()
        }
    }
    
    @objc private func saveButtonTapped() {
        dismiss {
            self.onSave?()
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
        contentView.pin.width(310).height(208).center()
        contentView.flex.layout(mode: .adjustHeight)
    }
    
    // 윈도우에 표시하는 편리한 메서드
    static func show(in windowScene: UIWindowScene? = nil) -> LottoResultSavePopupView {
        let popupView = LottoResultSavePopupView()
        
        if let window = WindowManager.findKeyWindow() {
            window.addSubview(popupView)
            popupView.frame = window.bounds
            popupView.show()
        }
        
        return popupView
    }
} 
