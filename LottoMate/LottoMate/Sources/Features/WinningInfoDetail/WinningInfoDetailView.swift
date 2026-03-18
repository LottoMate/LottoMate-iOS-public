//
//  WinningNumbersDetailView.swift
//  LottoMate
//
//  Created by Mirae on 7/30/24.
//  당첨 번호 상세

import UIKit
import ReactorKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa

protocol WinningInfoDetailViewDelegate: AnyObject {
    func didTapBackButton()
}

class WinningInfoDetailView: UIView, View {
    let viewModel = LottoMateViewModel.shared
    private let selectedLotteryTypeRelay = BehaviorRelay<LotteryType>(value: .lotto)
    
    fileprivate let scrollView = UIScrollView()
    fileprivate let rootFlexContainer = UIView()
    weak var delegate: WinningInfoDetailViewDelegate?
    var disposeBag = DisposeBag()
    
    private let topMargin: CGFloat = {
        let topMargin = DeviceMetrics.statusWithNavigationBarHeight
        return topMargin
    }()
    
    let speetoWinningInfoView = SpeetoWinningInfoView()
    
    /// 복권 타입 필터 버튼
    let lotteryTypeButtonsView: LotteryTypeButtonsView
    let contentView = UIView()
    
    var selectedLotteryType: Observable<LotteryType> {
        selectedLotteryTypeRelay.asObservable()
    }
    
    init(initialLotteryType: LotteryType) {
        self.lotteryTypeButtonsView = LotteryTypeButtonsView(selectedLotteryType: selectedLotteryTypeRelay)
        super.init(frame: .zero)
        backgroundColor = .white
        selectedLotteryTypeRelay.accept(initialLotteryType)
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        rootFlexContainer.flex
            .direction(.column)
            .marginTop(topMargin)
            .define { flex in
                flex.addItem(lotteryTypeButtonsView)
                    .marginHorizontal(20)
                    .marginTop(24)
                
                flex.addItem(contentView)
                    .direction(.column)
                    .marginBottom(topMargin + 60)
                    .define { flex in
                        selectedLotteryTypeRelay
                            .subscribe(onNext: { type in
                                flex.view?.subviews.forEach { $0.removeFromSuperview() }
                                
                                if type == .lotto {
                                    let view = LottoWinningInfoView()
                                    flex.addItem(view).grow(1)
                                    self.layoutSubviews()
                                } else if type == .pensionLottery {
                                    let view = PensionLotteryWinningInfoView()
                                    flex.addItem(view).grow(1)
                                    self.layoutSubviews()
                                } else if type == .speeto {
                                    self.speetoWinningInfoView.delegate = self
                                    flex.addItem(self.speetoWinningInfoView).grow(1)
                                    self.layoutSubviews()
                                }
                            })
                            .disposed(by: disposeBag)
                    }
            }
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.all()
        rootFlexContainer.pin.top().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
    }
    
    func bind(reactor: SpeetoWinningInfoReactor) {
        self.speetoWinningInfoView.bind(reactor: reactor)
    }
}

extension WinningInfoDetailView: SpeetoWinningInfoViewDelegate {
    func speetoWinningInfoViewHeightDidChange() {
        layoutSubviews()
    }
}

#Preview {
    let view = WinningInfoDetailView(initialLotteryType: .lotto)
    return view
}
