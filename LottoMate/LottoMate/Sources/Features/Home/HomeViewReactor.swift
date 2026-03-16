//
//  HomeViewReactor.swift
//  LottoMate
//
//  Created by Mirae on 11/11/24.
//

import ReactorKit
import RxSwift

final class HomeViewReactor: Reactor {
    private let lottoMateAPIService = LottoMateAPIService()
    private let storageService = StorageService.shared
    
    enum Action {
        case selectLotteryType(LotteryType)
        case fetchInitialData
        case showLotteryTypeDetailView
        case hideLotteryTypeDetailView
        case fetchPreviousLottoRound
        case fetchNextLottoRound
        case fetchPreviousPensionRound
        case fetchNextPensionRound
//        case fetchPreviousSpeetoRound
//        case fetchNextSpeetoRound
//        case fetchSpeetoResult(Int)
        case showMapViewController
        case checkWinningViewTapped
        case fetchLottoResult(Int)
        case fetchPensionLotteryResult(Int)
        case checkWinning(drwNo: Int, numbers: [[Int]])
        case resetWinningResult
        case saveLottoNumbers([[Int]], String) // numbers, lottoDrwNo
        case savePensionNumbers([[String]], String) // numbers, lottoDrwNo
        case resetSaveState
        /// Footer의 '공지사항' 버튼이 탭 됨
        case noticeButtonTapped
    }
    
    enum Mutation {
        case setSelectedLotteryType(LotteryType)
        case setLoading(Bool)
        case setLotteryResult(LatestLotteryWinningInfoModel)
        case setCurrentLottoRound(Int)
        case setLottoRoundResult(LottoResultModel)
        case setCurrentPensionRound(Int)
        case setPensionRoundResult(PensionLotteryResultModel)
        case setCurrentSpeetoRound(Int)
//        case setSpeetoRoundResult(SpeetoResultModel)
        case setError(Error)
        case setLotteryTypeDetail(Bool)
        case showMap
        case showQrScanner
        case setWinningResult([LottoNumberWithRank])
        case resetWinningResult
        case setSaveLoading(Bool)
        case setSaveSuccess(Bool)
        case setSaveError(Error)
        case resetSaveState
        /// Footer의 '공지사항' 버튼 탭을 통해 공지사항 화면을 보여주거나 이동 (동작 확정되지 않음)
        case showNoticeView
    }
    
    struct State {
        var selectedLotteryType: LotteryType
        var latestLotteryResult: LatestLotteryWinningInfoModel?
        var lottoRoundResult: LottoResultModel?
        var pensionRoundResult: PensionLotteryResultModel?
//        var speetoRoundResult: SpeetoResultModel?
        var latestLottoRound: Int?
        var latestPensionRound: Int?
        var latestSpeetoRound: Int?
        var currentLottoRound: Int?
        var currentPensionLotteryRound: Int?
        var currentSpeetoRound: Int?
        var isLottoRightArrowIconHidden: Bool = true
        var isPensionRightArrowIconHidden: Bool = true
        var isSpeetoRightArrowIconHidden: Bool = true
        var isLoading: Bool = false
        var error: Error?
        var showLotteryTypeDetail: Bool = false
        var isMapVisible = false
        var isQrScannerVisible = false
        var winningResult: [LottoNumberWithRank]? = nil
        var saveLoading: Bool = false
        var saveSuccess: Bool = false
        var saveError: Error?
        var isNoticeViewVisible: Bool = false
    }
    
    let initialState: State
    
    init(initialLotteryType: LotteryType = .lotto) {
        self.initialState = State(selectedLotteryType: initialLotteryType)
    }
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .selectLotteryType(type):
            return .just(.setSelectedLotteryType(type))
        
        case .fetchInitialData:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                lottoMateAPIService.getLottoHome()
                    .map { Mutation.setLotteryResult($0) }
                    .catch { Observable.just(Mutation.setError($0)) }
                    .asObservable(),
                
