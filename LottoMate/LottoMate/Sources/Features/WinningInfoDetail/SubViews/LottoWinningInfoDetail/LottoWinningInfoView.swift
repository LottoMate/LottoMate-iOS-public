//
//  LottoWinningInfoView.swift
//  LottoMate
//
//  Created by Mirae on 8/23/24.
//  로또 버튼 눌렸을 때 나타나는 디테일 뷰

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxCocoa
import BottomSheet

class LottoWinningInfoView: UIView {
    let viewModel = LottoMateViewModel.shared
    
    fileprivate let rootFlexContainer = UIView()
    
    let disposeBag = DisposeBag()
    
    var firstPrizeCardView = LottoPrizeInfoCardView(prizeTier: .firstPrize)
    var secondPrizeCardView = LottoPrizeInfoCardView(prizeTier: .secondPrize)
    var thirdPrizeCardView = LottoPrizeInfoCardView(prizeTier: .thirdPrize)
    var fourthPrizeCardView = LottoPrizeInfoCardView(prizeTier: .fourthPrize)
    var fifthPrizeCardView = LottoPrizeInfoCardView(prizeTier: .fifthPrize)
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
    
    /// 당첨 번호 보기
    let lotteryResultsTitle = UILabel()
    /// 총 판매 금액 레이블
    let totalSalesAmountLabel = UILabel()
    /// 총 판매 금액 값
//    let totalSalesAmountValue: Int = 111998191000
    let winningNumbersView = LottoWinningNumbersView()
    
    /// 등수별 당첨 정보
    let prizeDetailsByRank = UILabel()
    /// '1인당 당첨 수령 금액' 레이블
    let noticePrizeAmountPerPerson = UILabel()
    
    /// 지급 기한 정보 레이블
    let claimNoticeLabel = UILabel()
    /// 배너 뷰
//    let banner = BannerView(bannerBackgroundColor: .yellow5, bannerImageName: "banner_coins", titleText: "행운의 1등 로또\r어디서 샀을까?", bodyText: "당첨 판매점 보러가기")
    
    init() {
        super.init(frame: .zero)
        
        bind()
        
        lottoDrawRoundView()
        
        lotteryResultsTitle.text = "당첨 번호 보기"
        styleLabel(for: lotteryResultsTitle, fontStyle: .headline1, textColor: .primaryGray)
        
        prizeDetailsByRank.text = "등수별 당첨 정보"
        styleLabel(for: prizeDetailsByRank, fontStyle: .headline1, textColor: .primaryGray)
        
        noticePrizeAmountPerPerson.text = "1인당 당첨 수령 금액"
        styleLabel(for: noticePrizeAmountPerPerson, fontStyle: .caption1, textColor: .gray80)
        
        styleLabel(for: totalSalesAmountLabel, fontStyle: .caption1, textColor: .gray80)
        
        claimNoticeLabel.text = "* 지급 개시일부터 1년 내 당첨금을 찾아가야 해요. (휴일일 경우 다음날까지)"
        styleLabel(for: claimNoticeLabel, fontStyle: .caption1, textColor: .gray80)
        
        addSubview(rootFlexContainer)
        
        rootFlexContainer.flex
            .direction(.column)
            .paddingHorizontal(20)
            .paddingTop(28)
            .define { flex in
                flex.addItem().direction(.row)
                    .justifyContent(.spaceBetween)
                    .define { flex in
                        flex.addItem(previousRoundButton)
                            .paddingHorizontal(10)
                            .paddingVertical(7)
                        flex.addItem(lotteryDrawingInfo)
                            .direction(.row)
                            .grow(1)
                            .justifyContent(.center)
                            .define { flex in
                                flex.addItem(lotteryDrawRound).marginRight(8).grow(1)
                                flex.addItem(drawDate).grow(1)
                            }
                        flex.addItem(nextRoundButton).paddingHorizontal(10).paddingVertical(7)
                    }
                flex.addItem().direction(.row)
                    .justifyContent(.spaceBetween)
                    .alignItems(.end)
                    .define { flex in
                        flex.addItem(lotteryResultsTitle)
                            .alignSelf(.start)
                            .marginTop(24)
                        flex.addItem(totalSalesAmountLabel)
                    }
                flex.addItem(winningNumbersView)
                    .marginTop(12)
                flex.addItem().direction(.row)
                    .paddingTop(42)
                    .justifyContent(.spaceBetween)
                    .alignItems(.end)
                    .define { flex in
                        flex.addItem(prizeDetailsByRank)
                        flex.addItem(noticePrizeAmountPerPerson)
                    }
                flex.addItem().direction(.column)
                    .gap(20)
                    .marginTop(12)
                    .marginBottom(16)
                    .define { flex in
                        flex.addItem(firstPrizeCardView)
                        flex.addItem(secondPrizeCardView)
                        flex.addItem(thirdPrizeCardView)
                        flex.addItem(fourthPrizeCardView)
                        flex.addItem(fifthPrizeCardView)
                    }
                flex.addItem(claimNoticeLabel).alignSelf(.start).marginBottom(32)
//                flex.addItem(banner)
            }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func bind() {
        // 회차 라벨
        viewModel.lottoResult
            .map { result in
                let text = "\(result?.lottoResult.drwNum ?? 0)회"
                return text
            }
            .bind(to: lotteryDrawRound.rx.text)
            .disposed(by: disposeBag)
        
        // 추첨 날짜
        viewModel.lottoResult
            .observe(on: MainScheduler.instance)
            .map { result in
                let drawDate = result?.lottoResult.drwDate.reformatDate ?? "no data"
                return drawDate
            }
            .bind(to: drawDate.rx.text)
            .disposed(by: disposeBag)
        
        previousRoundButton.rx.tap
            .subscribe(onNext: { _ in
                if let currentRound = self.viewModel.currentLottoRound.value {
                    let previousRound = currentRound - 1
                    self.viewModel.currentLottoRound.accept(previousRound)
                    self.viewModel.fetchLottoResult(round: previousRound)
                }
            })
            .disposed(by: disposeBag)
        
        // 최신 회차일 때, next round button disabled 하기
        let isNotLatestRound = self.viewModel.currentLottoRound
            .map { currentLottoRound -> Bool in
                if let currentRound = currentLottoRound, let latestRound = self.viewModel.latestLotteryResult.value?.the645.drwNum {
                    return currentRound < latestRound
                }
                return false
            }
        
        isNotLatestRound
            .bind(to: nextRoundButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        nextRoundButton.rx.tap
            .subscribe(onNext: { _ in
                if let currentRound = self.viewModel.currentLottoRound.value {
                    let nextRound = currentRound + 1
                    self.viewModel.currentLottoRound.accept(nextRound)
                    self.viewModel.fetchLottoResult(round: nextRound)
                }
            })
            .disposed(by: disposeBag)
        
        // 총 판매 금액
        viewModel.lottoResult
            .map { result in
                let totalSalesPrice = result?.lottoResult.totalSalesPrice ?? 0
                return "총 판매 금액 : \(totalSalesPrice.formattedWithSeparator())원"
            }
            .bind(to: totalSalesAmountLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

#Preview {
    let view = LottoWinningInfoView()
    return view
}

