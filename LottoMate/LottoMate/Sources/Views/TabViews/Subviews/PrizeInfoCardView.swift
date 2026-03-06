//
//  PrizeInfoCardView.swift
//  LottoMate
//
//  Created by Mirae on 8/8/24.
//

import Foundation
import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import RxSwift
import RxGesture

enum LotteryType: String {
    case lotto = "로또"
    case pensionLottery = "연금복권"
    case speeto = "스피또"
}

class PrizeInfoCardView: UIView {
    fileprivate let rootFlexContainer = UIView()
    
    var lotteryType: LotteryType?
    
    let rank = UILabel()
    var rankValue: Int?
    
    let prizeMoney = UILabel()
    var lottoPrizeMoneyValue: Int?
    let perOnePersonLabel = UILabel()
    /// 연금복권, 스피또는 상금이 고정되어 있어 스트링 타입으로 입력 (년, 원 등 단위까지 입력해주어야 함.)
    var prizeMoneyString: String?
    
    
    /// 당첨 조건 타이틀 레이블
    let winningConditionLabel = UILabel()
    /// 당첨 조건 값을 보여주는  레이블
    var winningConditionValueLabel = UILabel()
    /// 당첨 조건 값
    var winningConditionValue: String?
    
    /// 당첨자 수 타이틀 레이블
    let numberOfWinnersLabel = UILabel()
    /// 당첨자 수 값을 보여주는 레이블
    let numberOfWinnersValueLabel = UILabel()
    /// 당첨자 수 값
    var numberOfWinnerValue: Int?
    
    /// 인당 당첨금 타이틀 레이블
    let prizePerWinnerLabel = UILabel()
    /// 인당 당첨금 값을 보여주는 레이블
    let prizePerWinnerValueLabel = UILabel()
    /// 인당 당첨금 값
    var prizePerWinnerValue: Int?
    
    /// 당첨 정보 디테일 컨테이너
    let prizeInfoDetailContainer = UIView()
    /// 당첨 조건, 당첨자 수, 인당 당첨금 라벨 컨테이너
    let prizeDetailLabelContainer = UIView()
    /// 당첨 조건, 당첨자 수, 인당 당첨금 값 컨테이너
    let prizeDetailValueContainer = UIView()
    
    init(lotteryType: LotteryType, rankValue: Int, lottoPrizeMoneyValue: Int? = nil, prizeMoneyString: String? = nil, winningConditionValue: String, numberOfWinnerValue: Int, prizePerWinnerValue: Int? = nil) {
        super.init(frame: .zero)
        self.lotteryType = lotteryType
        self.rankValue = rankValue
        self.lottoPrizeMoneyValue = lottoPrizeMoneyValue
        self.prizeMoneyString = prizeMoneyString
        self.winningConditionValue = winningConditionValue
        self.numberOfWinnerValue = numberOfWinnerValue
        self.prizePerWinnerValue = prizePerWinnerValue
        
        configureCardView(for: rootFlexContainer)
        let shadowOffset = CGSize(width: 0, height: 0)
        rootFlexContainer.addDropShadow()
        
        rank.text = "\(rankValue)등"
        styleLabel(for: rank, fontStyle: .headline2, textColor: .gray_6B6B6B)
        
        switch lotteryType {
        case .lotto:
            if let lottoPrizeMoney = lottoPrizeMoneyValue {
//                prizeMoney.text = "\(lottoPrizeMoney.formattedWithSeparator())원"
            }
        case .pensionLottery:
            if let pensionPrizeMoney = prizeMoneyString {
                prizeMoney.text = "\(pensionPrizeMoney)"
            }
        case .speeto:
            if let speetoPrizeMoney = prizeMoneyString {
                prizeMoney.text = "\(speetoPrizeMoney)"
            }
        }
        prizeMoney.numberOfLines = 0
        prizeMoney.sizeToFit()
        styleLabel(for: prizeMoney, fontStyle: .title3, textColor: .black)
        
        perOnePersonLabel.text = "1인당"
        styleLabel(for: perOnePersonLabel, fontStyle: .label2, textColor: .gray80)
        
        prizeInfoDetailContainer.backgroundColor = .gray_F9F9F9
        prizeInfoDetailContainer.layer.cornerRadius = 8
        
        winningConditionLabel.text = "당첨 조건"
        styleLabel(for: winningConditionLabel, fontStyle: .headline2, textColor: .gray_858585)
        
        numberOfWinnersLabel.text = "당첨자 수"
        styleLabel(for: numberOfWinnersLabel, fontStyle: .headline2, textColor: .gray_858585)
        
        prizePerWinnerLabel.text = "총 당첨금"
        styleLabel(for: prizePerWinnerLabel, fontStyle: .headline2, textColor: .gray_858585)
        
        winningConditionValueLabel.text = "\(winningConditionValue)"
        styleLabel(for: winningConditionValueLabel, fontStyle: .headline2, textColor: .black)
        
        switch lotteryType {
        case .lotto:
            numberOfWinnersValueLabel.text = "\(numberOfWinnerValue)명"
        case .pensionLottery:
            numberOfWinnersValueLabel.text = "\(numberOfWinnerValue)매"
        case .speeto:
            numberOfWinnersValueLabel.text = "\(numberOfWinnerValue)매"
        }
        styleLabel(for: numberOfWinnersValueLabel, fontStyle: .headline2, textColor: .black)
        
        if let lottoPrizeMoneyPerWinner = prizePerWinnerValue {
            prizePerWinnerValueLabel.text = "\(lottoPrizeMoneyPerWinner.formattedWithSeparator())원"
            styleLabel(for: prizePerWinnerValueLabel, fontStyle: .headline2, textColor: .black)
        }
        
        rootFlexContainer.flex.direction(.column).padding(20).define { flex in
            flex.addItem(rank).alignSelf(.start)
            flex.addItem().direction(.row).alignItems(.end).paddingTop(2).paddingBottom(12).define { flex in
                flex.addItem(prizeMoney)
                    .minWidth(180) // 값에 따라 width가 변경되어야 함...
                flex.addItem(perOnePersonLabel)
                    .marginLeft(8)
            }
            
            flex.addItem(prizeInfoDetailContainer).direction(.row).paddingVertical(16).paddingHorizontal(20).define { flex in
                flex.addItem(prizeDetailLabelContainer).direction(.column).alignItems(.start).define { flex in
                    flex.addItem(winningConditionLabel)
                    flex.addItem(numberOfWinnersLabel).marginTop(10)
                    if prizePerWinnerValue != nil {
                        flex.addItem(prizePerWinnerLabel).marginTop(10)
                    }
                }
                
                flex.addItem(prizeDetailValueContainer).direction(.column).alignItems(.start).paddingLeft(24).define { flex in
                    flex.addItem(winningConditionValueLabel)
                    flex.addItem(numberOfWinnersValueLabel).marginTop(10)
                    if prizePerWinnerValue != nil {
                        flex.addItem(prizePerWinnerValueLabel).marginTop(10)
                    }
                }
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
}

#Preview {
    let view = PrizeInfoCardView(lotteryType: .lotto, rankValue: 1, prizeMoneyString: "월 700만원 x 20년", winningConditionValue: "1등번호 7자리 일치", numberOfWinnerValue: 1)
    return view
}
