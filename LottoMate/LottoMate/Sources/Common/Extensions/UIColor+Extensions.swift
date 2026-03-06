//
//  UIColor+Extensions.swift
//  LottoMate
//
//  Created by Mirae on 8/3/24.
//

import UIKit

extension UIColor {
    static var gray_6B6B6B: UIColor {
        return UIColor(named: "6B6B6B") ?? .black
    }
    static var gray_F9F9F9: UIColor {
        return UIColor(named: "F9F9F9") ?? .clear
    }
    static var gray_858585: UIColor {
        return UIColor(named: "858585") ?? .clear
    }
    static var gray_EEEEEE: UIColor {
        return UIColor(named: "EEEEEE") ?? .clear
    }
    static var gray_D2D2D2: UIColor {
        return UIColor(named: "D2D2D2") ?? .clear
    }
    static var ltm_E1464C: UIColor {
        return UIColor(named: "E1464C") ?? .clear
    }
    static var gray_ACACAC: UIColor {
        return UIColor(named: "ACACAC") ?? .clear
    }
    static var gray_D9D9D9: UIColor {
        return UIColor(named: "D9D9D9") ?? .clear
    }
    
    // MARK: 각 로또 등수의 텍스트 컬러 (1등, 2등...)
    static var firstPrizeTextColor: UIColor {
        return UIColor(named: "red_50_default") ?? .black
    }
    static var secondPrizeTextColor: UIColor {
        return UIColor(named: "red_30") ?? .black
    }
    static var thirdPrizeTextColor: UIColor {
        return UIColor(named: "yellow_60") ?? .black
    }
    static var fourthPrizeTextColor: UIColor {
        return UIColor(named: "green_50_default") ?? .black
    }
    static var fifthPrizeTextColor: UIColor {
        return UIColor(named: "blue_40") ?? .black
    }
}
