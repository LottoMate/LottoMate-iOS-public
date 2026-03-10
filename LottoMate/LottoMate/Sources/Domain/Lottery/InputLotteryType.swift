//
//  InputLotteryType.swift
//  LottoMate
//
//  Created by Mirae on 3/10/26.
//

import Foundation

enum InputLotteryType: String, CaseIterable, Codable {
    case lotto = "lotto"
    case pension = "pension"
    
    var displayName: String {
        switch self {
        case .lotto:
            return "로또"
        case .pension:
            return "연금복권"
        }
    }
}
