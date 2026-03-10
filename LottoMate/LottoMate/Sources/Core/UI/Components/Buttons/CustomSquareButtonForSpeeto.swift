//
//  CustomSquareButton.swift
//  LottoMate
//
//  Created by Mirae on 9/4/24.
//

import UIKit
import ReactorKit
import PinLayout
import FlexLayout
import RxSwift
import RxRelay
import RxGesture

class CustomSquareButtonForSpeeto: UIView, View {
    fileprivate let rootFlexContainer = UIView()
    
    typealias Reactor = SpeetoWinningInfoReactor
    var disposeBag = DisposeBag()
    
    let titleLabel2000 = UILabel()
    let titleLabel1000 = UILabel()
    let titleLabel500 = UILabel()
    
    let bottomBorder2000 = UIView()
    let bottomBorder1000 = UIView()
    let bottomBorder500 = UIView()
    
    init() {
        super.init(frame: .zero)
        
        titleLabel2000.text = "2000"
        titleLabel1000.text = "1000"
        titleLabel500.text = "500"
        
        styleLabel(for: titleLabel2000, fontStyle: .headline2, textColor: .black)
        styleLabel(for: titleLabel1000, fontStyle: .headline2, textColor: .gray60)
        styleLabel(for: titleLabel500, fontStyle: .headline2, textColor: .gray60)
        
        addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.column).paddingTop(10).define { flex in
            flex.addItem().direction(.row).gap(16).paddingHorizontal(20).define { flex in
                flex.addItem().direction(.column).define { flex in
                    flex.addItem(titleLabel2000).width(40).marginBottom(8)
                    flex.addItem(bottomBorder2000).height(2)
                }
                flex.addItem().direction(.column).define { flex in
                    flex.addItem(titleLabel1000).width(40).marginBottom(8)
                    flex.addItem(bottomBorder1000).height(2)
                }
                flex.addItem().direction(.column).define { flex in
                    flex.addItem(titleLabel500).width(40).marginBottom(8)
                    flex.addItem(bottomBorder500).height(2)
                }
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
    
    func bind(reactor: Reactor) {
        titleLabel2000.rx.tapGesture()
            .when(.recognized)
            .map { _ in SpeetoType.s2000 }
            .map { Reactor.Action.selectSpeetoType($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        titleLabel1000.rx.tapGesture()
            .when(.recognized)
            .map { _ in SpeetoType.s1000 }
            .map { Reactor.Action.selectSpeetoType($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        titleLabel500.rx.tapGesture()
            .when(.recognized)
            .map { _ in SpeetoType.s500 }
            .map { Reactor.Action.selectSpeetoType($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.speetoType }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                
                let selectedType: SpeetoType
                switch type {
                case .s2000: selectedType = .s2000
                case .s1000: selectedType = .s1000
                case .s500: selectedType = .s500
                }
                print("type - \(type)")
                self.updateButtonStyle(with: selectedType)
            })
            .disposed(by: disposeBag)
    }
    
    func updateButtonStyle(with type: SpeetoType) {
        self.titleLabel2000.textColor = type == .the2000 ? .black : .gray60
        self.titleLabel1000.textColor = type == .the1000 ? .black : .gray60
        self.titleLabel500.textColor = type == .the500 ? .black : .gray60
        
        self.bottomBorder2000.backgroundColor = type == .the2000 ? .red50Default : .white
        self.bottomBorder1000.backgroundColor = type == .the1000 ? .red50Default : .white
        self.bottomBorder500.backgroundColor = type == .the500 ? .red50Default : .white
    }
}

#Preview {
    let view = CustomSquareButtonForSpeeto()
    return view
}
