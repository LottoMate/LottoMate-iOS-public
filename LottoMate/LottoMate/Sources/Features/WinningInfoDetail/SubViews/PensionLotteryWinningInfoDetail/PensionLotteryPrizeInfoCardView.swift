//
//  PensionLotteryPrizeInfoCardView.swift
//  LottoMate
//
//  Created by Mirae on 8/27/24.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxCocoa

enum PensionLotteryTier: CaseIterable {
    case firstPrize
    case secondPrize
    case thirdPrize
    case fourthPrize
    case fifthPrize
    case sixthPrize
    case seventhPrize
    case eighthPrize
    
    var prizeTierText: String {
        switch self {
        case .firstPrize:
            return "1등"
        case .secondPrize:
            return "2등"
        case .thirdPrize:
            return "3등"
        case .fourthPrize:
            return "4등"
        case .fifthPrize:
            return "5등"
        case .sixthPrize:
            return "6등"
        case .seventhPrize:
            return "7등"
        case .eighthPrize:
            return "보너스"
        }
    }
    var prizeTierTextColor: UIColor {
        switch self {
        case .firstPrize:
            return .firstPrizeTextColor
        case .secondPrize:
            return .secondPrizeTextColor
        case .thirdPrize:
            return .thirdPrizeTextColor
        case .fourthPrize:
            return .fourthPrizeTextColor
        case .fifthPrize:
            return .fifthPrizeTextColor
        case .sixthPrize, .seventhPrize, .eighthPrize:
            return .gray_6B6B6B
        }
    }
    var prizeMoneyText: String {
        switch self {
        case .firstPrize:
            return "월 700만원 x 20년"
        case .secondPrize:
            return "월 100만원 x 10년"
        case .thirdPrize:
            return "1,000,000원"
        case .fourthPrize:
            return "100,000원"
        case .fifthPrize:
            return "50,000원"
        case .sixthPrize:
            return "5,000원"
        case .seventhPrize:
            return "1,000원"
        case .eighthPrize:
            return "월 100만원 x 10년"
        }
    }
    var winningConditionText: String {
        switch self {
        case .firstPrize:
            return "1등번호 7자리 일치"
        case .secondPrize:
            return "1등번호 뒤 6자리 일치"
        case .thirdPrize:
            return "1등번호 뒤 5자리 일치"
        case .fourthPrize:
            return "1등번호 뒤 4자리 일치"
        case .fifthPrize:
            return "1등번호 뒤 3자리 일치"
        case .sixthPrize:
            return "1등번호 뒤 2자리 일치"
        case .seventhPrize:
            return "1등번호 뒤 1자리 일치"
        case .eighthPrize:
            return "보너스 번호 6자리 일치"
        }
    }
}

class PensionLotteryPrizeInfoCardView: UIView {
    let viewModel = LottoMateViewModel.shared
    private let disposeBag = DisposeBag()
    fileprivate let rootFlexContainer = UIView()
    var prizeTier: PensionLotteryTier = .firstPrize
    /// 연금복권 당첨 등수 레이블 (예: 1등)
    let rank = UILabel()
    /// 1등 아이콘 (연금복권 아이콘으로 변경 필요)
    private let firstPrizeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_winnerBadge_lotto")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    /// 연금복권 당첨 금액 레이블 (예: 월 700만원 x 20년)
    let prizeMoney = UILabel()
    /// 당첨 상세 정보 컨테이너 (회색 배경)
    let prizeInfoDetailContainer = UIView()
    /// 당첨 조건, 당첨자 수, 총 당첨금 '라벨' 컨테이너
    let prizeDetailLabelContainer = UIView()
    /// 당첨 조건, 당첨자 수, 총 당첨금 '값' 컨테이너
    let prizeDetailValueContainer = UIView()
    /// '당첨 조건' 레이블
    let winningConditionLabel = UILabel()
    /// 당첨 조건 내용 레이블
    var winningConditionValueLabel = UILabel()
    /// '당첨자 수'  레이블
    let numberOfWinnersLabel = UILabel()
    /// 당첨자 수 값 레이블
    let numberOfWinnersValueLabel = UILabel()
    
