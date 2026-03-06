//
//  WinningNumbersView.swift
//  LottoMate
//
//  Created by Mirae on 8/1/24.
//  금주 당첨 번호를 보여주는 뷰

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa

class LottoWinningNumbersView: UIView {
    var viewModel = LottoMateViewModel.shared
    fileprivate let rootFlexContainer = UIView()
    
    /// 당첨번호, 보너스 텍스트를 담은 컨테이너 뷰
    let winningNumbersAndBonus = UIView()
    let winningNumberLabel = UILabel()
    let BonusLabel = UILabel()
    
    /// 당첨번호 공 번호를 담을 컨테이너 뷰
    let winningNumberBalls = UIView()
    let firstNumberView = WinningNumberCircleView()
    let secondNumberView = WinningNumberCircleView()
    let thirdNumberView = WinningNumberCircleView()
    let fourthNumberView = WinningNumberCircleView()
    let fifthNumberView = WinningNumberCircleView()
    let sixthNumberView = WinningNumberCircleView()
    let plusIcon = UIImageView()
    let bonusNumberView = WinningNumberCircleView()
    
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        bindData()
    
        rootFlexContainer.backgroundColor = .white
        rootFlexContainer.layer.borderWidth = 1
        rootFlexContainer.layer.borderColor = UIColor.lightestGray.cgColor
        rootFlexContainer.layer.cornerRadius = 16
        let shadowOffset = CGSize(width: 0, height: 0)
        rootFlexContainer.addDropShadow()
        
        winningNumberLabel.text = "당첨 번호"
        styleLabel(for: winningNumberLabel, fontStyle: .caption1, textColor: .gray_ACACAC)
        
        BonusLabel.text = "보너스"
        styleLabel(for: BonusLabel, fontStyle: .caption1, textColor: .gray_ACACAC)
        
        plusIcon.image = UIImage(named: "plus")
        plusIcon.contentMode = .center
        
        rootFlexContainer.flex.direction(.column).paddingVertical(28).paddingHorizontal(20).define { flex in
            flex.addItem(winningNumbersAndBonus).direction(.row).justifyContent(.spaceBetween).paddingBottom(8).define { flex in
                flex.addItem(winningNumberLabel)
                flex.addItem(BonusLabel)
            }
            
            flex.addItem(winningNumberBalls).direction(.row).justifyContent(.spaceBetween).define { flex in
                flex.addItem(firstNumberView).width(30).height(30)
                flex.addItem(secondNumberView).width(30).height(30)
                flex.addItem(thirdNumberView).width(30).height(30)
                flex.addItem(fourthNumberView).width(30).height(30)
                flex.addItem(fifthNumberView).width(30).height(30)
                flex.addItem(sixthNumberView).width(30).height(30)
                flex.addItem(plusIcon).width(8).height(8).alignSelf(.center)
                flex.addItem(bonusNumberView).width(30).height(30)
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
        // 첫번째 번호
        viewModel.lottoResult
            .map { result -> (Int, UIColor) in
                if let firstNumber = result?.lottoResult.lottoNum[0] {
                    let color = self.colorForNumber(firstNumber)
                    return (firstNumber, color)
                } else {
                    return (0, .black)
                }
            }
            .subscribe(onNext: { number, color in
                self.firstNumberView.number = number
                self.firstNumberView.circleColor = color
            })
            .disposed(by: disposeBag)
        // 두번째 번호
        viewModel.lottoResult
            .map { result -> (Int, UIColor) in
                if let secondNumber = result?.lottoResult.lottoNum[1] {
                    let color = self.colorForNumber(secondNumber)
                    return (secondNumber, color)
                } else {
                    return (0, .black)
                }
            }
            .subscribe(onNext: { number, color in
                self.secondNumberView.number = number
                self.secondNumberView.circleColor = color
            })
            .disposed(by: disposeBag)
        // 세번째 번호
        viewModel.lottoResult
            .map { result -> (Int, UIColor) in
                if let thirdNumber = result?.lottoResult.lottoNum[2] {
                    let color = self.colorForNumber(thirdNumber)
                    return (thirdNumber, color)
                } else {
                    return (0, .black)
                }
            }
            .subscribe(onNext: { number, color in
                self.thirdNumberView.number = number
                self.thirdNumberView.circleColor = color
            })
            .disposed(by: disposeBag)
        // 네번째 번호
        viewModel.lottoResult
            .map { result -> (Int, UIColor) in
                if let fourthNumber = result?.lottoResult.lottoNum[3] {
                    let color = self.colorForNumber(fourthNumber)
                    return (fourthNumber, color)
                } else {
                    return (0, .black)
                }
            }
            .subscribe(onNext: { number, color in
                self.fourthNumberView.number = number
                self.fourthNumberView.circleColor = color
            })
            .disposed(by: disposeBag)
        // 다섯번째 번호
        viewModel.lottoResult
            .map { result -> (Int, UIColor) in
                if let fifthNumber = result?.lottoResult.lottoNum[4] {
                    let color = self.colorForNumber(fifthNumber)
                    return (fifthNumber, color)
                } else {
                    return (0, .black)
                }
            }
            .subscribe(onNext: { number, color in
                self.fifthNumberView.number = number
                self.fifthNumberView.circleColor = color
            })
            .disposed(by: disposeBag)
        // 여섯번째 번호
        viewModel.lottoResult
            .map { result -> (Int, UIColor) in
                if let sixthNumber = result?.lottoResult.lottoNum[5] {
                    let color = self.colorForNumber(sixthNumber)
                    return (sixthNumber, color)
                } else {
                    return (0, .black)
                }
            }
            .subscribe(onNext: { number, color in
                self.sixthNumberView.number = number
                self.sixthNumberView.circleColor = color
            })
            .disposed(by: disposeBag)
        // 보너스 번호
        viewModel.lottoResult
            .map { result -> (Int, UIColor) in
                if let bonusNumber = result?.lottoResult.lottoBonusNum[0] {
                    let color = self.colorForNumber(bonusNumber)
                    return (bonusNumber, color)
                } else {
                    return (0, .black)
                }
            }
            .subscribe(onNext: { number, color in
                self.bonusNumberView.number = number
                self.bonusNumberView.circleColor = color
            })
            .disposed(by: disposeBag)
    }
}

#Preview {
    let view = LottoWinningNumbersView()
    return view
}
