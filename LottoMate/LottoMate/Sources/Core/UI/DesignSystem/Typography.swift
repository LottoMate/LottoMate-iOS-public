//
//  Typography.swift
//  LottoMate
//
//  Created by Mirae on 7/30/24.
//

import UIKit

public enum Typography {
    case display1
    case display2
    case title1
    case title2
    case title3
    case headline1
    case headline2
    case body1
    case body2
    case label1
    case label2
    case caption1
    case caption2
    case largeAndMediumButtonTitle
    ///  커스텀 폰트 (weight는 String 타입으로 폰트 이름을 입력해 주어야 함.    PretendardVariable-Regular, PretendardVariable-Thin, PretendardVariable-ExtraLight, PretendardVariable-Light, PretendardVariable-Medium, PretendardVariable-SemiBold, PretendardVariable-Bold, PretendardVariable-ExtraBold, PretendardVariable-Black)
    case custom(weight: String, size: CGFloat, lineHeight: CGFloat, letterSpacing: CGFloat)
    
    
    var size: CGFloat {
        switch self {
        case .display1:
            return 48
        case .display2:
            return 40
        case .title1:
            return 36
        case .title2:
            return 28
        case .title3:
            return 24
        case .headline1:
            return 18
        case .headline2:
            return 16
        case .body1:
            return 16
        case .body2:
            return 16
        case .label1:
            return 14
        case .label2:
            return 14
        case .caption1:
            return 12
        case .caption2:
            return 10
        case .custom(_, let size, _, _):
            return size
        case .largeAndMediumButtonTitle:
            return 16
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .display1:
            return 62
        case .display2:
            return 54
        case .title1:
            return 48
        case .title2:
            return 40
        case .title3:
            return 34
        case .headline1:
            return 28
        case .headline2:
            return 24
        case .body1:
            return 24
        case .body2:
            return 24
        case .label1:
            return 22
        case .label2:
            return 22
        case .caption1:
            return 18
        case .caption2:
            return 16
        case .custom(_, _, let lineHeight, _):
            return lineHeight
        case .largeAndMediumButtonTitle:
            return 24
        }
    }
    
    var letterSpacing: CGFloat {
        switch self {
        case .custom(_, _, _, let letterSpacing):
            return letterSpacing
        default:
            return -0.6
        }
    }
    
    func font() -> UIFont {
        let fontName: String
        switch self {
        case .display1, .display2, .title1, .title2, .title3, .headline1, .headline2:
            fontName = "PretendardVariable-Bold"
        case .body1, .label1, .caption2:
            fontName = "PretendardVariable-Medium"
        case .body2:
            fontName = "PretendardVariable-Regular"
        case .label2, .caption1:
            fontName = "PretendardVariable-SemiBold"
        case .custom(let weight, _, _, _):
            fontName = weight
        case .largeAndMediumButtonTitle:
            fontName = "PretendardVariable-SemiBold"
        }

        let fontDescriptor = UIFontDescriptor(name: fontName, size: self.size)
            .addingAttributes([
                .featureSettings: [
                    [
                        UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                        UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector
                    ]
                ]
            ])
        let font = UIFont(descriptor: fontDescriptor, size: self.size)
        
        return font
    }
    
    func attributes(alignment: NSTextAlignment = .center) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.minimumLineHeight = self.lineHeight
        paragraphStyle.maximumLineHeight = self.lineHeight
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let font = font()
        let baselineOffset = (self.lineHeight - font.lineHeight) / 2.0
        
        return [
            .font: font,
            .kern: self.letterSpacing,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: baselineOffset
        ]
    }
}

// MARK: 사용
public func styleLabel(for label: UILabel, fontStyle: Typography, textColor: UIColor, alignment: NSTextAlignment = .center) {
    let fontStyle: Typography = fontStyle
    let attributedString = NSAttributedString(string: label.text ?? "", attributes: fontStyle.attributes(alignment: alignment))
    
    label.attributedText = attributedString
    label.textColor = textColor
}
