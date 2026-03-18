//
//  HomeSpeetoResultComponents.swift
//  LottoMate
//
//  Created by Mirae on 3/18/26.
//

import UIKit
import FlexLayout

struct HomeSpeetoResultComponents {
    let mainContainer: UIView
    let resultRoundBadge: UIView
    let winningInfoFooter: UIView
    let prizeMoneyLabel: UILabel
    let remainingWinningChancesLabel: UILabel
    let releaseInfoView: UIView
    let remainingRanksView: UIView
}

enum HomeSpeetoResultComponentsBuilder {
    static func build(result: HomeSpeetoMockResult, winningInfoButton: UIView) -> HomeSpeetoResultComponents {
        let resultRoundBadge = HomeResultViewFactory.makeResultRoundBadge(
            roundText: "\(result.speetoDrwNum)회 1등 당첨금",
            dateText: "\(result.speetoDrwDate) 스피또 2000 기준",
            roundTextColor: .black,
            dateTextColor: .gray100,
            axis: .column
        )

        let winningInfoFooter = HomeResultViewFactory.makeWinningInfoFooter(
            guideText: "💸 2등은 당첨금이 얼마일까?",
            buttonView: winningInfoButton
        )

        let mainContainer = UIView()

        let prizeMoneyLabel = UILabel()
        prizeMoneyLabel.text = result.prizeMoneyText
        styleLabel(for: prizeMoneyLabel, fontStyle: .title1, textColor: .black)

        let remainingWinningChancesLabel = HomeResultViewFactory.makeHighlightedInfoLabel(
            text: "1등 복권 \(result.firstPrizeRemainingCount)장 남았어요",
            highlights: ["\(result.firstPrizeRemainingCount)장"]
        )

        let lotteryReleaseRate = UILabel()
        lotteryReleaseRate.text = "현재까지 출고율"
        styleLabel(for: lotteryReleaseRate, fontStyle: .caption1, textColor: .gray100)

        let releaseRate = UILabel()
        releaseRate.text = "\(result.releaseRate)%"
        styleLabel(for: releaseRate, fontStyle: .caption1, textColor: .gray100)

        let releaseInfoView = UIView()
        releaseInfoView.flex
            .direction(.row)
            .alignSelf(.center)
            .gap(4)
            .define { flex in
                flex.addItem(lotteryReleaseRate)
                flex.addItem(releaseRate)
            }

        let firstPrizeRemaining = UILabel()
        firstPrizeRemaining.text = "1등 : \(result.firstPrizeRemainingCount)/\(result.firstPrizeTotalCount)"
        styleLabel(for: firstPrizeRemaining, fontStyle: .caption1, textColor: .gray80)

        let secondPrizeRemaining = UILabel()
        secondPrizeRemaining.text = "2등 : \(result.secondPrizeRemainingCount)/\(result.secondPrizeTotalCount)"
        styleLabel(for: secondPrizeRemaining, fontStyle: .caption1, textColor: .gray80)

        let thirdPrizeRemaining = UILabel()
        thirdPrizeRemaining.text = "3등 : \(result.thirdPrizeRemainingCount)/\(result.thirdPrizeTotalCount)"
        styleLabel(for: thirdPrizeRemaining, fontStyle: .caption1, textColor: .gray80)

        let separatorLabel1 = UILabel()
        separatorLabel1.text = "|"
        styleLabel(for: separatorLabel1, fontStyle: .caption1, textColor: .gray40)

        let separatorLabel2 = UILabel()
        separatorLabel2.text = "|"
        styleLabel(for: separatorLabel2, fontStyle: .caption1, textColor: .gray40)

        let remainingRanksView = UIView()
        remainingRanksView.flex
            .direction(.row)
            .gap(8)
            .alignSelf(.center)
            .define { flex in
                flex.addItem(firstPrizeRemaining)
                flex.addItem(separatorLabel1)
                flex.addItem(secondPrizeRemaining)
                flex.addItem(separatorLabel2)
                flex.addItem(thirdPrizeRemaining)
            }

        return HomeSpeetoResultComponents(
            mainContainer: mainContainer,
            resultRoundBadge: resultRoundBadge,
            winningInfoFooter: winningInfoFooter,
            prizeMoneyLabel: prizeMoneyLabel,
            remainingWinningChancesLabel: remainingWinningChancesLabel,
            releaseInfoView: releaseInfoView,
            remainingRanksView: remainingRanksView
        )
    }
}
