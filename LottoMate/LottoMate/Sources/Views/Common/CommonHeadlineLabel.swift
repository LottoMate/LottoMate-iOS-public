//
//  CommonHeadline1Label.swift
//  LottoMate
//
//  Created by Mirae on 11/11/24.
//

import UIKit

class CommonHeadline1Label: UILabel {
    
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        self.numberOfLines = 2
        styleLabel(for: self, fontStyle: .headline1, textColor: .black)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CommonTitle3Label: UILabel {
    
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        self.numberOfLines = 2
        styleLabel(for: self, fontStyle: .title3, textColor: .black, alignment: .left)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
