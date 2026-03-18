//
//  WinningInfoDetailState.swift
//  LottoMate
//
//  Created by Mirae on 3/18/26.
//

import Foundation

struct WinningInfoDetailState {
    var selectedLotteryType: LotteryType
    var latestLotteryResult: LatestLotteryWinningInfoModel?
    var lottoRoundResult: LottoResultModel?
    var pensionRoundResult: PensionLotteryResultModel?
    var currentLottoRound: Int?
    var currentPensionLotteryRound: Int?

    init(
        selectedLotteryType: LotteryType,
        latestLotteryResult: LatestLotteryWinningInfoModel? = nil,
        lottoRoundResult: LottoResultModel? = nil,
        pensionRoundResult: PensionLotteryResultModel? = nil,
        currentLottoRound: Int? = nil,
        currentPensionLotteryRound: Int? = nil
    ) {
        self.selectedLotteryType = selectedLotteryType
        self.latestLotteryResult = latestLotteryResult
        self.lottoRoundResult = lottoRoundResult
        self.pensionRoundResult = pensionRoundResult
        self.currentLottoRound = currentLottoRound
        self.currentPensionLotteryRound = currentPensionLotteryRound
    }
}