                Observable.just(Mutation.setLoading(false))
            ])
        
        case .showLotteryTypeDetailView:
            return .just(Mutation.setLotteryTypeDetail(true))
        
        case .hideLotteryTypeDetailView:
            return .just(Mutation.setLotteryTypeDetail(false))
        
        case .fetchPreviousLottoRound:
            // 첫회차가 몇일까? 1이면 1이상일때라는 조건 추가하기
            guard let currentLottoRound = currentState.currentLottoRound else { return .empty() }
            let previousLottoRound = currentLottoRound - 1
            return Observable.concat([
                .just(Mutation.setCurrentLottoRound(previousLottoRound)),
                
                lottoMateAPIService.getLottoResult(round: previousLottoRound)
                    .map { Mutation.setLottoRoundResult($0) }
                    .catch { .just(.setError($0)) }
            ])
        
        case .fetchNextLottoRound:
            guard let currentLottoRound = currentState.currentLottoRound,
                  let maxLottoRound = currentState.latestLottoRound else { return .empty() }
            guard currentLottoRound < maxLottoRound else { return .empty() }
            
            let nextLottoRound = currentLottoRound + 1
            
            return Observable.concat([
                .just(Mutation.setCurrentLottoRound(nextLottoRound)),
                
                lottoMateAPIService.getLottoResult(round: nextLottoRound)
                    .map { Mutation.setLottoRoundResult($0) }
                    .catch { .just(.setError($0)) }
            ])
        
        case .fetchPreviousPensionRound:
            // 첫회차가 몇일까? 1이면 1이상일때라는 조건 추가하기
            guard let currentPensionLotteryRound = currentState.currentPensionLotteryRound else { return .empty() }
            let previousPensionRound = currentPensionLotteryRound - 1
            return Observable.concat([
                .just(Mutation.setCurrentPensionRound(previousPensionRound)),
                
                lottoMateAPIService.getPensionLotteryResult(round: previousPensionRound)
                    .map { Mutation.setPensionRoundResult($0) }
                    .catch { .just(.setError($0)) }
            ])
        
        case .fetchNextPensionRound:
            guard let currentPensionRound = currentState.currentPensionLotteryRound,
                  let maxPensionRound = currentState.latestPensionRound
            else { return .empty() }
            guard currentPensionRound < maxPensionRound else { return .empty() }
            
            let nextPensionRound = currentPensionRound + 1
            
            return Observable.concat([
                .just(Mutation.setCurrentPensionRound(nextPensionRound)),
                
                lottoMateAPIService.getPensionLotteryResult(round: nextPensionRound)
                    .map { Mutation.setPensionRoundResult($0) }
                    .catch { .just(.setError($0)) }
            ])
        
//        case .fetchPreviousSpeetoRound:
//            guard let currentSpeetoRound = currentState.currentSpeetoRound else { return .empty() }
//            let previousSpeetoRound = currentSpeetoRound - 1
//            return Observable.concat([
//                .just(Mutation.setCurrentSpeetoRound(previousSpeetoRound)),
//
//                lottoMateAPIService.getSpeetoResult(round: previousSpeetoRound)
//                    .map { Mutation.setSpeetoRoundResult($0) }
//                    .catch { .just(.setError($0)) }
//            ])
            
//        case .fetchNextSpeetoRound:
//            guard let currentSpeetoRound = currentState.currentSpeetoRound,
//                  let maxSpeetoRound = currentState.latestSpeetoRound
//            else { return .empty() }
//            guard currentSpeetoRound < maxSpeetoRound else { return .empty() }
//
//            let nextSpeetoRound = currentSpeetoRound + 1
//
//            return Observable.concat([
//                .just(Mutation.setCurrentSpeetoRound(nextSpeetoRound)),
//
//                lottoMateAPIService.getSpeetoResult(round: nextSpeetoRound)
//                    .map { Mutation.setSpeetoRoundResult($0) }
//                    .catch { .just(.setError($0)) }
//            ])
        
        case .showMapViewController:
            return .just(Mutation.showMap)
        
        case .checkWinningViewTapped:
            return .just(Mutation.showQrScanner)
        
        case .fetchLottoResult(let round):
            return Observable.concat([
                .just(Mutation.setLoading(true)),
                
                lottoMateAPIService.getLottoResult(round: round)
                    .map { Mutation.setLottoRoundResult($0) }
                    .catch { .just(.setError($0)) },
                    
                .just(Mutation.setLoading(false))
            ])

        case .fetchPensionLotteryResult(let round):
            return Observable.concat([
                .just(Mutation.setLoading(true)),
                
                lottoMateAPIService.getPensionLotteryResult(round: round)
                    .map { Mutation.setPensionRoundResult($0) }
                    .catch { .just(.setError($0)) },
                    
                .just(Mutation.setLoading(false))
            ])

