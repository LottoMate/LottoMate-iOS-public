//
//  PensionLotteryWinningNumbersView.swift
//  LottoMate
//
//  Created by Mirae on 8/9/24.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxCocoa

class PensionLotteryWinningNumbersView: UIView {
    var viewModel = LottoMateViewModel.shared
    fileprivate let rootFlexContainer = UIView()
    
    let groupAndNumbersContainer = UIView()
    
    let rankLabel = UILabel()
    let groupContainer = UIView()
    let groupNumberBall = WinningNumberCircleView()
    var groupNumber: Int?
    let groupLabel = UILabel()
    
    let winningNumbersContainer = UIView()
    let firstPensionLotteryNumber = WinningNumberCircleView()
    let secondPensionLotteryNumber = WinningNumberCircleView()
    let thirdPensionLotteryNumber = WinningNumberCircleView()
    let fourthPensionLotteryNumber = WinningNumberCircleView()
    let fifthPensionLotteryNumber = WinningNumberCircleView()
    let sixthPensionLotteryNumber = WinningNumberCircleView()
    
    let bonusLabel = UILabel()
    let bonusGroupAndNumbersContainer = UIView()
    let eachGroupContainer = UIView()
    let eachLabel = UILabel()
    let bonusGroupLabel = UILabel()
    
    let bonusNumbersContainer = UIView()
    let firstPensionBonusNumber = WinningNumberCircleView()
    let secondPensionBonusNumber = WinningNumberCircleView()
    let thirdPensionBonusNumber = WinningNumberCircleView()
    let fourthPensionBonusNumber = WinningNumberCircleView()
    let fifthPensionBonusNumber = WinningNumberCircleView()
    let sixthPensionBonusNumber = WinningNumberCircleView()
    
    private let disposeBag = DisposeBag()
    
