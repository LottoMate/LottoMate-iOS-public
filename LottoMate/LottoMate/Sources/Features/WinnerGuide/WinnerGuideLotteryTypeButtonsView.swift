// 
//  WinnerGuideLotteryTypeButtonsView.swift
//  LottoMate
//
//  Created by Claude on 3/27/25.
//  당첨금 가이드 뷰용 로또 종류 필터 버튼

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxCocoa

class WinnerGuideLotteryTypeButtonsView: UIView {
    fileprivate let rootFlexContainer = UIView()
    
    // 독립적인 선택된 로또 타입 상태 관리
    let selectedLotteryType = BehaviorRelay<LotteryType>(value: .lotto)
    
    var lottoTypeButton = StyledButton(
        title: "로또",
        buttonStyle: .solid(.round, .active),
        cornerRadius: 17,
        verticalPadding: 6,
        horizontalPadding: 16
    )
    var pensionLotteryTypeButton = StyledButton(
        title: "연금복권",
        buttonStyle: .assistive(.round, .active),
        cornerRadius: 17,
        verticalPadding: 6,
        horizontalPadding: 16
    )
    var speetoTypeButton = StyledButton(
        title: "스피또",
        buttonStyle: .assistive(.round, .active),
        cornerRadius: 17,
        verticalPadding: 6,
        horizontalPadding: 16
    )
    
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        setupBindings()
        
        rootFlexContainer.flex.direction(.row).define { flex in
            flex.addItem(lottoTypeButton).marginRight(10)
            flex.addItem(pensionLotteryTypeButton).marginRight(10)
            flex.addItem(speetoTypeButton)
        }
        addSubview(rootFlexContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top().horizontally().margin(pin.safeArea)
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    private func setupBindings() {
        let lottoButtonTap = lottoTypeButton.rx.tap.asObservable()
        let pensionButtonTap = pensionLotteryTypeButton.rx.tap.asObservable()
        let speetoButtonTap = speetoTypeButton.rx.tap.asObservable()
        
        Observable.merge(lottoButtonTap.map { LotteryType.lotto },
                         pensionButtonTap.map { LotteryType.pensionLottery },
                         speetoButtonTap.map { LotteryType.speeto })
        .bind(to: selectedLotteryType)
        .disposed(by: disposeBag)
        
        selectedLotteryType
            .subscribe(onNext: { [weak self] lotteryType in
                self?.updateButtonStyles(for: lotteryType)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateButtonStyles(for selectedType: LotteryType) {
        lottoTypeButton.style = (selectedType == .lotto) ? .solid(.round, .active) : .assistive(.round, .active)
        pensionLotteryTypeButton.style = (selectedType == .pensionLottery) ? .solid(.round, .active) : .assistive(.round, .active)
        speetoTypeButton.style = (selectedType == .speeto) ? .solid(.round, .active) : .assistive(.round, .active)
    }
}

#Preview {
    let view = WinnerGuideLotteryTypeButtonsView()
    return view
} 