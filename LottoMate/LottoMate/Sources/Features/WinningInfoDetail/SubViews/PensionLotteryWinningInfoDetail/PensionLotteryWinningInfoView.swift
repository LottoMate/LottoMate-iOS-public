//
//  PensionLotteryWinningInfoView.swift
//  LottoMate
//
//  Created by Mirae on 8/26/24.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxCocoa

class PensionLotteryWinningInfoView: UIView {
    let viewModel = LottoMateViewModel.shared
    let disposeBag = DisposeBag()
    fileprivate let rootFlexContainer = UIView()
    /// 당첨 번호 뷰 (groupNumber 정리 또는 제거 필요)
    let winningNumbersView = PensionLotteryWinningNumbersView(groupNumber: 1)
    /// 당첨 회차
    var lotteryDrawRound = UILabel()
    /// 당첨 날짜
    var drawDate = UILabel()
    /// 당첨 회차 + 날짜 컨테이너. 탭하여 회차 선택 픽커 바텀 시트를 보여줌.
    let lotteryDrawingInfo = UIView()
    /// 전 회차로 가기 버튼
    let previousRoundButton = UIButton()
    /// 다음 회차로 가기 버튼
    let nextRoundButton = UIButton()
    /// '당첨 번호 보기' 레이블
    let lotteryResultsTitle = UILabel()
    /// '등수별 당첨 정보' 레이블
    let prizeDetailsByRank = UILabel()
    /// 지급 기한 정보 레이블
    let claimNoticeLabel = UILabel()
    /// 배너 뷰
//    let banner = BannerView(bannerBackgroundColor: .yellow5, bannerImageName: "banner_coins", titleText: "행운의 1등 로또\r어디서 샀을까?", bodyText: "당첨 판매점 보러가기")
    
    init() {
        super.init(frame: .zero)
        
        bind()
        
        pensionLotteryDrawRoundView()
        
        lotteryResultsTitle.text = "당첨 번호 보기"
        styleLabel(for: lotteryResultsTitle, fontStyle: .headline1, textColor: .primaryGray)
        
        prizeDetailsByRank.text = "등수별 당첨 정보"
        styleLabel(for: prizeDetailsByRank, fontStyle: .headline1, textColor: .primaryGray)
        
        claimNoticeLabel.text = "* 지급 개시일부터 1년 내 당첨금을 찾아가야 해요. (휴일일 경우 다음날까지)"
        styleLabel(for: claimNoticeLabel, fontStyle: .caption1, textColor: .gray80)
        
        addSubview(rootFlexContainer)
        
        rootFlexContainer.flex.direction(.column).paddingHorizontal(20).paddingTop(28).define { flex in
            // 회차
            flex.addItem().direction(.row).justifyContent(.spaceBetween).define { flex in
                flex.addItem(previousRoundButton).paddingHorizontal(10).paddingVertical(7)
                flex.addItem(lotteryDrawingInfo).direction(.row).grow(1).justifyContent(.center).define { flex in
                    flex.addItem(lotteryDrawRound).marginRight(8).grow(1)
                    flex.addItem(drawDate).grow(1)
                }
                flex.addItem(nextRoundButton).paddingHorizontal(10).paddingVertical(7)
            }
            // 당첨 번호 보기
            flex.addItem(lotteryResultsTitle).alignSelf(.start).marginTop(24)
            // 당첨 번호 박스
            flex.addItem(winningNumbersView).marginTop(12)
            // 등수별 당첨 정보
            flex.addItem(prizeDetailsByRank).marginTop(42).alignSelf(.start)
            // 당첨 정보 상세 박스
            flex.addItem().direction(.column).gap(20).marginTop(12).marginBottom(16).define { flex in
                PensionLotteryTier.allCases.forEach { tier in
                    let view = PensionLotteryPrizeInfoCardView(prizeTier: tier)
                    flex.addItem(view)
                }
            }
            flex.addItem(claimNoticeLabel).alignSelf(.start).marginBottom(32)
//            flex.addItem(banner)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    func bind() {
        // 회차 라벨
        viewModel.pensionLotteryResult
            .map { result in
                let text = "\(result?.pensionLotteryResult.drwNum ?? 0)회"
                return text
            }
            .bind(to: lotteryDrawRound.rx.text)
            .disposed(by: disposeBag)
        
        // 추첨 날짜
        viewModel.pensionLotteryResult
            .map { result in
                let drawDate = result?.pensionLotteryResult.drwDate.reformatDate ?? "no data"
                return drawDate
            }
            .bind(to: drawDate.rx.text)
            .disposed(by: disposeBag)
        
        // 전 회차
        previousRoundButton.rx.tap
            .subscribe(onNext: { _ in
                if let currentRound = self.viewModel.currentPensionLotteryRound.value {
                    let previousRound = currentRound - 1
                    self.viewModel.currentPensionLotteryRound.accept(previousRound)
                    self.viewModel.fetchPensionLotteryResult(round: previousRound)
                }
            })
            .disposed(by: disposeBag)
        
        // 최신 회차일 때, next round button disabled 하기
        let isNotLatestRound = self.viewModel.currentPensionLotteryRound
            .map { currentPensionLotteryRound -> Bool in
                if let currentRound = currentPensionLotteryRound, let latestRound = self.viewModel.latestLotteryResult.value?.the720.drwNum {
                    return currentRound < latestRound
                }
                return false
            }
        
        isNotLatestRound
            .bind(to: nextRoundButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 다음 회차
        nextRoundButton.rx.tap
            .subscribe(onNext: { _ in
                if let currentRound = self.viewModel.currentPensionLotteryRound.value {
                    let nextRound = currentRound + 1
                    self.viewModel.currentPensionLotteryRound.accept(nextRound)
                    self.viewModel.fetchPensionLotteryResult(round: nextRound)
                }
            })
            .disposed(by: disposeBag)
        
    }
}

#Preview {
    let view = PensionLotteryWinningInfoView()
    return view
}
