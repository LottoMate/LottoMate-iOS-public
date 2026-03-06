//
//  WinningReviewDetailResponse.swift
//  LottoMate
//
//  Created by MEMER.D on 8/26/25.
//

import Foundation

// MARK: - Welcome
struct WinningReviewDetailResponse: Codable, Equatable {
    let reviewNo, reviewHref: Int?
    let reviewTitle, reviewCont: String?
    let reviewThumb: String?
    let reviewImg: [String]?
    let intrvDate, reviewDate: String?
    let lottoDrwNo, storeNo: Int?
    let storeAddr: String?
}
