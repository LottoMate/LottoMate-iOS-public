//
//  HomePensionResultComponents.swift
//  LottoMate
//
//  Created by Mirae on 3/17/26.
//

import UIKit

struct HomePensionResultComponents {
    let mainContainer: UIView
    let resultRoundBadge: UIView
    let winningInfoFooter: UIView
    let prizeMoneyLabel: UILabel
    let prizeMoneyPerWinnerInfoLabel: UILabel
    let winningNumberBalls: UIView
}

enum HomePensionResultComponentsBuilder {
    static func build(result: PensionResultType, owner: UIView, winningInfoButton: UIView) -> HomePensionResultComponents {
        let resultRoundBadge = HomeResultViewFactory.makeResultRoundBadge(
            roundText: "\(result.pensionDrwNum)회 1등 당첨금",
            dateText: "\(result.pensionDrwDate.reformatDate) 추첨"
        )

        let winningInfoFooter = HomeResultViewFactory.makeWinningInfoFooter(
            guideText: "💸 2등은 당첨금이 얼마일까?",
            buttonView: winningInfoButton
        )

        let mainContainer = UIView()

        let prizeMoneyLabel = UILabel()
        prizeMoneyLabel.text = "20년 x 월 700만원"
        styleLabel(for: prizeMoneyLabel, fontStyle: .title2, textColor: .black)

        let prizeMoneyPerWinnerInfoLabel = HomeResultViewFactory.makeHighlightedInfoLabel(
            text: "당첨자는 20년 동안 매월 700만원 씩 받아요",
            highlights: ["20년", "매월 700만원"]
        )

        let winningNumberBalls = HomeResultViewFactory.makePensionWinningNumberBalls(
            owner: owner,
            numbers: result.pensionNum
        )

        return HomePensionResultComponents(
            mainContainer: mainContainer,
            resultRoundBadge: resultRoundBadge,
            winningInfoFooter: winningInfoFooter,
            prizeMoneyLabel: prizeMoneyLabel,
            prizeMoneyPerWinnerInfoLabel: prizeMoneyPerWinnerInfoLabel,
            winningNumberBalls: winningNumberBalls
        )
    }
}
