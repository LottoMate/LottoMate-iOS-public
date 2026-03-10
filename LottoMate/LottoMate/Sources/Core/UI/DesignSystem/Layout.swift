//
//  Layout.swift
//  LottoMate
//
//  Created by Mirae on 11/19/24.
//  비율로 크기 계산시 사용합니다.

import Foundation

enum Layout {
    /// 화면 너비에 대한 카드 뷰의 상대적 크기를 계산할 때 사용하는 비율입니다.
    /// UIScreen.width / 1.257 = PastVoteView.width
    static let pastVoteCardWidthDivisor: CGFloat = 1.257
    /// PastVoteView의 너비에 대한 높이를 계산할 때 사용하는 비율입니다.
    /// PastVoteView.width / 1.365 = PastVoteView.height
    static let pastVoteCardHeightDivisor: CGFloat = 1.365
}
