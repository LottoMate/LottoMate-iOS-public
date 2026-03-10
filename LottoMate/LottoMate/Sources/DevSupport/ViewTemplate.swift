//
//  ViewTemplate.swift
//  LottoMate
//
//  Created by Mirae on 8/8/24.
//

import UIKit
import PinLayout
import FlexLayout

class ViewTemplate: UIView {
    fileprivate let rootFlexContainer = UIView()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(rootFlexContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews() 
    }
}

#Preview {
    let view = ViewTemplate()
    return view
}
