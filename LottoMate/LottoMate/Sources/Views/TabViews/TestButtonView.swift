//
//  TestHomeView .swift
//  LottoMate
//
//  Created by Mirae on 7/25/24.
//  임시 Home

import UIKit
import FlexLayout
import PinLayout
import SwiftSoup
import RxSwift

class TestButtonView: UIView {
    var viewModel = LottoMateViewModel.shared
    let disposeBag = DisposeBag()
    
    fileprivate let rootFlexContainer = UIView()
    
    public let defaultSolidButton = StyledButton(title: "Test Button", buttonStyle: .solid(.large, .active), cornerRadius: 8, verticalPadding: 0, horizontalPadding: 0)
    
    let textView = UITextView()
    
    let shadowButtonWithIconAndTitle = ShadowRoundButton(title: "복권 전체", icon: UIImage(named: "icon_filter"))
    let shadowButtonWithOnlyTitle = ShadowRoundButton(title: "당첨 판매점")
    let shadowButtonWithOnlyIcon = ShadowRoundButton(icon: UIImage(named: "icon_filter"))
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .gray130
        
//        #if !NO_SERVER
        viewModel.fetchLottoHome()
        bindData()
//        #endif
                
        defaultSolidButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        parseHtml()
        
        addSubview(rootFlexContainer)
        
        rootFlexContainer.flex.direction(.column).define { flex in
            flex.addItem(defaultSolidButton).width(127).height(48).marginBottom(48)
            flex.addItem().direction(.column).gap(48).define { flex in
                flex.addItem(shadowButtonWithIconAndTitle)
                flex.addItem(shadowButtonWithOnlyTitle)
                flex.addItem(shadowButtonWithOnlyIcon)
            }
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
    
    func bindData() {
        viewModel.latestLotteryResult
            .subscribe(onNext: { result in
                if let latestLottoDrawNumber = result?.the645.drwNum {
                    self.viewModel.fetchLottoResult(round: latestLottoDrawNumber)
                }
                if let latestPensionLotteryResult = result?.the720.drwNum {
                    self.viewModel.fetchPensionLotteryResult(round: latestPensionLotteryResult)
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func buttonTapped(_ sender: Any) {
        print("Button tapped")
    }
    
    
    func parseHtml() {
        do {
            let html = SampleHtmlDoc.sampleData
            let doc: Document = try SwiftSoup.parse(html)
            let elements: Elements = try doc.select("span")
            
            let lineSpacing: CGFloat = 2.0
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            
            let attributedString = NSMutableAttributedString()
            
            for div in elements {
                let text = try div.text()
                
                if text.first == "▶" {
                    let boldTextAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 14),
                        .paragraphStyle: paragraphStyle
                    ]
                    let atrributedText = NSAttributedString(string: (text + "\n"), attributes: boldTextAttributes)
                    attributedString.append(atrributedText)
                    
                } else if text.prefix(2) == "->" {
                    let smallTextAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 12),
                        .paragraphStyle: paragraphStyle
                    ]
                    let atrributedText = NSAttributedString(string: (text + "\n\n"), attributes: smallTextAttributes)
                    attributedString.append(atrributedText)
                    
                } else {
                    // Default style 주기
                }
            }
            textView.attributedText = attributedString
            
        } catch Exception.Error(_, let message) {
            print("parseHtml message: \(message)")
        } catch {
            print("An error occurs parsing html doc.")
        }
    }
}

#Preview {
    let preview = TestButtonView()
    return preview
}
