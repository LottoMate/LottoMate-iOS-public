//
//  VoteView.swift
//  LottoMate
//
//  Created by Mirae on 11/14/24.
//

import UIKit
import PinLayout
import FlexLayout

class VoteView: UIView {
    fileprivate let rootFlexContainer = UIView()
    private let mateViewLabel: UILabel = {
        let label = UILabel()
        label.text = "메이트 투표"
        styleLabel(for: label, fontStyle: .body1, textColor: .gray100)
        return label
    }()
   
    private let QLabel = CommonTitle3Label(text: "Q.")
    private let questionLabel = CommonTitle3Label(text: "나는 로또 당첨이 되면\r다니던 직장을 그만둔다.")
    private let syncIcon = CommonImageView(imageName: "icon_sync")
    private let image = CommonImageView(imageName: "slotMachineAndCoins")
    
    private let firstOptionView: UIView = {
        let view = UIView()
        let optionText: UILabel = {
            let label = UILabel()
            label.text = "당장 그만두고 실컷 논다."
            styleLabel(for: label, fontStyle: .headline2, textColor: .black, alignment: .left)
            return label
        }()
        
        view.flex.define { flex in
            flex.addItem(optionText)
        }
        .paddingVertical(16)
        .paddingLeft(20)
        .backgroundColor(.white)
        .cornerRadius(16)
        
        view.addDropShadow()
        
        return view
    }()
    private let secondOptionView: UIView = {
        let view = UIView()
        let optionText: UILabel = {
            let label = UILabel()
            label.text = "그래도 직장은 계속 다닌다."
            styleLabel(for: label, fontStyle: .headline2, textColor: .black, alignment: .left)
            return label
        }()
        
        view.flex.define { flex in
            flex.addItem(optionText)
        }
        .paddingVertical(16)
        .paddingLeft(20)
        .backgroundColor(.white)
        .cornerRadius(16)
        
        view.addDropShadow()
        
        return view
    }()
    
    let voteButton = StyledButton(title: "답변을 선택해주세요", buttonStyle: .solid(.large, .inactive), cornerRadius: 8, verticalPadding: 18, horizontalPadding: 0)
    
    let submitVoteTopicButton: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = "투표하고 싶은 질문이 있다면?"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray100)
        
        let rightArrowIcon = UIImageView()
        let image = UIImage(named: "icon_arrow_right_in_button")
        rightArrowIcon.image = image
        rightArrowIcon.contentMode = .scaleAspectFit
        
        view.flex.direction(.row).gap(4).alignItems(.center).define { flex in
            flex.addItem(label)
            flex.addItem(rightArrowIcon)
                .size(14)
        }
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(rootFlexContainer)
        
        rootFlexContainer.flex.direction(.column).define { flex in
            flex.addItem(mateViewLabel)
                .alignSelf(.start)
                .marginBottom(2)
            flex.addItem()
                .direction(.row)
                .alignItems(.start)
                .justifyContent(.spaceBetween)
                .define { flex in
                    flex.addItem()
                        .direction(.row)
                        .alignItems(.start)
                        .define { flex in
                            flex.addItem(QLabel)
                                .marginRight(4)
                            flex.addItem(questionLabel)
                                .marginRight(21)
                        }
                    flex.addItem(syncIcon)
                        .size(24)
                }
                .marginBottom(20)
            flex.addItem(image)
                .paddingHorizontal(59.5)
                .marginBottom(28)
            flex.addItem(firstOptionView)
                .marginBottom(12)
            flex.addItem(secondOptionView)
                .marginBottom(24)
            flex.addItem(voteButton)
                .marginBottom(16)
            flex.addItem(submitVoteTopicButton)
                .alignSelf(.center)
            
        }
        .paddingHorizontal(20)
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
    let view = VoteView()
    return view
}
