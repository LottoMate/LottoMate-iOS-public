//
//  StyledButton.swift
//  LottoMate
//
//  Created by Mirae on 7/25/24.
//

import UIKit

class StyledButton: UIButton {
    var style: ButtonStyle = .solid(.round, .active) {
        didSet {
            applyButtonStyle()
        }
    }
    var title: String = ""
    var cornerRadius: CGFloat = 0
    var verticalPadding: CGFloat = 0
    var horizontalPadding: CGFloat = 0
    
    init(title: String, buttonStyle: ButtonStyle, cornerRadius: CGFloat = 0, verticalPadding: CGFloat = 0, horizontalPadding: CGFloat = 0) {
        super.init(frame: .zero)
        
        self.title = title
        self.style = buttonStyle
        self.cornerRadius = cornerRadius
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        
        buttonSetUp()
        applyButtonStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isEnabled: Bool {
        didSet {
            applyButtonStyle()
        }
    }
    
    func buttonSetUp() {
        setTitle(title, for: .normal)
        layer.cornerRadius = cornerRadius
    }
    
    func applyButtonStyle() {
        let currentTitle = self.title(for: .normal) ?? self.title
        let attributedTitle = NSAttributedString(string: currentTitle, attributes: style.titleFontStyle.attributes())
        setAttributedTitle(attributedTitle, for: .normal)
        
        setTitleColor(style.textColor, for: isEnabled ? .normal : .disabled)
        backgroundColor = style.backgroundColor
        layer.borderWidth = 1
        layer.borderColor = style.borderColor.cgColor
        contentEdgeInsets =  UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        titleLabel?.lineBreakMode = .byWordWrapping
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        if state == .normal && title != nil {
            self.title = title!
        }
        applyButtonStyle()
    }
}

#Preview {
    let styledBtnView = StyledButton(title: "스피또", buttonStyle: .solid(.round, .active),  cornerRadius: 17, verticalPadding: 6, horizontalPadding: 16)

    return styledBtnView
}
