//
//  LotteryTypeFilterBottomSheetViewController.swift
//  LottoMate
//
//  Created by Mirae on 10/7/24.
//

import UIKit
import PinLayout
import FlexLayout
import RxGesture
import ReactorKit
import RxCocoa
import RxSwift
import RxRelay

class LotteryTypeFilterBottomSheetViewController: UIViewController, View {
    fileprivate let rootFlexContainer = UIView()
    var disposeBag = DisposeBag()
    
    // 임시로 사용할 변수 추가 (선택 변경을 위해)
    private var temporarySelectedTypes: [LotteryType] = []
    
    /// 필터가 적용되엇을 때 알리기 위한 릴레이
    let filterApplied = PublishRelay<[LotteryType]>()
    
    let titleLabel = UILabel()
    let lottoLabel = UILabel()
    let pensionLotteryLabel = UILabel()
    let speetoLabel = UILabel()
    
    let lottoContainer = UIView()
    let pensionLotteryContainer = UIView()
    let speetoContainer = UIView()
    
    let lottoCheckIcon = UIImageView()
    let pensionLotteryCheckIcon = UIImageView()
    let speetoCheckIcon = UIImageView()
    
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
        title: "적용하기",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    let inactiveConfirmButton = StyledButton(
        title: "적용하기",
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "복권 선택"
        styleLabel(for: titleLabel, fontStyle: .headline1, textColor: .black, alignment: .left)
        
        lottoLabel.text = "로또"
        styleLabel(for: lottoLabel, fontStyle: .body1, textColor: .black, alignment: .left)
        
        pensionLotteryLabel.text = "연금복권"
        styleLabel(for: pensionLotteryLabel, fontStyle: .body1, textColor: .black, alignment: .left)
        
        speetoLabel.text = "스피또"
        styleLabel(for: speetoLabel, fontStyle: .body1, textColor: .black, alignment: .left)
        
        if let lottoCheckIconImage = UIImage(named: "icon_check") {
            lottoCheckIcon.image = lottoCheckIconImage
            lottoCheckIcon.contentMode = .scaleAspectFit
        }
        if let pensionLotteryCheckIconImage = UIImage(named: "icon_check") {
            pensionLotteryCheckIcon.image = pensionLotteryCheckIconImage
            pensionLotteryCheckIcon.contentMode = .scaleAspectFit
        }
        if let speetoCheckIconImage = UIImage(named: "icon_check") {
            speetoCheckIcon.image = speetoCheckIconImage
            speetoCheckIcon.contentMode = .scaleAspectFit
        }
        
        rootFlexContainer.backgroundColor = .white
        rootFlexContainer.layer.cornerRadius = 32
        rootFlexContainer.clipsToBounds = true
        rootFlexContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        view.addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.column)
            .paddingTop(24)
            .paddingBottom(24)
            .paddingHorizontal(20)
            .define { flex in
                flex.addItem(titleLabel)
                    .marginBottom(24)
                flex.addItem()
                    .gap(16)
                    .direction(.column)
                    .marginBottom(20)
                    .define { flex in
                        flex.addItem(lottoContainer).direction(.row).define { flex in
                            flex.addItem(lottoLabel).grow(1)
                            flex.addItem(lottoCheckIcon)
                        }
                        flex.addItem(pensionLotteryContainer).direction(.row).define { flex in
                            flex.addItem(pensionLotteryLabel).grow(1)
                            flex.addItem(pensionLotteryCheckIcon)
                        }
//                        flex.addItem(speetoContainer).direction(.row).define { flex in
//                            flex.addItem(speetoLabel).grow(1)
//                            flex.addItem(speetoCheckIcon)
//                        }
                    }
                flex.addItem().direction(.row).gap(15).justifyContent(.spaceEvenly).define { flex in
                    flex.addItem(cancelButton)
                        .grow(1)
                        .basis(0)
                    flex.addItem(confirmButtonContainer)
                        .grow(1)
                        .basis(0)
                }
            }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.bottom().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    func bind(reactor: MapViewReactor) {
        lottoContainer.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                // 임시 선택 상태 변경
                if self.temporarySelectedTypes.contains(.lotto) {
                    self.temporarySelectedTypes.removeAll { $0 == .lotto }
                } else {
                    self.temporarySelectedTypes.append(.lotto)
                }
                
                // UI 업데이트
                self.lottoCheckIcon.isHidden = !self.temporarySelectedTypes.contains(.lotto)
                self.confirmButton.isHidden = self.temporarySelectedTypes.isEmpty
                self.inactiveConfirmButton.isHidden = !self.temporarySelectedTypes.isEmpty
            })
            .disposed(by: disposeBag)
        
        // 연금복권 컨테이너 탭 제스처
        pensionLotteryContainer.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                // 임시 선택 상태 변경
                if self.temporarySelectedTypes.contains(.pensionLottery) {
                    self.temporarySelectedTypes.removeAll { $0 == .pensionLottery }
                } else {
                    self.temporarySelectedTypes.append(.pensionLottery)
                }
                
                // UI 업데이트
                self.pensionLotteryCheckIcon.isHidden = !self.temporarySelectedTypes.contains(.pensionLottery)
                self.confirmButton.isHidden = self.temporarySelectedTypes.isEmpty
                self.inactiveConfirmButton.isHidden = !self.temporarySelectedTypes.isEmpty
            })
            .disposed(by: disposeBag)
        
        // 스피또 컨테이너 탭 제스처
