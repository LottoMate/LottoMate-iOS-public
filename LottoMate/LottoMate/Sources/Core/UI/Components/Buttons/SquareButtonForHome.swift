//
//  CustomSquareButtonForHome.swift
//  LottoMate
//
//  Created by Mirae on 11/11/24.
//

import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import RxSwift
import RxGesture

class SquereButtonForHome: UIView, View {
    var disposeBag = DisposeBag()
    
    fileprivate let rootFlexContainer = UIView()
    
    private let lottoButtonLabel: UILabel = {
       let label = UILabel()
        label.text = "로또"
        styleLabel(for: label, fontStyle: .headline2, textColor: .black)
        return label
    }()
    
    private let pensionLotteryButtonLabel: UILabel = {
       let label = UILabel()
        label.text = "연금복권"
        styleLabel(for: label, fontStyle: .headline2, textColor: .gray60)
        return label
    }()
    
    private let speetoButtonLabel: UILabel = {
       let label = UILabel()
        label.text = "스피또"
        styleLabel(for: label, fontStyle: .headline2, textColor: .gray60)
        return label
    }()
    
    let lottoBottomBorder = UIView()
    let pensionLotteryBottomBorder = UIView()
    let speetoBottomBorder = UIView()
    
    private let informationIcon = CommonImageView(imageName: "icon_infomation")
    
    init() {
        super.init(frame: .zero)
        
        addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.column).define { flex in
            flex.addItem().direction(.row).justifyContent(.spaceBetween).paddingTop(10).paddingHorizontal(20).define { flex in
                flex.addItem().direction(.row).gap(16).define { flex in
                    flex.addItem().direction(.column).define { flex in
                        flex.addItem(lottoButtonLabel).marginBottom(8)
                        flex.addItem(lottoBottomBorder).height(2)
                    }
                    flex.addItem().direction(.column).define { flex in
                        flex.addItem(pensionLotteryButtonLabel).marginBottom(8)
                        flex.addItem(pensionLotteryBottomBorder).height(2)
                    }
                    flex.addItem().direction(.column).define { flex in
                        flex.addItem(speetoButtonLabel).marginBottom(8)
                        flex.addItem(speetoBottomBorder).height(2)
                    }
                }
                flex.addItem(informationIcon)
                    .size(22)
                    .paddingVertical(1)
            }
            flex.addItem().height(1).backgroundColor(.gray20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
}

extension SquereButtonForHome {
    func bind(reactor: HomeViewReactor) {
        lottoButtonLabel.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.selectLotteryType(.lotto) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        pensionLotteryButtonLabel.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.selectLotteryType(.pensionLottery) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        speetoButtonLabel.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.selectLotteryType(.speeto) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedLotteryType }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] type in
                self?.updateButtonStyle(for: type)
            })
            .disposed(by: disposeBag)
        
        informationIcon.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.showLotteryTypeDetailView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func updateButtonStyle(for type: LotteryType) {
        self.lottoButtonLabel.textColor = type == .lotto ? .black : .gray60
        self.pensionLotteryButtonLabel.textColor = type == .pensionLottery ? .black : .gray60
        self.speetoButtonLabel.textColor = type == .speeto ? .black : .gray60
        
        self.lottoBottomBorder.backgroundColor = type == .lotto ? .red50Default : .white
        self.pensionLotteryBottomBorder.backgroundColor = type == .pensionLottery ? .red50Default : .white
        self.speetoBottomBorder.backgroundColor = type == .speeto ? .red50Default : .white
    }
}

#Preview {
    let view = SquereButtonForHome()
    return view
}