//        case .fetchSpeetoResult(let round):
//            return Observable.concat([
//                .just(Mutation.setLoading(true)),
//
//                lottoMateAPIService.getSpeetoResult(round: round)
//                    .map { Mutation.setSpeetoRoundResult($0) }
//                    .catch { .just(.setError($0)) },
//
//                .just(Mutation.setLoading(false))
//            ])

        case .checkWinning(let drwNo, let numbers):
            return Observable.concat([
                .just(Mutation.setLoading(true)),
                
                checkWinningNumbers(drwNo: drwNo, numbers: numbers)
                    .map { Mutation.setWinningResult($0) }
                    .catch { .just(.setError($0)) },
                    
                .just(Mutation.setLoading(false))
            ])
            
        case .resetWinningResult:
            return .just(Mutation.resetWinningResult)
            
        case .saveLottoNumbers(let numbers, let lottoDrwNo):
            // 비어있지 않은 번호들만 필터링
            let validNumbers = numbers.filter { !$0.isEmpty }
            guard !validNumbers.isEmpty else { return .empty() }
            
            return Observable.concat([
                Observable.just(.setSaveLoading(true)),
                
                // 여러 번호를 순차적으로 저장
                Observable.merge(
                    validNumbers.map { numbers in
                        storageService.createMyLottoNumbers(
                            lottoNum: numbers,
                            lottoType: "L645",
                            lottoDrwNo: lottoDrwNo
                        )
                    }
                )
                .toArray()
                .asObservable()
                .map { _ in Mutation.setSaveSuccess(true) }
                .catch { error in
                    Observable.just(.setSaveError(error))
                },
                
                Observable.just(.setSaveLoading(false))
            ])
            
        case .savePensionNumbers(let numbers, let lottoDrwNo):
            // 비어있지 않은 번호들만 필터링하고 Int 배열로 변환
            let validNumbers = numbers.compactMap { numberStrings -> [Int]? in
                let intNumbers = numberStrings.compactMap { Int($0) }
                return intNumbers.isEmpty ? nil : intNumbers
            }
            guard !validNumbers.isEmpty else { return .empty() }
            
            return Observable.concat([
                Observable.just(.setSaveLoading(true)),
                
                // 여러 번호를 순차적으로 저장 (연금복권은 L720으로 저장)
                Observable.merge(
                    validNumbers.map { numbers in
                        storageService.createMyLottoNumbers(
                            lottoNum: numbers,
                            lottoType: "L720",
                            lottoDrwNo: lottoDrwNo
                        )
                    }
                )
                .toArray()
                .asObservable()
                .map { _ in Mutation.setSaveSuccess(true) }
                .catch { error in
                    Observable.just(.setSaveError(error))
                },
                
                Observable.just(.setSaveLoading(false))
            ])
            
        case .resetSaveState:
            return .just(.resetSaveState)
        
        case .noticeButtonTapped:
            return .just(.showNoticeView)
        }
    }
    
    private func checkWinningNumbers(drwNo: Int, numbers: [[Int]]) -> Observable<[LottoNumberWithRank]> {
        guard let latestLottoRound = currentState.latestLottoRound else {
            return .just([])
        }

        if drwNo > latestLottoRound {
            return .just(numbers.map { userNumbers in
                let result = LottoNumberWithRank(numbers: userNumbers, rank: nil, notAnnouncedYet: true, drwNo: drwNo, prizeMoney: nil)
                
                // 추첨일이 오늘이고 추첨 시간이 지나지 않았거나, 추첨일이 미래인 경우에만 notAnnouncedYet을 true로 설정
                if (result.isDrawToday && !result.isAfterDrawTime) || (result.daysUntilDraw ?? 0) > 0 {
                    return result
                } else {
                    // 이미 추첨 시간이 지난 경우 서버에서 결과를 가져와야 함
                    return LottoNumberWithRank(numbers: userNumbers, rank: nil, notAnnouncedYet: false, drwNo: drwNo, prizeMoney: nil)
                }
            })
        }
        
        return lottoMateAPIService.getLottoResult(round: drwNo)
            .map { result -> [LottoNumberWithRank] in
                let winningNumbers = result.lottoResult.lottoNum
                let bonusNumber = result.lottoResult.lottoBonusNum
                let drawDateString = result.lottoResult.drwDate
                
                // 날짜 문자열을 Date 객체로 변환
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let drawDate = dateFormatter.date(from: drawDateString) ?? {
                    // 날짜 변환 실패 시 회차를 기준으로 계산된 날짜 사용
                    let baseDate = Calendar.current.date(from: DateComponents(year: 2002, month: 12, day: 7))!
                    let weeksToAdd = drwNo - 1
                    return Calendar.current.date(byAdding: .day, value: weeksToAdd * 7, to: baseDate)!
                }()
                
                let firstPrizeMoney = result.lottoResult.p1PerJackpot
                let secondPrizeMoney = result.lottoResult.p2PerJackpot
                let thirdPrizeMoney = result.lottoResult.p3PerJackpot
                let fourthPrizeMoney = result.lottoResult.p4PerJackpot
                let fifthPrizeMoney = result.lottoResult.p5PerJackpot
                
                return numbers.map { userNumbers in
                    let matchedCount = userNumbers.filter { winningNumbers.contains($0) }.count
                    let containsBonus = userNumbers.contains(bonusNumber)
                    
                    let rank: Int?
                    
                    switch (matchedCount, containsBonus) {
                    case (6, _): rank = 1    // 1등 - 6개 모두 일치
                    case (5, true): rank = 2 // 2등 - 5개 일치 + 보너스 번호 일치
                    case (5, false): rank = 3 // 3등 - 5개 일치
                    case (4, _): rank = 4    // 4등 - 4개 일치
                    case (3, _): rank = 5    // 5등 - 3개 일치
                    default: rank = nil      // 미당첨
                    }
                    
                    // 당첨 등수에 따른 상금 결정
                    let prizeMoney: Int?
                    if let rank = rank {
                        switch rank {
                        case 1: prizeMoney = firstPrizeMoney
                        case 2: prizeMoney = secondPrizeMoney
                        case 3: prizeMoney = thirdPrizeMoney
                        case 4: prizeMoney = fourthPrizeMoney
                        case 5: prizeMoney = fifthPrizeMoney
                        default: prizeMoney = nil
                        }
                    } else {
                        prizeMoney = nil
                    }
                    
                    return LottoNumberWithRank(
                        numbers: userNumbers,
                        rank: rank,
                        notAnnouncedYet: false,
                        drwNo: drwNo,
                        prizeMoney: prizeMoney,
                        drawDate: drawDate
                    )
                }
            }
    }
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setSelectedLotteryType(type):
            newState.selectedLotteryType = type
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setLotteryResult(let result):
            newState.latestLotteryResult = result
            newState.latestLottoRound = result.the645.drwNum
            newState.currentLottoRound = result.the645.drwNum
            newState.latestPensionRound = result.the720.drwNum
            newState.currentPensionLotteryRound = result.the720.drwNum
