//
//  Buttons.swift
//  LottoMate
//
//  Created by Mirae on 7/23/24.
//

import UIKit
import Foundation

enum ButtonStatus: CaseIterable {
    case active
    case inactive
    case pressed
}

enum ButtonSize {
    case large
    case medium
    case small
    case round
    case xs
}

enum ButtonStyle {
    case solid(ButtonSize, ButtonStatus)
    case outline(ButtonSize, ButtonStatus)
    case text(ButtonSize, ButtonStatus)
    case assistive(ButtonSize, ButtonStatus)
    
    var backgroundColor: UIColor {
        switch self {
        case .solid(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return .ltm_E1464C
            case .inactive:
                return .disabledSolidBtnBg
            case .pressed:
                return .pressedSolidBtnBg
            }
        
        case .outline(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return .clear
            case .inactive:
                return .clear
            case .pressed:
                return .clear
            }
        
        case .text(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return .clear
            case .inactive:
                return .clear
            case .pressed:
                return .pressedTextBtnBg
            }
       
        case .assistive(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return .clear
            case .inactive:
                return .clear
            case .pressed:
                return .gray_EEEEEE
            }
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .solid(_, _):
            return .clear
        
        case .outline(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return .activeOutline
            case .inactive:
                return .inactiveOutline
            case .pressed:
                return .defaultOutline
            }
        
        case .text(_, _):
            return .clear
        
        case .assistive(_, _):
            return .gray_D2D2D2
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .solid(_, _):
            return .white
        
        case .outline(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return .activeOutlineBtnText
            case .inactive:
                return .inactiveOutlineBtnText
            case .pressed:
                return .defaultOutlineBtnText
            }
            
        case .text(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return .defaultTextBtnText
            case .inactive:
                return .diabledTextBtnText
            case .pressed:
                return .pressedTextBtnText
            }
        
        case .assistive(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return .black
            case .inactive:
                return .gray_D2D2D2
            case .pressed:
                return .black
            }
        }
    }
    
    var titleFontStyle: Typography {
        switch self {
        case .solid(let buttonSize, _):
            switch buttonSize {
            case .large, .medium:
                return .largeAndMediumButtonTitle
            case .small, .round:
                return .label2
            case .xs:
                return .caption1
            }
            
        case .outline(let buttonSize, _):
            switch buttonSize {
            case .large, .medium:
                return .largeAndMediumButtonTitle
            case .small, .round:
                return .label2
            case .xs:
                return .caption1
            }
            
        case .text(let buttonSize, _):
            switch buttonSize {
            case .large, .medium:
                return .largeAndMediumButtonTitle
            case .small, .round:
                return .label2
            case .xs:
                return .caption1
            }
            
        case .assistive(let buttonSize, _):
            switch buttonSize {
            case .large, .medium:
                return .largeAndMediumButtonTitle
            case .small, .round:
                return .label2
            case .xs:
                return .caption1
            }
        }
    }
    
    var hasBorder: Bool {
        switch self {
        case .solid(_, _):
            return false
        case .outline(_, _):
            return true
        case .text(_, _):
            return false
        case .assistive(_, _):
            return true
        }
    }
    
    var isDisabled: Bool {
        switch self {
        case .solid(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return false
            case .inactive:
                return true
            case .pressed:
                return false
            }
        
        case .outline(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return false
            case .inactive:
                return true
            case .pressed:
                return false
            }
        
        case .text(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return false
            case .inactive:
                return false
            case .pressed:
                return false
            }
        
        case .assistive(_, let buttonStatus):
            switch buttonStatus {
            case .active:
                return false
            case .inactive:
                return true
            case .pressed:
                return false
            }
        }
    }
}
