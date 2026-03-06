//
//  ReviewListResponse.swift
//  LottoMate
//
//  Created by Mirae on 12/27/24.
//

import Foundation

struct WinningReviewListResponse: Codable {
    /// 리뷰 번호
    let reviewNo: Int
    /// 리뷰 링크
    let reviewHref: Int
    /// 리뷰 제목
    let reviewTitle: String
    /// 리뷰 썸네일 이미지 (aws 링크)
    let reviewThumb: String?
    /// 인터뷰 날짜
    let intrvDate: String
    /// 당첨 복권 종류와 등수
    let reviewPlace: String
}