    init(prizeTier: PensionLotteryTier) {
        super.init(frame: .zero)
        self.prizeTier = prizeTier
        
        bindData()
        
        configureCardView(for: rootFlexContainer)
        let shadowOffset = CGSize(width: 0, height: 0)
        rootFlexContainer.addDropShadow()
        
        rank.text = prizeTier.prizeTierText
        styleLabel(for: rank, fontStyle: .headline2, textColor: prizeTier.prizeTierTextColor)
        
        prizeMoney.text = prizeTier.prizeMoneyText
        styleLabel(for: prizeMoney, fontStyle: .title2, textColor: .black)
        
        prizeInfoDetailContainer.backgroundColor = .gray_F9F9F9
        prizeInfoDetailContainer.layer.cornerRadius = 8
        
        winningConditionLabel.text = "당첨 조건"
        styleLabel(for: winningConditionLabel, fontStyle: .body1, textColor: .gray_858585)
        
        // 당첨 조건 내용
        winningConditionValueLabel.text = prizeTier.winningConditionText
        styleLabel(for: winningConditionValueLabel, fontStyle: .headline2, textColor: .black)
        
        numberOfWinnersLabel.text = "당첨 수"
        styleLabel(for: numberOfWinnersLabel, fontStyle: .body1, textColor: .gray_858585)
        
        styleLabel(for: numberOfWinnersValueLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        // MARK: FlexLayout
        addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.column).padding(20).define { flex in
            flex.addItem().direction(.row).define { flex in
                if prizeTier == .firstPrize {
                    flex.addItem(firstPrizeIcon).marginRight(8)
                }
                flex.addItem(rank).alignSelf(.start)
            }
            
            flex.addItem(prizeMoney).alignSelf(.start).marginBottom(12)
            
            flex.addItem(prizeInfoDetailContainer).direction(.row).paddingVertical(16).paddingHorizontal(20).paddingBottom(16).define { flex in
                flex.addItem(prizeDetailLabelContainer).direction(.column).alignItems(.start).define { flex in
                    flex.addItem(winningConditionLabel)
                    flex.addItem(numberOfWinnersLabel).marginTop(10)
                }
                flex.addItem(prizeDetailValueContainer).direction(.column).alignItems(.start).paddingLeft(24).grow(1).define { flex in
                    flex.addItem(winningConditionValueLabel)
                    flex.addItem(numberOfWinnersValueLabel).marginTop(10).width(100%)
                }
            }
        }
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
        // 당첨자 수
        viewModel.pensionLotteryResult
            .map { result in
                var winnerCount = 0
                switch self.prizeTier {
                case .firstPrize:
                    winnerCount = result?.pensionLotteryResult.p1WinnrCnt ?? 0
                case .secondPrize:
                    winnerCount = result?.pensionLotteryResult.p2WinnrCnt ?? 0
                case .thirdPrize:
                    winnerCount = result?.pensionLotteryResult.p3WinnrCnt ?? 0
                case .fourthPrize:
                    winnerCount = result?.pensionLotteryResult.p4WinnrCnt ?? 0
                case .fifthPrize:
                    winnerCount = result?.pensionLotteryResult.p5WinnrCnt ?? 0
                case .sixthPrize:
                    winnerCount = result?.pensionLotteryResult.p6WinnrCnt ?? 0
                case .seventhPrize:
                    winnerCount = result?.pensionLotteryResult.p7WinnrCnt ?? 0
                case .eighthPrize:
                    winnerCount = result?.pensionLotteryResult.p8WinnrCnt ?? 0
                }
                return "\(winnerCount.formattedWithSeparator())매"
            }
            .bind(to: numberOfWinnersValueLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

#Preview {
    let view = PensionLotteryPrizeInfoCardView(prizeTier: .firstPrize)
    return view
}