//            newState.latestSpeetoRound = result.speeto.drwNum
//            newState.currentSpeetoRound = result.speeto.drwNum
            
        case .setError(let error):
            newState.error = error
        
        case .setLotteryTypeDetail(let showLotteryTypeDetailView):
            newState.showLotteryTypeDetail = showLotteryTypeDetailView
        
        case .setLottoRoundResult(let result):
            newState.lottoRoundResult = result
        
        case .setCurrentLottoRound(let round):
            newState.isLottoRightArrowIconHidden = state.latestLottoRound == round
            newState.currentLottoRound = round
        
        case .setPensionRoundResult(let result):
            newState.pensionRoundResult = result
        
        case .setCurrentPensionRound(let round):
            newState.isPensionRightArrowIconHidden = state.latestPensionRound == round
            newState.currentPensionLotteryRound = round
            
//        case .setSpeetoRoundResult(let result):
//            newState.speetoRoundResult = result
            
        case .setCurrentSpeetoRound(let round):
            newState.isSpeetoRightArrowIconHidden = state.latestSpeetoRound == round
            newState.currentSpeetoRound = round
            
        case .showMap:
            newState.isMapVisible.toggle()
            
        case .showQrScanner:
            newState.isQrScannerVisible.toggle()
            
        case .setWinningResult(let result):
            newState.winningResult = result
            
        case .resetWinningResult:
            newState.winningResult = nil
            
        case .setSaveLoading(let isLoading):
            newState.saveLoading = isLoading
            
        case .setSaveSuccess(let isSuccess):
            newState.saveSuccess = isSuccess
            if isSuccess {
                newState.saveError = nil
            }
            
        case .setSaveError(let error):
            newState.saveError = error
            newState.saveSuccess = false
            
        case .resetSaveState:
            newState.saveLoading = false
            newState.saveSuccess = false
            newState.saveError = nil
            
        case .showNoticeView:
            // TODO: hideNoticeView? 어떤 방식이 좋을까?
            newState.isNoticeViewVisible.toggle()
        }
        return newState
    }
}

