//
//  CircularAppleSignInButton.swift
//  LottoMate
//
//  Created by Mirae on 11/30/24.
//

import UIKit
import FlexLayout
import PinLayout

class CircularAppleSignInButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        clipsToBounds = true
        backgroundColor = .black
        
        if let appleBtnImage = UIImage(named: "Logo - SIWA - Logo-only - White") {
            var config = UIButton.Configuration.plain()
            config.background.backgroundColor = .black
            config.image = appleBtnImage
            config.contentInsets = NSDirectionalEdgeInsets(top: 3.5, leading: 0.5, bottom: 0, trailing: 0)
            
            configuration = config
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
}
