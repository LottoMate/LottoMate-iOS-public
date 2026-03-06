//
//  LottoPrizeInfoCardView.swift
//  LottoMate
//
//  Created by Mirae on 8/25/24.
//  로또 당첨 정보 디테일 (1~5등)

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxCocoa

enum LottoPrizeTier: String {
    case firstPrize = "1등"
    case secondPrize = "2등"
    case thirdPrize = "3등"
    case fourthPrize = "4등"
    case fifthPrize = "5등"
    
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
        }
    }
    
    var winningCondition: String {
        switch self {
        case .firstPrize:
            return "당첨번호 6개 일치"
        case .secondPrize:
            return "당첨번호 5개 일치\n+ 보너스 일치"
        case .thirdPrize:
            return "당첨번호 5개 일치"
        case .fourthPrize:
            return "당첨번호 4개 일치"
        case .fifthPrize:
            return "당첨번호 3개 일치"
        }
    }
}

class LottoPrizeInfoCardView: UIView {
    let viewModel = LottoMateViewModel.shared
    private let disposeBag = DisposeBag()
    
    fileprivate let rootFlexContainer = UIView()
    var prizeTier: LottoPrizeTier = .firstPrize
    
    /// 로또 당첨 등수 레이블 (예: 1등)
    let rank = UILabel()
    /// 1등 아이콘
    let firstPrizeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_winnerBadge_lotto")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    /// 로또 1인당 당첨 금액 레이블
    let prizeMoney = UILabel()
    /// 당첨 상세 정보 컨테이너 (회색 배경)
    let prizeInfoDetailContainer = UIView()
    /// 당첨 조건, 당첨자 수, 총 당첨금 '라벨' 컨테이너
    let prizeDetailLabelContainer = UIView()
    /// 당첨 조건, 당첨자 수, 총 당첨금 '값' 컨테이너
    let prizeDetailValueContainer = UIView()
    /// '1인당' 레이블
    let perOnePersonLabel = UILabel()
    /// '당첨 조건' 레이블
    let winningConditionLabel = UILabel()
    /// 당첨 조건 내용 레이블
    var winningConditionValueLabel = UILabel()
    /// '당첨자 수'  레이블
    let numberOfWinnersLabel = UILabel()
    /// 당첨자 수 값 레이블
    let numberOfWinnersValueLabel = UILabel()
    /// 인당 당첨금 타이틀 레이블 (총 당첨금으로 변경 필요) - response 변경 후 적용하기
    let prizePerWinnerLabel = UILabel()
    /// 인당 당첨금 값을 보여주는 레이블 (총 당첨금으로 변경 필요)
    let prizePerWinnerValueLabel = UILabel()
    
    
    init(prizeTier: LottoPrizeTier) {
        super.init(frame: .zero)
        self.prizeTier = prizeTier
        
        bindData()
        
        configureCardView(for: rootFlexContainer)
        let shadowOffset = CGSize(width: 0, height: 0)
        rootFlexContainer.addDropShadow()
        
        rank.text = prizeTier.rawValue
        styleLabel(for: rank, fontStyle: .headline2, textColor: prizeTier.prizeTierTextColor)
        
        firstPrizeIcon.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        styleLabel(for: prizeMoney, fontStyle: .title2, textColor: .black, alignment: .left)
        
        perOnePersonLabel.text = "1인당"
        styleLabel(for: perOnePersonLabel, fontStyle: .label2, textColor: .gray80)
        
        prizeInfoDetailContainer.backgroundColor = .gray_F9F9F9
        prizeInfoDetailContainer.layer.cornerRadius = 8
        
        winningConditionLabel.text = "당첨 조건"
        styleLabel(for: winningConditionLabel, fontStyle: .body1, textColor: .gray_858585)
        numberOfWinnersLabel.text = "당첨자 수"
        styleLabel(for: numberOfWinnersLabel, fontStyle: .body1, textColor: .gray_858585)
        prizePerWinnerLabel.text = "총 당첨금"
        styleLabel(for: prizePerWinnerLabel, fontStyle: .body1, textColor: .gray_858585)
        // 당첨 조건 내용
        winningConditionValueLabel.text = "\(prizeTier.winningCondition)"
        winningConditionValueLabel.numberOfLines = 2
        styleLabel(for: winningConditionValueLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        styleLabel(for: numberOfWinnersValueLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        styleLabel(for: prizePerWinnerValueLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        addSubview(rootFlexContainer)
        
        // MARK: FlexLayout
        rootFlexContainer.flex.direction(.column).padding(20).define { flex in
            flex.addItem().direction(.row).define { flex in
                if prizeTier == .firstPrize {
                    flex.addItem(firstPrizeIcon).marginRight(8)
                }
                flex.addItem(rank).alignSelf(.start)
            }
            flex.addItem(prizeMoney).alignSelf(.stretch).minWidth(0).maxWidth(.infinity).marginBottom(12)
            
            flex.addItem(prizeInfoDetailContainer).direction(.row).paddingVertical(16).paddingHorizontal(20).define { flex in
                flex.addItem(prizeDetailLabelContainer).direction(.column).alignItems(.start).define { flex in
                    flex.addItem(winningConditionLabel)
                    if prizeTier == .secondPrize {
                        flex.addItem(numberOfWinnersLabel).marginTop(34)
                    } else {
                        flex.addItem(numberOfWinnersLabel).marginTop(10)
                    }
                    flex.addItem(prizePerWinnerLabel).marginTop(10)
                    
                }
                flex.addItem(prizeDetailValueContainer).direction(.column).alignItems(.start).paddingLeft(24).grow(1).define { flex in
                    flex.addItem(winningConditionValueLabel).alignSelf(.start)
                    flex.addItem(numberOfWinnersValueLabel).marginTop(10).width(100%)
                    flex.addItem(prizePerWinnerValueLabel).marginTop(10).width(100%)
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
        // 인당 당첨금 (현재 총 당첨금 데이터 사용. 추후 변경 필요.)
        viewModel.lottoResult
            .map { result in
                var totalPrizeMoney = 0
                switch self.prizeTier {
                case .firstPrize:
                    totalPrizeMoney = result?.lottoResult.p1Jackpot ?? 0
                case .secondPrize:
                    totalPrizeMoney = result?.lottoResult.p2Jackpot ?? 0
                case .thirdPrize:
                    totalPrizeMoney = result?.lottoResult.p3Jackpot ?? 0
                case .fourthPrize:
                    totalPrizeMoney = result?.lottoResult.p4Jackpot ?? 0
                case .fifthPrize:
                    totalPrizeMoney = result?.lottoResult.p5Jackpot ?? 0
                }
                return "\((totalPrizeMoney).formattedWithSeparator())원"
            }
            .bind(to: prizeMoney.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.lottoResult
            .map { result in
                var winnerCount = 0
                switch self.prizeTier {
                case .firstPrize:
                    winnerCount = result?.lottoResult.p1WinnrCnt ?? 0 // 데이터 없을 경우 뷰가 줄어드는 현상 때문에 임시로 큰 값을 기본값으로 줌.
                case .secondPrize:
                    winnerCount = result?.lottoResult.p2WinnrCnt ?? 0
                case .thirdPrize:
                    winnerCount = result?.lottoResult.p3WinnrCnt ?? 0
                case .fourthPrize:
                    winnerCount = result?.lottoResult.p4WinnrCnt ?? 0
                case .fifthPrize:
                    winnerCount = result?.lottoResult.p5WinnrCnt ?? 0
                }
                return "\(winnerCount.formattedWithSeparator())명"
            }
            .bind(to: numberOfWinnersValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.lottoResult
            .map { result in
                var totalPrizeMoney = 0
                switch self.prizeTier {
                case .firstPrize:
                    totalPrizeMoney = result?.lottoResult.p1Jackpot ?? 0
                case .secondPrize:
                    totalPrizeMoney = result?.lottoResult.p2Jackpot ?? 0
                case .thirdPrize:
                    totalPrizeMoney = result?.lottoResult.p3Jackpot ?? 0
                case .fourthPrize:
                    totalPrizeMoney = result?.lottoResult.p4Jackpot ?? 0
                case .fifthPrize:
                    totalPrizeMoney = result?.lottoResult.p5Jackpot ?? 0
                }
                return "\((totalPrizeMoney).formattedWithSeparator())원"
            }
            .bind(to: prizePerWinnerValueLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

#Preview {
    let view = LottoPrizeInfoCardView(prizeTier: .firstPrize)
    return view
}
