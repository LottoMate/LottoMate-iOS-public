//
//  StorageTabButtonsView.swift
//  LottoMate
//
//  Created by Mirae on 10/25/24.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxCocoa
import ReactorKit

class StorageTabButtonsView: UIView, View {
    var disposeBag = DisposeBag()
    
    fileprivate let rootFlexContainer = UIView()
    
    private let myNumberButton: StyledButton = {
        let button = StyledButton(
            title: "내 번호",
            buttonStyle: .solid(.round, .active),
            cornerRadius: 17,
            verticalPadding: 6,
            horizontalPadding: 16)
        return button
    }()
    
    private let randomNumberButton: StyledButton = {
        let button = StyledButton(
            title: "랜덤 번호",
            buttonStyle: .assistive(.round, .active),
            cornerRadius: 17,
            verticalPadding: 6,
            horizontalPadding: 16)
        return button
    }()

    
    init() {
        super.init(frame: .zero)
        
        rootFlexContainer.flex.direction(.row).define { flex in
            flex.addItem(myNumberButton).marginRight(10)
            flex.addItem(randomNumberButton)
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
    
    func bind(reactor: StorageViewReactor) {
        myNumberButton.rx.tap
            .map { StorageViewReactor.Action.didSelectMyNumber }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        randomNumberButton.rx.tap
            .map { StorageViewReactor.Action.didSelectrandomNumber }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedMode }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] storageViewMode in
                self?.updateButtonStyles(for: storageViewMode)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateButtonStyles(for selectedViewMode: StorageViewMode) {
        myNumberButton.style = (selectedViewMode == .myNumber) ? .solid(.round, .active) : .assistive(.round, .active)
        randomNumberButton.style = (selectedViewMode == .randomNumber) ? .solid(.round, .active) : .assistive(.round, .active)
    }
}

#Preview {
    let view = StorageTabButtonsView()
    return view
}
