//
//  LatestLotteryWinningInfoModel.swift
//  LottoMate
//
//  Created by Mirae on 8/27/24.
//

import Foundation

// MARK: - 최신 복권 당첨 정보 (Home에서 사용)
struct LatestLotteryWinningInfoModel: Codable, Equatable {
    let the645: The645
    let the720: The720
    let message: String
    let code: Int

    enum CodingKeys: String, CodingKey {
        case the645 = "645"
        case the720 = "720"
        case message, code
    }
}

// MARK: - 최신 로또 당첨 정보
struct The645: Codable, Equatable {
    /// 로또 회차 키
    let lottoDrwNo: Int
    /// 로또 종류
    let lottoType: String
    /// 로또 번호
    let lottoNum: [Int]
    /// 로또 보너스 번호
    let lottoBonusNum: [Int]
    /// 회차 날짜
    let drwDate: String
    /// 회차 번호
    let drwNum: Int
    /// 로또 총 판매 금액
    let totalSalesPrice: Int
    
    /// 로또 1등 당첨금
    let p1Jackpot: Int
    /// 로또 1등 당첨자 수
    let p1WinnrCnt: Int
    
    /// 로또 2등 당첨금
    let p2Jackpot: Int
    /// 로또 2등 당첨자 수
    let p2WinnrCnt: Int
    
    /// 로또 3등 당첨금
    let p3Jackpot: Int
    /// 로또 3등 당첨자 수
    let p3WinnrCnt: Int
    
    /// 로또 4등 당첨금
    let p4Jackpot: Int
    /// 로또 4등 당첨자 수
    let p4WinnrCnt: Int
    
    /// 로또 5등 당첨금
    let p5Jackpot: Int
    /// 로또 5등 당첨자 수
    let p5WinnrCnt: Int
}

// MARK: - 최신 연금 복권 당첨 정보
struct The720: Codable, Equatable {
    /// 연금복권 회차 키
    let lottoDrwNo: Int
    /// 연금복권 종류
    let lottoType: String
    /// 로또 번호
    let lottoNum: [Int]
    /// 로또 보너스 번호
    let lottoBonusNum: [Int]
    /// 회차 날짜
    let drwDate: String
    /// 회차 번호
    let drwNum: Int
    /// 연금 복권 1등 당첨자 수
    let p1WinnrCnt: Int
    /// 연금 복권 2등 당첨자 수
    let p2WinnrCnt: Int
    /// 연금 복권 3등 당첨자 수
    let p3WinnrCnt: Int
    /// 연금 복권 4등 당첨자 수
    let p4WinnrCnt: Int
    /// 연금 복권 5등 당첨자 수
    let p5WinnrCnt: Int
    /// 연금 복권 6등 당첨자 수
    let p6WinnrCnt: Int
    /// 연금 복권 7등 당첨자 수
    let p7WinnrCnt: Int
    /// 연금 복권 8등 당첨자 수
    let p8WinnrCnt: Int
}

extension LatestLotteryWinningInfoModel: LottoResultType {
    var drwNum: Int { the645.drwNum }
    var drwDate: String { the645.drwDate }
    var p1Jackpot: Int { the645.p1Jackpot }
    var p1WinnrCnt: Int { the645.p1WinnrCnt }
    var lottoNum: [Int] { the645.lottoNum }
    var lottoBonusNum: [Int] { the645.lottoBonusNum }
}

extension LatestLotteryWinningInfoModel: PensionResultType {
    var pensionDrwNum: Int { the720.drwNum }
    var pensionDrwDate: String { the720.drwDate }
    var pensionNum: [Int] { the720.lottoNum }
}