    init(groupNumber: Int) {
        super.init(frame: .zero)
        self.groupNumber = groupNumber
        
        bindData()
        
        configureCardView(for: rootFlexContainer)
        let shadowOffset = CGSize(width: 0, height: 0)
        rootFlexContainer.addDropShadow()
        
        rankLabel.text = "1등"
        styleLabel(for: rankLabel, fontStyle: .caption1, textColor: .gray_ACACAC)
        
        groupLabel.text = "조"
        styleLabel(for: groupLabel, fontStyle: .label2, textColor: .black)
        
        
        groupNumberBall.circleColor = .gray140
        
        firstPensionLotteryNumber.circleColor = .red50Default
        secondPensionLotteryNumber.circleColor = .ltmPeach
        thirdPensionLotteryNumber.circleColor = .ltmYellow
        fourthPensionLotteryNumber.circleColor = .ltmBlue
        fifthPensionLotteryNumber.circleColor = .blue30
        sixthPensionLotteryNumber.circleColor = .gray100
        
        bonusLabel.text = "보너스"
        styleLabel(for: bonusLabel, fontStyle: .caption1, textColor: .gray_ACACAC)
        eachLabel.text = "각"
        styleLabel(for: eachLabel, fontStyle: .body1, textColor: .black)
        bonusGroupLabel.text = "조"
        styleLabel(for: bonusGroupLabel, fontStyle: .label2, textColor: .black)
        
        firstPensionBonusNumber.circleColor = .red50Default
        secondPensionBonusNumber.circleColor = .ltmPeach
        thirdPensionBonusNumber.circleColor = .ltmYellow
        fourthPensionBonusNumber.circleColor = .ltmBlue
        fifthPensionBonusNumber.circleColor = .blue30
        sixthPensionBonusNumber.circleColor = .gray100

        rootFlexContainer.flex.direction(.column).paddingVertical(24).paddingHorizontal(20).define { flex in
            flex.addItem(rankLabel).alignSelf(.start).marginBottom(8)
            
            flex.addItem(groupAndNumbersContainer).direction(.row).define { flex in
                flex.addItem(groupContainer).direction(.row).paddingRight(24).define { flex in
                    flex.addItem(groupNumberBall).width(30).height(30).marginRight(8)
                    flex.addItem(groupLabel)
                }
                flex.addItem(winningNumbersContainer).direction(.row).justifyContent(.spaceBetween).define { flex in
                    flex.addItem(firstPensionLotteryNumber).width(30).height(30)
                    flex.addItem(secondPensionLotteryNumber).width(30).height(30)
                    flex.addItem(thirdPensionLotteryNumber).width(30).height(30)
                    flex.addItem(fourthPensionLotteryNumber).width(30).height(30)
                    flex.addItem(fifthPensionLotteryNumber).width(30).height(30)
                    flex.addItem(sixthPensionLotteryNumber).width(30).height(30)
                }
                .grow(1)
            }
            
            flex.addItem().height(1).marginTop(16).backgroundColor(.gray_EEEEEE)
            flex.addItem(bonusLabel).alignSelf(.start).marginTop(16)
            
            flex.addItem(bonusGroupAndNumbersContainer).direction(.row).define { flex in
                flex.addItem(eachLabel).marginRight(24)
                flex.addItem(bonusGroupLabel).marginRight(24)
                flex.addItem(bonusNumbersContainer).direction(.row).justifyContent(.spaceBetween).define { flex in
                    flex.addItem(firstPensionBonusNumber).width(30).height(30)
                    flex.addItem(secondPensionBonusNumber).width(30).height(30)
                    flex.addItem(thirdPensionBonusNumber).width(30).height(30)
                    flex.addItem(fourthPensionBonusNumber).width(30).height(30)
                    flex.addItem(fifthPensionBonusNumber).width(30).height(30)
                    flex.addItem(sixthPensionBonusNumber).width(30).height(30)
                }
                .grow(1)
            }
            
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
    
    func bindData() {
        // 조 번호
        viewModel.pensionLotteryResult
            .subscribe(onNext: { result in
                let groupNumber = result?.pensionLotteryResult.lottoNum[safe: 0]
                if let number = groupNumber {
                    self.groupNumberBall.number = number
                }
            })
            .disposed(by: disposeBag)
        // 첫번째 번호
        viewModel.pensionLotteryResult
            .subscribe(onNext: { result in
                let firstNumber = result?.pensionLotteryResult.lottoNum[safe: 1]
                if let number = firstNumber {
                    self.firstPensionLotteryNumber.number = number
                }
            })
            .disposed(by: disposeBag)
        // 두번째 번호
        viewModel.pensionLotteryResult
            .subscribe(onNext: { result in
                let secondNumber = result?.pensionLotteryResult.lottoNum[safe: 2]
                if let number = secondNumber {
                    self.secondPensionLotteryNumber.number = number
                }
            })
            .disposed(by: disposeBag)
        // 세번째 번호
        viewModel.pensionLotteryResult
            .subscribe(onNext: { result in
                let thirdNumber = result?.pensionLotteryResult.lottoNum[safe: 3]
                if let number = thirdNumber {
                    self.thirdPensionLotteryNumber.number = number
                }
            })
            .disposed(by: disposeBag)
        // 네번째 번호
        viewModel.pensionLotteryResult
            .subscribe(onNext: { result in
                let fourthNumber = result?.pensionLotteryResult.lottoNum[safe: 4]
                if let number = fourthNumber {
                    self.fourthPensionLotteryNumber.number = number
                }
            })
            .disposed(by: disposeBag)
        // 다섯번째 번호
        viewModel.pensionLotteryResult
            .subscribe(onNext: { result in
                let fifthNumber = result?.pensionLotteryResult.lottoNum[safe: 5]
                if let number = fifthNumber {
                    self.fifthPensionLotteryNumber.number = number
                }
            })
            .disposed(by: disposeBag)
        // 여섯번째 번호
        viewModel.pensionLotteryResult
            .subscribe(onNext: { result in
                let sixthNumber = result?.pensionLotteryResult.lottoNum[safe: 6]
                if let number = sixthNumber {
                    self.sixthPensionLotteryNumber.number = number
                }
            })
            .disposed(by: disposeBag)
        // 보너스 번호
        viewModel.pensionLotteryResult
            .subscribe(onNext: { result in
                if let firstBonusNumber = result?.pensionLotteryResult.lottoBonusNum[safe: 0] {
                    self.firstPensionBonusNumber.number = firstBonusNumber
                }
                if let secondBonusNumber = result?.pensionLotteryResult.lottoBonusNum[safe: 1] {
                    self.secondPensionBonusNumber.number = secondBonusNumber
                }
                if let thirdBonusNumber = result?.pensionLotteryResult.lottoBonusNum[safe: 2] {
                    self.thirdPensionBonusNumber.number = thirdBonusNumber
                }
                if let fourthBonusNumber = result?.pensionLotteryResult.lottoBonusNum[safe: 3] {
                    self.fourthPensionBonusNumber.number = fourthBonusNumber
                }
                if let fifthBonusNumber = result?.pensionLotteryResult.lottoBonusNum[safe: 4] {
                    self.fifthPensionBonusNumber.number = fifthBonusNumber
                }
                if let sixthBonusNumber = result?.pensionLotteryResult.lottoBonusNum[safe: 5] {
                    self.sixthPensionBonusNumber.number = sixthBonusNumber
                }
                
            })
            .disposed(by: disposeBag)
        // 당첨 수
        
    }
}

#Preview {
    let view = PensionLotteryWinningNumbersView(groupNumber: 5)
    return view
}
