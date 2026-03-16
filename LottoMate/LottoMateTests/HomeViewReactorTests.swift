//
//  HomeViewReactorTests.swift
//  LottoMateTests
//
//  Created by Mirae on 3/16/26.
//

import XCTest
@testable import LottoMate

final class HomeViewReactorTests: XCTestCase {
    private var reactor: HomeViewReactor!

    override func setUp() {
        super.setUp()
        reactor = HomeViewReactor()
    }

    override func tearDown() {
        reactor = nil
        super.tearDown()
    }

    // 복권 타입 선택 mutation이 선택 상태를 바꾸는지 확인합니다.
    func testReduce_setSelectedLotteryType_updatesSelectedType() {
        let initialState = reactor.initialState

        let newState = reactor.reduce(
            state: initialState,
            mutation: .setSelectedLotteryType(.pensionLottery)
        )

        XCTAssertEqual(newState.selectedLotteryType, .pensionLottery)
    }

    // 홈 당첨 정보 반영 시 최신 회차와 현재 회차가 함께 설정되는지 확인합니다.
    func testReduce_setLotteryResult_updatesLatestAndCurrentRounds() throws {
        let result = try makeLatestLotteryWinningInfoModel()

        let newState = reactor.reduce(
            state: reactor.initialState,
            mutation: .setLotteryResult(result)
        )

        XCTAssertEqual(newState.latestLotteryResult, result)
        XCTAssertEqual(newState.latestLottoRound, result.the645.drwNum)
        XCTAssertEqual(newState.currentLottoRound, result.the645.drwNum)
        XCTAssertEqual(newState.latestPensionRound, result.the720.drwNum)
        XCTAssertEqual(newState.currentPensionLotteryRound, result.the720.drwNum)
    }

    // 로또 현재 회차가 최신 회차와 같을 때만 오른쪽 화살표가 숨겨지는지 확인합니다.
    func testReduce_setCurrentLottoRound_hidesRightArrowAtLatestRound() throws {
        let result = try makeLatestLotteryWinningInfoModel()
        let stateWithLatestRound = reactor.reduce(
            state: reactor.initialState,
            mutation: .setLotteryResult(result)
        )

        let latestRoundState = reactor.reduce(
            state: stateWithLatestRound,
            mutation: .setCurrentLottoRound(result.the645.drwNum)
        )

        let previousRoundState = reactor.reduce(
            state: stateWithLatestRound,
            mutation: .setCurrentLottoRound(result.the645.drwNum - 1)
        )

        XCTAssertTrue(latestRoundState.isLottoRightArrowIconHidden)
        XCTAssertFalse(previousRoundState.isLottoRightArrowIconHidden)
    }

    // 연금복권 현재 회차가 최신 회차와 같을 때만 오른쪽 화살표가 숨겨지는지 확인합니다.
    func testReduce_setCurrentPensionRound_hidesRightArrowAtLatestRound() throws {
        let result = try makeLatestLotteryWinningInfoModel()
        let stateWithLatestRound = reactor.reduce(
            state: reactor.initialState,
            mutation: .setLotteryResult(result)
        )

        let latestRoundState = reactor.reduce(
            state: stateWithLatestRound,
            mutation: .setCurrentPensionRound(result.the720.drwNum)
        )

        let previousRoundState = reactor.reduce(
            state: stateWithLatestRound,
            mutation: .setCurrentPensionRound(result.the720.drwNum - 1)
        )

        XCTAssertTrue(latestRoundState.isPensionRightArrowIconHidden)
        XCTAssertFalse(previousRoundState.isPensionRightArrowIconHidden)
    }

    // 지도 이동 플래그가 mutation마다 토글되는지 확인합니다.
    func testReduce_showMap_togglesVisibility() {
        let visibleState = reactor.reduce(
            state: reactor.initialState,
            mutation: .showMap
        )
        let hiddenState = reactor.reduce(
            state: visibleState,
            mutation: .showMap
        )

        XCTAssertTrue(visibleState.isMapVisible)
        XCTAssertFalse(hiddenState.isMapVisible)
    }

    // QR 스캐너 표시 플래그가 mutation마다 토글되는지 확인합니다.
    func testReduce_showQrScanner_togglesVisibility() {
        let visibleState = reactor.reduce(
            state: reactor.initialState,
            mutation: .showQrScanner
        )
        let hiddenState = reactor.reduce(
            state: visibleState,
            mutation: .showQrScanner
        )

        XCTAssertTrue(visibleState.isQrScannerVisible)
        XCTAssertFalse(hiddenState.isQrScannerVisible)
    }

    // 당첨 결과 초기화 mutation이 winningResult를 nil로 되돌리는지 확인합니다.
    func testReduce_resetWinningResult_clearsWinningResult() {
        let winningResult = [
            LottoNumberWithRank(numbers: [1, 2, 3, 4, 5, 6], rank: 1, drwNo: 1000)
        ]
        let stateWithResult = reactor.reduce(
            state: reactor.initialState,
            mutation: .setWinningResult(winningResult)
        )

        let clearedState = reactor.reduce(
            state: stateWithResult,
            mutation: .resetWinningResult
        )

        XCTAssertEqual(stateWithResult.winningResult, winningResult)
        XCTAssertNil(clearedState.winningResult)
    }

    // 저장 관련 상태 초기화 mutation이 로딩/성공/에러 상태를 모두 리셋하는지 확인합니다.
    func testReduce_resetSaveState_resetsFlagsAndError() {
        let error = NSError(domain: "HomeViewReactorTests", code: 1)
        let loadingState = reactor.reduce(
            state: reactor.initialState,
            mutation: .setSaveLoading(true)
        )
        let successState = reactor.reduce(
            state: loadingState,
            mutation: .setSaveSuccess(true)
        )
        let errorState = reactor.reduce(
            state: successState,
            mutation: .setSaveError(error)
        )

        let resetState = reactor.reduce(
            state: errorState,
            mutation: .resetSaveState
        )

        XCTAssertFalse(resetState.saveLoading)
        XCTAssertFalse(resetState.saveSuccess)
        XCTAssertNil(resetState.saveError)
    }

    // 공지 화면 표시 플래그가 mutation마다 토글되는지 확인합니다.
    func testReduce_showNoticeView_togglesVisibility() {
        let visibleState = reactor.reduce(
            state: reactor.initialState,
            mutation: .showNoticeView
        )
        let hiddenState = reactor.reduce(
            state: visibleState,
            mutation: .showNoticeView
        )

        XCTAssertTrue(visibleState.isNoticeViewVisible)
        XCTAssertFalse(hiddenState.isNoticeViewVisible)
    }

    private func makeLatestLotteryWinningInfoModel() throws -> LatestLotteryWinningInfoModel {
        let data = LottoMateEndpoint.getLottoHome.sampleData
        return try JSONDecoder().decode(LatestLotteryWinningInfoModel.self, from: data)
    }
}
