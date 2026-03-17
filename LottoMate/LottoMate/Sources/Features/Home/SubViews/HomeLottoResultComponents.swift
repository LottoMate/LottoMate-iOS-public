//
//  HomeLottoResultComponents.swift
//  LottoMate
//
//  Created by Mirae on 3/17/26.
//

import UIKit

struct HomeLottoResultComponents {
    let mainContainer: UIView
    let resultRoundBadge: UIView
    let winningInfoFooter: UIView
    let prizeMoneyLabel: UILabel
    let prizeMoneyPerWinnerInfoLabel: UILabel
    let winningNumberBalls: UIView
}

enum HomeLottoResultComponentsBuilder {
    static func build(result: LottoResultType, owner: UIView, winningInfoButton: UIView) -> HomeLottoResultComponents {
        let resultRoundBadge = HomeResultViewFactory.makeResultRoundBadge(
            roundText: "\(result.drwNum)회 1등 당첨금",
            dateText: "\(result.drwDate.reformatDate) 추첨"
        )

        let winningInfoFooter = HomeResultViewFactory.makeWinningInfoFooter(
            guideText: "💸 2등은 당첨금이 얼마일까?",
            buttonView: winningInfoButton
        )

        let mainContainer = UIView()

        let prizeMoneyLabel = UILabel()
        prizeMoneyLabel.text = "총 \(result.p1Jackpot.toHundredMillion)억원"
        styleLabel(for: prizeMoneyLabel, fontStyle: .title1, textColor: .black)

        let prizeMoneyPerWinnerInfoLabel = UILabel()
        let prizeMoneyPerWinner = result.p1Jackpot / result.p1WinnrCnt
        prizeMoneyPerWinnerInfoLabel.text = "당첨된 \(result.p1WinnrCnt)명은 한 번에 \(prizeMoneyPerWinner.toHundredMillion)억을 받아요"
        styleLabel(for: prizeMoneyPerWinnerInfoLabel, fontStyle: .label1, textColor: .black)

        let winningNumberBalls = HomeResultViewFactory.makeLottoWinningNumberBalls(
            owner: owner,
            numbers: result.lottoNum,
            bonusNumber: result.lottoBonusNum.first ?? 0
        )

        return HomeLottoResultComponents(
            mainContainer: mainContainer,
            resultRoundBadge: resultRoundBadge,
            winningInfoFooter: winningInfoFooter,
            prizeMoneyLabel: prizeMoneyLabel,
            prizeMoneyPerWinnerInfoLabel: prizeMoneyPerWinnerInfoLabel,
            winningNumberBalls: winningNumberBalls
        )
    }
}
