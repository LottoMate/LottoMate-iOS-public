//
//  LottoResultModel.swift
//  LottoMate
//
//  Created by Mirae on 8/12/24.
//

import Foundation

// MARK: - 로또 추첨 결과 정보(당첨 번호, 당첨금 등)

struct LottoResultModel: Codable {
    let lottoResult: LottoResult
    let message: String
    let code: Int

    enum CodingKeys: String, CodingKey {
        case lottoResult = "645"
        case message, code
    }
}

/// 로또 추첨 결과 정보 모델 (당첨 번호, 당첨금 등)
struct LottoResult: Codable, LottoResultType {
    /// 로또 회차 키
    let lottoDrwNo: Int
    /// 복권 타입 (e.g. 'L645', 'L720', 'S500', 'S1000', 'S2000')
    let lottoType: String
    /// 로또 번호
    let lottoNum: [Int]
    /// 로또 보너스 번호
    let lottoBonusNum: [Int]
    /// 로또 회차 날짜
    let drwDate: String
    /// 로또 회차 번호
    let drwNum: Int
    /// 로또 총 판매 금액
    let totalSalesPrice: Int
    
    /// 로또 1등 당첨금
    let p1Jackpot: Int
    /// 로또 1등 당첨자 수
    let p1WinnrCnt: Int
    /// 당첨금을 당첨자 수로 나눈 값
    let p1PerJackpot: Int
    
    /// 로또 2등 당첨금
    let p2Jackpot: Int
    /// 로또 2등 당첨자 수
    let p2WinnrCnt: Int
    /// 당첨금을 당첨자 수로 나눈 값
    let p2PerJackpot: Int
    
    /// 로또 3등 당첨금
    let p3Jackpot: Int
    /// 로또 3등 당첨자 수
    let p3WinnrCnt: Int
    /// 당첨금을 당첨자 수로 나눈 값
    let p3PerJackpot: Int
    
    /// 로또 4등 당첨금
    let p4Jackpot: Int
    /// 로또 4등 당첨자 수
    let p4WinnrCnt: Int
    /// 당첨금을 당첨자 수로 나눈 값
    let p4PerJackpot: Int
    
    /// 로또 5등 당첨금
    let p5Jackpot: Int
    /// 로또 5등 당첨자 수
    let p5WinnrCnt: Int
    /// 당첨금을 당첨자 수로 나눈 값
    let p5PerJackpot: Int
}