// MARK: - Result Type Models
struct LottoNumberWithRank: Equatable {
    let numbers: [Int]
    let rank: Int?
    let notAnnouncedYet: Bool
    let drwNo: Int
    let drawDate: Date
    let prizeMoney: Int?  // 당첨금액
    
    init(numbers: [Int], rank: Int?, notAnnouncedYet: Bool = false, drwNo: Int, prizeMoney: Int? = nil, drawDate: Date? = nil) {
        self.numbers = numbers
        self.rank = rank
        self.notAnnouncedYet = notAnnouncedYet
        self.drwNo = drwNo
        self.prizeMoney = prizeMoney
        
        if let drawDate = drawDate {
            self.drawDate = drawDate
        } else {
            // 제공된 날짜가 없을 경우 회차 기준으로 계산 (미래 회차 등 대비)
            // 1회차 기준일: 2002년 12월 7일 (토요일)
            let baseDate = Calendar.current.date(from: DateComponents(year: 2002, month: 12, day: 7))!
            let weeksToAdd = drwNo - 1 // 1회차는 기준일이므로 1을 빼줌
            self.drawDate = Calendar.current.date(byAdding: .day, value: weeksToAdd * 7, to: baseDate)!
        }
    }
    
    // 현재 날짜와 추첨일 비교
    var daysUntilDraw: Int? {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date()) // 오늘 자정을 기준으로
        let drawDay = calendar.startOfDay(for: drawDate) // 추첨일 자정을 기준으로
        
        // 날짜 차이를 일 단위로 계산
        let components = calendar.dateComponents([.day], from: now, to: drawDay)
        return components.day
    }
    
    // 추첨일이 오늘인지 확인
    var isDrawToday: Bool {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let drawDay = calendar.startOfDay(for: drawDate)
        return calendar.isDate(now, inSameDayAs: drawDay)
    }
    
    // 추첨 시간이 지났는지 확인 (추첨시간 20:45 기준)
    var isAfterDrawTime: Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // 현재 날짜의 20:45를 기준으로 비교
        var drawTimeComponents = calendar.dateComponents([.year, .month, .day], from: drawDate)
        drawTimeComponents.hour = 20
        drawTimeComponents.minute = 45
        drawTimeComponents.second = 0
        
        guard let drawTime = calendar.date(from: drawTimeComponents) else { return false }
        return now > drawTime
    }
}

protocol LottoResultType {
    var drwNum: Int { get }
    var drwDate: String { get }
    var p1Jackpot: Int { get }
    var p1WinnrCnt: Int { get }
    var lottoNum: [Int] { get }
    var lottoBonusNum: [Int] { get }
}

protocol PensionResultType {
    var pensionDrwNum: Int { get }
    var pensionDrwDate: String { get }
    var pensionNum: [Int] { get }
}

protocol SpeetoResultType {
    var speetoDrwNum: Int { get }
    var speetoDrwDate: String { get }
    var speetoNum: [Int] { get }
}
