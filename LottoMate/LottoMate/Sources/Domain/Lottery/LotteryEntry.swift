//
//  LotteryEntry.swift
//  LottoMate
//
//  Created by Mirae on 3/10/26.
//

import Foundation

struct LotteryEntry: Codable, Identifiable {
    let id: UUID
    let type: InputLotteryType
    let round: Int
    let drawDate: String
    let numbers: [Int]
    let isWinning: Bool
    let isWinningChecked: Bool
    let createdAt: Date
    
    init(type: InputLotteryType, round: Int, drawDate: String, numbers: [Int]) {
        self.id = UUID()
        self.type = type
        self.round = round
        self.drawDate = drawDate
        self.numbers = numbers
        self.isWinning = false
        self.isWinningChecked = false
        self.createdAt = Date()
    }
    
    // 당첨 상태 업데이트를 위한 생성자
    init(from entry: LotteryEntry, isWinning: Bool, isWinningChecked: Bool) {
        self.id = entry.id
        self.type = entry.type
        self.round = entry.round
        self.drawDate = entry.drawDate
        self.numbers = entry.numbers
        self.isWinning = isWinning
        self.isWinningChecked = isWinningChecked
        self.createdAt = entry.createdAt
    }
}