//        speetoContainer.rx.tapGesture()
//            .when(.recognized)
//            .subscribe(onNext: { [weak self] _ in
//                guard let self = self else { return }
//                
//                // 임시 선택 상태 변경
//                if self.temporarySelectedTypes.contains(.speeto) {
//                    self.temporarySelectedTypes.removeAll { $0 == .speeto }
//                } else {
//                    self.temporarySelectedTypes.append(.speeto)
//                }
//                
//                // UI 업데이트
//                self.speetoCheckIcon.isHidden = !self.temporarySelectedTypes.contains(.speeto)
//                self.confirmButton.isHidden = self.temporarySelectedTypes.isEmpty
//                self.inactiveConfirmButton.isHidden = !self.temporarySelectedTypes.isEmpty
//            })
//            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                // 바텀 시트 닫기 전에 리액터에게 액션 전달
                reactor.action.onNext(.filterBottomSheetDismissed)
                // 바텀 시트 닫기
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 확인 버튼 - 선택한 값 적용
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                // 현재 임시 선택 상태를 리액터로 전달
                reactor.action.onNext(.applyLotteryTypeFilter(self.temporarySelectedTypes))
                
                // 바텀 시트 닫기 (applyLotteryTypeFilter 액션 내부에서 이미 처리하지만 명시적으로 추가)
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 비활성화된 확인 버튼은 아무 동작 안 함
        inactiveConfirmButton.rx.tap
            .subscribe()
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedLotteryTypes }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] types in
                guard let self = self else { return }
                
                // 임시 선택 타입을 리액터의 현재 상태로 항상 초기화
                self.temporarySelectedTypes = types
                
                // 체크박스 상태 업데이트
                self.lottoCheckIcon.isHidden = !self.temporarySelectedTypes.contains(.lotto)
                self.pensionLotteryCheckIcon.isHidden = !self.temporarySelectedTypes.contains(.pensionLottery)
//                self.speetoCheckIcon.isHidden = !self.temporarySelectedTypes.contains(.speeto)
                
                // 버튼 활성화 상태 업데이트
                self.confirmButton.isHidden = self.temporarySelectedTypes.isEmpty
                self.inactiveConfirmButton.isHidden = !self.temporarySelectedTypes.isEmpty
            })
            .disposed(by: disposeBag)
    }
}

#Preview {
    LotteryTypeFilterBottomSheetViewController()
}
