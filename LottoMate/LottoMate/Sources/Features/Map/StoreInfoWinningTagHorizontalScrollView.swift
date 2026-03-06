//
//  StoreInfoWinningTagHorizontalScrollView.swift
//  LottoMate
//
//  Created by Mirae on 10/8/24.
//

import UIKit
import PinLayout
import FlexLayout

class StoreInfoWinningTagHorizontalScrollView: UIView {
    fileprivate let rootFlexContainer = UIView()
    fileprivate let scrollView = UIScrollView()
    
    private let leftPaddingView = UIView()
    private let rightPaddingView = UIView()
    private var lottoInfos: [LottoInfo] = []
    
    // LottoType enum
    enum LottoType {
        case lotto645     // L645
        case pension720   // L720
        case speeto500    // S500
        case speeto1000   // S1000
        case speeto2000   // S2000
        
        init?(serverType: String) {
            switch serverType {
            case "L645": self = .lotto645
            case "L720": self = .pension720
            case "S500": self = .speeto500
            case "S1000": self = .speeto1000
            case "S2000": self = .speeto2000
            default: return nil
            }
        }
        
        var displayText: String {
            switch self {
            case .lotto645: return "로또"
            case .pension720: return "연금복권"
            case .speeto500: return "스피또 500"
            case .speeto1000: return "스피또 1000"
            case .speeto2000: return "스피또 2000"
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .lotto645: return .green5
            case .pension720: return .blue5
            case .speeto500, .speeto1000, .speeto2000: return .peach5
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = false
        
        leftPaddingView.backgroundColor = .white
        rightPaddingView.backgroundColor = .white
        
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
        addSubview(leftPaddingView)
        addSubview(rightPaddingView)
    }
    
    // Configure 함수
    func configure(with lottoInfos: [LottoInfo]) {
        self.lottoInfos = lottoInfos
        setupLayout()
        setNeedsLayout()
    }
    
    private func setupLayout() {
        rootFlexContainer.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        rootFlexContainer
            .flex
            .direction(.row)
            .gap(16)
            .paddingLeft(20)
            .paddingTop(20)
            .paddingRight(20)
            .backgroundColor(.white)
            .define { flex in
                let itemsPerColumn = 4
                let itemCount = lottoInfos.count
                let columns = Int(ceil(Double(itemCount) / Double(itemsPerColumn)))
                
                for columnIndex in 0..<columns {
                    flex.addItem()
                        .direction(.column)
                        .gap(8)
                        .define { columnFlex in
                            let startIndex = columnIndex * itemsPerColumn
                            let endIndex = min(startIndex + itemsPerColumn, itemCount)
                            
                            for i in startIndex..<endIndex {
                                let info = lottoInfos[i]
                                guard let lottoType = LottoType(serverType: info.lottoType) else { continue }
                                
                                let lotteryTypeLabel = UILabel()
                                lotteryTypeLabel.text = "\(lottoType.displayText) \(info.place)등"
                                styleLabel(for: lotteryTypeLabel, fontStyle: .label1, textColor: .black)
                                
                                let prizeMoney = UILabel()
                                prizeMoney.text = info.lottoJackpot == nil ? "" : "\(info.lottoJackpot.toHundredMillion)억원 당첨"
                                styleLabel(for: prizeMoney, fontStyle: .label2, textColor: .black)
                                
                                let roundNumber = UILabel()
                                roundNumber.text = "\(info.drwNum)회"
                                styleLabel(for: roundNumber, fontStyle: .caption1, textColor: .gray100)
                                
                                columnFlex
                                    .addItem()
                                    .direction(.row)
                                    .alignSelf(.start)
                                    .gap(4)
                                    .alignItems(.end)
                                    .paddingVertical(4)
                                    .paddingHorizontal(12)
                                    .backgroundColor(lottoType.backgroundColor)
                                    .cornerRadius(8)
                                    .define { flex in
                                        flex.addItem(lotteryTypeLabel)
                                        flex.addItem(prizeMoney)
                                        flex.addItem(roundNumber)
                                    }
                            }
                        }
                }
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leftPaddingView.pin
            .left()
            .top()
            .bottom()
            .width(20)
        
        rightPaddingView.pin
            .right()
            .top()
            .bottom()
            .width(20)
        
        scrollView.pin.all()
        rootFlexContainer.pin.top(pin.safeArea.top).left().bottom()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        rootFlexContainer.flex.layout(mode: .adjustWidth)
        scrollView.contentSize = rootFlexContainer.frame.size
        
        bringSubviewToFront(leftPaddingView)
        bringSubviewToFront(rightPaddingView)
    }
}

#Preview {
    StoreInfoWinningTagHorizontalScrollView()
}
