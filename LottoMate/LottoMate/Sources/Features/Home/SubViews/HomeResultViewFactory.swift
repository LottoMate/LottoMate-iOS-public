//
//  HomeResultViewFactory.swift
//  LottoMate
//
//  Created by Mirae on 3/17/26.
//

import UIKit
import FlexLayout

enum HomeResultViewFactory {
    static func makeResultRoundBadge(
        roundText: String,
        dateText: String,
        roundTextColor: UIColor = .gray120,
        dateTextColor: UIColor = .gray80,
        axis: Flex.Direction = .row
    ) -> UIView {
        let badgeView = UIView()

        let winningRoundInfoLabel = UILabel()
        winningRoundInfoLabel.text = roundText
        styleLabel(for: winningRoundInfoLabel, fontStyle: .label2, textColor: roundTextColor)

        let roundDateInfoLabel = UILabel()
        roundDateInfoLabel.text = dateText
        styleLabel(for: roundDateInfoLabel, fontStyle: .caption1, textColor: dateTextColor)

        badgeView.flex
            .direction(axis)
            .justifyContent(.center)
            .alignItems(.center)
            .gap(8)
            .define { flex in
                flex.addItem(winningRoundInfoLabel)
                flex.addItem(roundDateInfoLabel)
            }

        return badgeView
    }

    static func makeWinningInfoFooter(guideText: String, buttonView: UIView) -> UIView {
        let footerView = UIView()
        let prizeDetailGuideLabel = UILabel()
        prizeDetailGuideLabel.text = guideText
        styleLabel(for: prizeDetailGuideLabel, fontStyle: .label1, textColor: .black)

        footerView.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .define { flex in
                flex.addItem(prizeDetailGuideLabel)
                flex.addItem(buttonView)
            }

        return footerView
    }

    static func makeHighlightedInfoLabel(
        text: String,
        highlights: [String],
        baseStyle: [NSAttributedString.Key: Any] = Typography.label1.attributes(),
        highlightStyle: [NSAttributedString.Key: Any] = Typography.label2.attributes()
    ) -> UILabel {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(baseStyle, range: NSRange(location: 0, length: text.count))

        highlights.forEach { highlight in
            if let range = text.range(of: highlight) {
                let nsRange = NSRange(range, in: text)
                attributedString.addAttributes(highlightStyle, range: nsRange)
            }
        }

        label.attributedText = attributedString
        return label
    }

    static func makeLottoWinningNumberBalls(owner: UIView, numbers: [Int], bonusNumber: Int) -> UIView {
        let view = UIView()
        let plusIcon = CommonImageView(imageName: "plus")

        view.flex.direction(.row).gap(7).alignItems(.center).define { flex in
            numbers.forEach { number in
                let numberBall = WinningNumberCircleView()
                numberBall.number = number
                numberBall.circleColor = owner.colorForNumber(number)

                flex.addItem(numberBall)
                    .size(28)
            }

            let bonusNumberBall = WinningNumberCircleView()
            bonusNumberBall.number = bonusNumber
            bonusNumberBall.circleColor = .green50Default

            flex.addItem(plusIcon)
                .size(10)
            flex.addItem(bonusNumberBall)
                .size(28)
        }

        return view
    }

    static func makePensionWinningNumberBalls(owner: UIView, numbers: [Int]) -> UIView {
        let view = UIView()

        view.flex.direction(.row).gap(7).define { flex in
            numbers.enumerated().forEach { index, number in
                let numberBall = WinningNumberCircleView()
                numberBall.number = number
                numberBall.circleColor = owner.colorForPensionNumber(index: index)

                if index == 0 {
                    let groupLabel = UILabel()
                    groupLabel.text = "조"
                    styleLabel(for: groupLabel, fontStyle: .caption1, textColor: .black)

                    flex.addItem()
                        .direction(.row)
                        .gap(7)
                        .define { flex in
                            flex.addItem(numberBall)
                                .size(28)
                            flex.addItem(groupLabel)
                        }
                } else {
                    flex.addItem(numberBall)
                        .size(28)
                }
            }
        }

        return view
    }
}
