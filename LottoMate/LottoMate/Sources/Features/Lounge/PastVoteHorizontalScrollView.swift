//
//  PastVoteHorizontalScrollView.swift
//  LottoMate
//
//  Created by Mirae on 11/19/24.
//

import UIKit
import PinLayout
import FlexLayout

class PastVoteHorizontalScrollView: UIView {
    fileprivate let rootFlexContainer = UIView()
    fileprivate let scrollView = UIScrollView()
    
    let samplePastVoteView1 = PastVoteView()
    let samplePastVoteView2 = PastVoteView()
    let samplePastVoteView3 = PastVoteView()
    let samplePastVoteView4 = PastVoteView()
    
    init() {
        super.init(frame: .zero)
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = false
        
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
        
        rootFlexContainer.flex.direction(.row)
            .gap(16)
            .paddingTop(20)
            .paddingBottom(98)
            .define { flex in
            flex.addItem(samplePastVoteView1).marginLeft(20)
            flex.addItem(samplePastVoteView2)
            flex.addItem(samplePastVoteView3)
            flex.addItem(samplePastVoteView4).marginRight(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.all()
        rootFlexContainer.pin.top().left().bottom()
        rootFlexContainer.flex.layout(mode: .adjustWidth)
        scrollView.contentSize = rootFlexContainer.frame.size
    }
}

#Preview {
    let view = PastVoteHorizontalScrollView()
    return view
}
