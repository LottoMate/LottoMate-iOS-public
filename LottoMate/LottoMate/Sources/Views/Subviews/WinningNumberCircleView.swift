//
//  WinningNumberCircleView.swift
//  LottoMate
//
//  Created by Mirae on 8/1/24.
//

import UIKit
import FlexLayout
import PinLayout

class WinningNumberCircleView: UILabel {
    var circleColor: UIColor = .black
    var number: Int = 0 {
        didSet {
            setNeedsDisplay() // Redraw the view when the number changes
        }
    }
    
    override func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            // Draw the circle
            let circlePath = UIBezierPath(ovalIn: rect)
            context.addPath(circlePath.cgPath)
            context.setFillColor(circleColor.cgColor)
            context.fillPath()
            
            // Draw the number
            let numberString = "\(number)" as NSString
            let fontDescriptor = UIFontDescriptor(name: "PretendardVariable-SemiBold", size: 14)
            let font = UIFont(descriptor: fontDescriptor, size: 14)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font.withSize(rect.width / 2),
                .foregroundColor: UIColor.white
            ]
        
            let textSize = numberString.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (rect.width - textSize.width) / 2,
                y: (rect.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            numberString.draw(in: textRect, withAttributes: attributes)
        }
}

#Preview {
    let circleView = WinningNumberCircleView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    circleView.number = 5
    circleView.circleColor = .black
    return circleView
}
