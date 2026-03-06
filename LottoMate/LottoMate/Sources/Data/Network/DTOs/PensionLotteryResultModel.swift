//
//  PensionLotteryResultModel.swift
//  LottoMate
//
//  Created by Mirae on 8/28/24.
//

import Foundation

// MARK: - 연금복권 추첨 결과 정보(당첨 번호, 당첨금 등)

struct PensionLotteryResultModel: Codable {
    let pensionLotteryResult: PensionLotteryResult
    let message: String
    let code: Int

    enum CodingKeys: String, CodingKey {
        case pensionLotteryResult = "720"
        case message, code
    }
}

/// 연금복권 추첨 결과 정보 모델 (당첨 번호, 당첨금 등)
struct PensionLotteryResult: Codable, PensionResultType {
    var pensionDrwNum: Int {
        self.drwNum
    }
    var pensionDrwDate: String {
        self.drwDate
    }
    var pensionNum: [Int] {
        self.lottoNum
    }
    
    /// 로또 회차 키
    let lottoDrwNo: Int
    /// 복권 타입 (e.g. 'L645', 'L720', 'S500', 'S1000', 'S2000')
    let lottoType: String
    let lottoNum: [Int]
    let lottoBonusNum: [Int]
    let drwDate: String
    /// 로또 회차 번호
    let drwNum: Int
    let p1WinnrCnt: Int
    let p2WinnrCnt: Int
    let p3WinnrCnt: Int
    let p4WinnrCnt: Int
    let p5WinnrCnt: Int
    let p6WinnrCnt: Int
    let p7WinnrCnt: Int
    let p8WinnrCnt: Int
}
