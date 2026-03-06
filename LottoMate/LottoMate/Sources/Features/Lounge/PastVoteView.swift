//
//  PastVoteView.swift
//  LottoMate
//
//  Created by Mirae on 11/18/24.
//

import UIKit
import PinLayout
import FlexLayout

class PastVoteView: UIView {
    fileprivate let rootFlexContainer = UIView()
    
    private var cardViewWidth: CGFloat = {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth / Layout.pastVoteCardWidthDivisor
    }()
    
    private let QLabel: UILabel = {
        let label = UILabel()
        label.text = "Q."
        styleLabel(for: label, fontStyle: .headline2, textColor: .black)
        return label
    }()
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "나는 로또 당첨이 되면 다니던\r직장을 그만둔다."
        label.numberOfLines = 2
        styleLabel(for: label, fontStyle: .headline2, textColor: .black, alignment: .left)
        return label
    }()
    private let majorityView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        // 컬러 배경을 위한 두 개의 뷰
        let coloredBackgroundView = UIView()
        coloredBackgroundView.backgroundColor = .red5
        containerView.addSubview(coloredBackgroundView)
        
        let grayBackgroundView = UIView()
        grayBackgroundView.backgroundColor = .gray10
        containerView.addSubview(grayBackgroundView)
        
        // UI 컴포넌트들
        let checkBadge = CommonImageView(imageName: "bedge_check")
        let optionLabel: UILabel = {
            let label = UILabel()
            label.text = "당장 그만두고 논다."
            styleLabel(for: label, fontStyle: .label2, textColor: .red70)
            return label
        }()
        let percentageLabel: UILabel = {
            let label = UILabel()
            label.text = "60%"
            styleLabel(for: label, fontStyle: .label2, textColor: .red70)
            return label
        }()
        
        containerView.flex.define { flex in
            flex.direction(.row)
                .justifyContent(.spaceBetween)
                .paddingHorizontal(16)
                .paddingVertical(13)
                .border(1, .red50Default)
                .define { flex in
                    flex.addItem()
                        .direction(.row)
                        .gap(4)
                        .define { flex in
                            flex.addItem(checkBadge)
                            flex.addItem(optionLabel)
                        }
                    flex.addItem(percentageLabel)
                }
        }
        
        return containerView
    }()
    private let minorityView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        let coloredBackgroundView = UIView()
        coloredBackgroundView.backgroundColor = .gray20
        containerView.addSubview(coloredBackgroundView)
        
        let grayBackgroundView = UIView()
        grayBackgroundView.backgroundColor = .gray10
        containerView.addSubview(grayBackgroundView)
        
        let optionLabel: UILabel = {
            let label = UILabel()
            label.text = "직장은 계속 다닌다."
            styleLabel(for: label, fontStyle: .label2, textColor: .gray120)
            return label
        }()
        let percentageLabel: UILabel = {
            let label = UILabel()
            label.text = "40%"
            styleLabel(for: label, fontStyle: .label2, textColor: .gray120)
            return label
        }()
        
        containerView.flex
            .define { flex in
                flex.direction(.row)
                    .justifyContent(.spaceBetween)
                    .paddingHorizontal(16)
                    .paddingVertical(13)
                    .define { flex in
                        flex.addItem(optionLabel)
                        flex.addItem(percentageLabel)
                    }
            }

        return containerView
    }()
    
    init() {
        super.init(frame: .zero)
        rootFlexContainer.backgroundColor = .white
        rootFlexContainer.layer.cornerRadius = 16
        rootFlexContainer.addDropShadow()
        
        addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.column)
            .width(cardViewWidth)
            .padding(20)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .alignItems(.start)
                    .define { flex in
                        flex.addItem(QLabel)
                            .marginRight(4)
                        flex.addItem(questionLabel)
                            .marginRight(72)
                    }
                flex.addItem(majorityView)
                    .marginTop(16)
                flex.addItem(minorityView)
                    .marginTop(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        let coloredMajorityView = majorityView.subviews.first { $0.backgroundColor == .red5 }
        let grayMajorityView = majorityView.subviews.first { $0.backgroundColor == .gray10 }
        
        if let coloredView = coloredMajorityView, let grayView = grayMajorityView {
            let percentage: CGFloat = 60 // 현재 퍼센테이지
            let coloredWidth = majorityView.bounds.width * (percentage / 100.0)
            let grayWidth = majorityView.bounds.width * ((100.0 - percentage) / 100.0)
            
            coloredView.pin.left().top().bottom().width(coloredWidth)
            grayView.pin.right().top().bottom().width(grayWidth)
        }
        
        let coloredMinorityView = minorityView.subviews.first { $0.backgroundColor == .gray20 }
        let grayMinorityView = minorityView.subviews.first { $0.backgroundColor == .gray10 }
        
        if let coloredView = coloredMinorityView, let grayView = grayMinorityView {
            let percentage: CGFloat = 40
            let coloredWidth = minorityView.bounds.width * (percentage / 100.0)
            let grayWidth = minorityView.bounds.width * ((100.0 - percentage) / 100.0)
            
            coloredView.pin.left().top().bottom().width(coloredWidth)
            grayView.pin.right().top().bottom().width(grayWidth)
        }
    }
    
    // 투표 비율을 업데이트하는 메서드
    func updateVotePercentage(_ percentage: CGFloat) {
        let coloredView = majorityView.subviews.first { $0.backgroundColor == .red5 }
        let whiteView = majorityView.subviews.first { $0.backgroundColor == .gray10 }
        
        if let coloredView = coloredView, let whiteView = whiteView {
            let coloredWidth = majorityView.bounds.width * (percentage / 100.0)
            let whiteWidth = majorityView.bounds.width * ((100.0 - percentage) / 100.0)
            
            UIView.animate(withDuration: 0.3) {
                coloredView.pin.left().top().bottom().width(coloredWidth)
                whiteView.pin.right().top().bottom().width(whiteWidth)
                self.majorityView.layoutIfNeeded()
            }
        }
    }
}

#Preview {
    let view = PastVoteView()
    return view
}
