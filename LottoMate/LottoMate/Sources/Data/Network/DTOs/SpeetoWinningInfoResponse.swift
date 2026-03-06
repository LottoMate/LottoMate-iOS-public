//
//  SpeetoWinningInfoResponse.swift
//  LottoMate
//
//  Created by Mirae on 3/11/25.
//

import Foundation

/// 스피또 당첨 정보 응답 모델
struct SpeetoWinningInfoResponse: Codable {
    let message: String
    let code: Int
    let storeLottoDrwInfoSpeeto: StoreLottoDrwInfoSpeeto

    enum CodingKeys: String, CodingKey {
        case message, code
        case storeLottoDrwInfoSpeeto = "store_lotto_drw_info_speeto"
    }
}

struct StoreLottoDrwInfoSpeeto: Codable {
    let pageNum, pageSize, totalPages, totalElements: Int
    let content: [SpeetoWinningStore]
}

struct SpeetoWinningStore: Codable, Equatable {
    let payDate: String
    let drwNum: Int
    let reviewHref: String?
    let place: Int
    let storeNm: String
}
