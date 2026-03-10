//
//  Int+Extensions.swift
//  LottoMate
//
//  Created by Mirae on 12/25/24.
//

import Foundation

extension Int {
    func formattedWithSeparator() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    /// 숫자를 억 단위로 변환합니다.
    var toHundredMillion: Int {
        return self / 100_000_000
    }
}

// 옵셔널 Int에 대한 extension 추가
extension Optional where Wrapped == Int {
    /// 옵셔널 숫자를 억 단위로 변환합니다. nil이면 0을 반환합니다.
    var toHundredMillion: Int {
        return self.map { $0 / 100_000_000 } ?? 0
    }
}
