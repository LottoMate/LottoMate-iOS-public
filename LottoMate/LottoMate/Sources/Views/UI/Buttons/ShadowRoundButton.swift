//
//  ShadowRoundButton.swift
//  LottoMate
//
//  Created by Mirae on 9/23/24.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxRelay

enum IconPosition {
    case left
    case right
}

class ShadowRoundButton: UIView {
    private let aButtonView = UIView()
    var titleLabel = UILabel()
    var filterIcon = UIImageView()
    
    private var iconPosition: IconPosition?
    private(set) var isSelected = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    private var hasIconOnly: Bool {
        return filterIcon.image != nil && titleLabel.text == nil
    }
    
    init(title: String? = nil, icon: UIImage? = nil, iconPosition: IconPosition? = nil) {
        super.init(frame: .zero)
        
        setupBinding()
        
        if let icon = icon {
            filterIcon.image = icon
            filterIcon.contentMode = .scaleAspectFit
            filterIcon.tintColor = .gray100
            aButtonView.addSubview(filterIcon)
        }
        
        if let title = title {
            titleLabel.text = title
            styleLabel(for: titleLabel, fontStyle: .label2, textColor: .black)
            aButtonView.addSubview(titleLabel)
        }
        
        if let iconPosition = iconPosition {
            self.iconPosition = iconPosition
        }
        
        aButtonView.backgroundColor = .white
        aButtonView.addDropShadow()
        
        addSubview(aButtonView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if filterIcon.image != nil && titleLabel.text != nil {
            // 아이콘과 타이틀이 모두 있는 경우
            filterIcon.pin.width(12).height(12)
            
            // 아이콘 위치에 따라 레이아웃 조정
            if iconPosition == .left {
                titleLabel.pin.sizeToFit().right(of: filterIcon, aligned: .center).marginLeft(4)
                aButtonView.flex.border(1, .black)
            } else {
                titleLabel.pin.sizeToFit().left(of: filterIcon, aligned: .center).marginRight(8)
                aButtonView.flex.border(0, .clear)
            }
            aButtonView.pin.wrapContent(padding: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        } else if filterIcon.image != nil {
            // 아이콘만 있는 경우 (Circle 모양)
            filterIcon.pin.width(24).height(24).center()
            aButtonView.pin.wrapContent(padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
            aButtonView.flex.border(0, .clear)
        } else if titleLabel.text != nil {
            // 타이틀만 있는 경우
            titleLabel.pin.sizeToFit().center()
            aButtonView.pin.wrapContent(padding: UIEdgeInsets(top: 8, left: 17.75, bottom: 8, right: 17.75))
        }
        
        aButtonView.layer.cornerRadius = (aButtonView.layer.bounds.height / 2)
    }
    
    private func setupBinding() {
        self.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let newValue = !self.isSelected.value
                self.isSelected.accept(newValue)
            })
            .disposed(by: disposeBag)
        
        isSelected
            .subscribe(onNext: { [weak self] selected in
                guard let self = self else { return }
                self.updateBorder(selected)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateBorder(_ selected: Bool) {
        // 아이콘만 있는 경우에는 항상 테두리 없음
        if hasIconOnly {
            aButtonView.flex.border(0, .clear)
        } else if iconPosition == .right {
            // 아이콘이 오른쪽에 있는 경우에는 테두리 없음
            aButtonView.flex.border(0, .clear)
        } else if iconPosition == .left {
            // 아이콘이 왼쪽에 있는 경우 (복권 종류 필터 버튼) 항상 테두리 있음
            aButtonView.flex.border(1, .black)
        } else {
            // 아이콘이 왼쪽에 있거나 아이콘이 없는 경우, 선택 상태에 따라 테두리 설정
            if selected {
                aButtonView.flex.border(1, .black)
            } else {
                aButtonView.flex.border(0, .clear)
            }
        }
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
        setNeedsLayout()
    }
}

#Preview {
    let view = ShadowRoundButton(title: "당첨 판매점")
    return view
}
