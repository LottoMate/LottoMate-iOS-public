//
//  UIView+Extensions.swift
//  LottoMate
//
//  Created by Mirae on 8/2/24.
//

import UIKit

extension UIView {
    /// 뷰에 그림자를 추가합니다.
    func addDropShadow() {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.withAlphaComponent(0.16).cgColor
        layer.shadowRadius = 8 / 2
        layer.shadowOpacity = 1

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    /// 복권 등수별 당첨 정보 카드뷰 기본 설정
    func configureCardView(for rootFlexContainer: UIView) {
        rootFlexContainer.backgroundColor = .white
        rootFlexContainer.layer.borderWidth = 1
        rootFlexContainer.layer.borderColor = UIColor.lightestGray.cgColor
        rootFlexContainer.layer.cornerRadius = 16
    }
    
    func colorForNumber(_ number: Int) -> UIColor {
        switch number {
        case 1...10:
            return .yellow50Default
        case 11...20:
            return .blue50Default
        case 21...30:
            return .red50Default
        case 31...40:
            return .gray90
        case 41...45:
            return .green50Default
        default:
            return .gray // 범위 밖의 숫자에 대해 기본값 설정
        }
    }
    
    func colorForPensionNumber(index: Int) -> UIColor {
       switch index {
       case 0:
           return .gray140
       case 1:
           return .red50Default
       case 2:
           return .ltmPeach
       case 3:
           return .ltmYellow
       case 4:
           return .ltmBlue
       case 5:
           return .blue30
       case 6:
           return .gray100
       default:
           return .gray
       }
    }
}
