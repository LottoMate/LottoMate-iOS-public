//
//  StorageViewReactor.swift
//  LottoMate
//
//  Created by Mirae on 10/25/24.
//

import ReactorKit
import RxSwift

final class StorageViewReactor: Reactor {
    private let apiService = LottoMateAPIService()
    private let storageService = StorageService.shared
    
    enum Action {
        case didSelectMyNumber
        case didSelectrandomNumber
        case generateRandomNumbers
        case checkReset
        case hideLoading
        case savePermanently([Int])
        case saveMyNumbers([Int], String, String) // numbers, lottoType, lottoDrwNo
        case deleteSavedNumbers(id: UUID)
        case showSavedNumbersView
        case hideSavedNumbersView
        case copyToClipboard([Int])
        case qrScanButtonTapped
        case addNumberButtonTapped
        case checkWinning(drwNo: Int, numbers: [[Int]])
        case resetQrScannerState
        case resetWinningResult
        case resetNavigation
        case resetSaveState
    }
    
    enum Mutation {
        case showSelectedView(StorageViewMode)
        case appendTemporaryNumbers([Int])
        case updatePermanentNumbers([SavedLottoNumber])
        case setSaveLoading(Bool)
        case setSaveSuccess(Bool)
        case setSaveError(Error)
        case incrementCount
        case resetData
        case setRandomNumberIsLoading(Bool)
        case showSavedNumbersView(Bool)
        case numbersCopied
        case showQrScanner(Bool)
        case navigateToAddNumber(Bool)
        case setError(Error)
        case setLottoWinningResultIsLoading(Bool)
        case setLottoWinningResult([LottoNumberWithRank])
        case resetWinningResult
        case resetSaveState
    }
    
    struct State {
        var selectedMode: StorageViewMode = .myNumber
        var temporaryRandomNumbers: [[Int]]
        var permanentRandomNumbers: [SavedLottoNumber]
        var generationCount: Int
        var RandomNumberisLoading: Bool = false
        var showSavedNumbersView: Bool = false
        var numbersCopied: Bool = false
        var showQrScanner: Bool = false
        var navigateToAddNumber: Bool = false
        var error: Error?
        var saveLoading: Bool = false
        var saveSuccess: Bool = false
        var saveError: Error?
        var lottoWinningResultIsLoading: Bool = false
        var winningResult: [LottoNumberWithRank]? = nil
    }
    
    let initialState: State
    private let disposeBag = DisposeBag()
    private let temporaryStorage = TemporaryLottoStorage()
    private let permanentStorage = PermanentLottoStorage()
    
    init() {
        let temporaryRandomNumbersData = TemporaryLottoStorage.load()
        self.initialState = State(
            temporaryRandomNumbers: temporaryRandomNumbersData.numbers,
            permanentRandomNumbers: PermanentLottoStorage().load(),
            generationCount: temporaryRandomNumbersData.count
        )
        setupDailyReset()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didSelectMyNumber:
            return .just(.showSelectedView(.myNumber))
        case .didSelectrandomNumber:
            return .just(.showSelectedView(.randomNumber))
        case .generateRandomNumbers:
            let newRandomNumbers = generateLottoNumbers()
            var updatedRandomNumbers = currentState.temporaryRandomNumbers
            updatedRandomNumbers.append(newRandomNumbers)
            let newCount = currentState.generationCount + 1
            TemporaryLottoStorage.save(updatedRandomNumbers, count: newCount)
            return .concat([
                Observable.just(Mutation.setRandomNumberIsLoading(true)),
                .just(.appendTemporaryNumbers(newRandomNumbers)),
                .just(.incrementCount)
            ])
        case .checkReset:
            if TemporaryLottoStorage.shouldResetData() {
                TemporaryLottoStorage.resetData()
                return .just(.resetData)
            }
            return .empty()
        case .hideLoading:
            return Observable.just(Mutation.setRandomNumberIsLoading(false))
        case .savePermanently(let numbers):
            permanentStorage.save(numbers)
            return .just(.updatePermanentNumbers(permanentStorage.load()))
        case .saveMyNumbers(let numbers, let lottoType, let lottoDrwNo):
            return Observable.concat([
                Observable.just(.setSaveLoading(true)),
                
                storageService.createMyLottoNumbers(
                    lottoNum: numbers,
                    lottoType: lottoType,
                    lottoDrwNo: lottoDrwNo
                )
                .map { _ in Mutation.setSaveSuccess(true) }
                .catch { error in
                    Observable.just(.setSaveError(error))
                },
                
                Observable.just(.setSaveLoading(false))
            ])
        case .deleteSavedNumbers(id: let id):
            permanentStorage.deleteNumbers(with: id)
            return .just(.updatePermanentNumbers(permanentStorage.load()))
        case .showSavedNumbersView:
            return .just(Mutation.showSavedNumbersView(true))
        case .hideSavedNumbersView:
            return .just(Mutation.showSavedNumbersView(false))
        case .copyToClipboard(let numbers):
            let formedNumbers = numbers.map(String.init).joined(separator: " - ")
            UIPasteboard.general.string = formedNumbers
            return .just(.numbersCopied)
        case .qrScanButtonTapped:
            return .just(Mutation.showQrScanner(true))
        case .resetQrScannerState:
            return .just(Mutation.showQrScanner(false))
        case .addNumberButtonTapped:
            return .just(Mutation.navigateToAddNumber(true))
        case .checkWinning(drwNo: let drwNo, numbers: let numbers):
            // Check if we're looking for a future round
            let latestLottoRound = apiService.getLatestLottoRound() // This should be implemented in your service
            
            if drwNo > latestLottoRound {
                // If this is a future round (not announced yet)
                let results = numbers.map { userNumbers in
                    LottoNumberWithRank(numbers: userNumbers, rank: nil, notAnnouncedYet: true, drwNo: drwNo)
                }
                return .just(.setLottoWinningResult(results))
            }
            
            return Observable.concat([
                Observable.just(.setLottoWinningResultIsLoading(true)),
                
                apiService.getLottoResult(round: drwNo)
                    .map { result -> [LottoNumberWithRank] in
                        return numbers.map { userNumbers in
                            self.checkWinningNumbers(
                                userNumbers: userNumbers,
                                winningNumbers: result.lottoResult.lottoNum,
                                bonusNumber: result.lottoResult.lottoBonusNum.first ?? 0,
                                drwNo: drwNo
                            )
                        }
                    }
                    .map { Mutation.setLottoWinningResult($0) }
                    .catch { Observable.just(.setError($0)) },
                
                Observable.just(.setLottoWinningResultIsLoading(false))
            ])
            
        case .resetWinningResult:
            return .just(.resetWinningResult)
        case .resetNavigation:
            return .just(Mutation.navigateToAddNumber(false))
        case .resetSaveState:
            return .just(Mutation.resetSaveState)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .showSelectedView(let storageViewMode):
            newState.selectedMode = storageViewMode
        case .appendTemporaryNumbers(let numbers):
            newState.temporaryRandomNumbers.append(numbers)
        case .incrementCount:
            newState.generationCount += 1
        case .resetData:
            newState.temporaryRandomNumbers = []
            newState.generationCount = 0
        case .setRandomNumberIsLoading(let isLoading):
            newState.RandomNumberisLoading = isLoading
        case .updatePermanentNumbers(let savedNumbers):
            newState.permanentRandomNumbers = savedNumbers
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
        case .showSavedNumbersView(let showSavedNumbersView):
            newState.showSavedNumbersView = showSavedNumbersView
        case .numbersCopied:
            newState.numbersCopied.toggle()
        case .showQrScanner(let showQrScanner):
            newState.showQrScanner = showQrScanner
        case .navigateToAddNumber(let navigate):
            newState.navigateToAddNumber = navigate
        case .setError(let error):
            newState.error = error
        case .setLottoWinningResultIsLoading(let isLoading):
            newState.lottoWinningResultIsLoading = isLoading
        case .setLottoWinningResult(let winningResult):
            newState.winningResult = winningResult
        case .resetWinningResult:
            newState.winningResult = nil
        case .resetSaveState:
            newState.saveLoading = false
            newState.saveSuccess = false
            newState.saveError = nil
        }
        
        return newState
    }
}

extension StorageViewReactor {
    // Helper to check winning numbers against drawn numbers
    private func checkWinningNumbers(userNumbers: [Int], winningNumbers: [Int], bonusNumber: Int, drwNo: Int) -> LottoNumberWithRank {
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
        
        return LottoNumberWithRank(numbers: userNumbers, rank: rank, notAnnouncedYet: false, drwNo: drwNo)
    }
    
    private func generateLottoNumbers() -> [Int] {
        var numbers = Set<Int>()
        
        while numbers.count < 6 {
            let randomNumber = Int.random(in: 1...45)
            numbers.insert(randomNumber)
        }
        
        return Array(numbers).sorted()
    }
    
    private func setupDailyReset() {
        // 다음 자정 시간 계산
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        guard let nextMidnight = calendar.nextDate(
            after: Date(),
            matching: components,
            matchingPolicy: .strict
        ) else { return }
        
        let timeUntilMidnight = nextMidnight.timeIntervalSince(Date())
        
        // 자정에 맞춰 첫 번째 타이머 실행
        Observable<Int>.timer(.seconds(Int(timeUntilMidnight)), scheduler: MainScheduler.instance)
            .map { _ in Action.checkReset }
            .bind(to: action)
            .disposed(by: disposeBag)
        
        // 이후 24시간마다 반복
        Observable<Int>.timer(
            .seconds(Int(timeUntilMidnight)),
            period: .seconds(24 * 60 * 60),
            scheduler: MainScheduler.instance
        )
        .map { _ in Action.checkReset }
        .bind(to: action)
        .disposed(by: disposeBag)
    }
}

// Helper extension for the LottoMateAPIService
extension LottoMateAPIService {
    func getLatestLottoRound() -> Int {
        // Use the LottoMateViewModel's current round data if available
        if let latestRound = LottoMateViewModel.shared.currentLottoRound.value {
            return latestRound
        }
        
        // Fallback to a reasonable default if we don't have latest round info
        // We could also fetch it here, but that would make this a blocking operation
        let currentDate = Date()
        // Calculate the approximate round based on the fact that:
        // - Lotto started on December 7, 2002 (round 1)
        // - Each round is weekly
        let startDate = Calendar.current.date(from: DateComponents(year: 2002, month: 12, day: 7))!
        let weeksSinceStart = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: currentDate).weekOfYear ?? 0
        
        // Add 1 since the first round was 1, not 0
        return weeksSinceStart + 1
    }
}

// Updating LottoWinningResult to use LottoNumberWithRank for consistency
typealias LottoWinningResult = LottoNumberWithRank

enum StorageViewMode {
    case myNumber
    case randomNumber
}

struct SavedLottoNumber: Codable, Equatable {
    let id: UUID
    let date: Date
    let numbers: [Int]
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    init(date: Date, numbers: [Int]) {
        self.id = UUID()
        self.date = date
        self.numbers = numbers
    }
}

struct TemporaryLottoStorage {
    private static let storageKey = "tempLottoNumbers"
    private static let countKey = "randomNumbersGenerationCount"
    private static let lastSavedDateKey = "tempLastSavedDate"
    
    static func save(_ numbers: [[Int]], count: Int) {
        if let encoded = try? JSONEncoder().encode(numbers) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
            UserDefaults.standard.set(count, forKey: countKey)
            UserDefaults.standard.set(Date(), forKey: lastSavedDateKey)
        }
    }
    
    static func load() -> (numbers: [[Int]], count: Int) {
        if shouldResetData() {
            resetData()
            return ([], 0)
        }
        
        let numbers: [[Int]] = {
            guard let data = UserDefaults.standard.data(forKey: storageKey),
                  let numbers = try? JSONDecoder().decode([[Int]].self, from: data) else {
                return []
            }
            return numbers
        }()
        
        let count = UserDefaults.standard.integer(forKey: countKey)
        return (numbers, count)
    }
    
    static func shouldResetData() -> Bool {
        guard let lastSavedDate = UserDefaults.standard.object(forKey: lastSavedDateKey) as? Date else {
            return false
        }
        
        let calendar = Calendar.current
        let lastSavedDay = calendar.startOfDay(for: lastSavedDate)
        let currentDay = calendar.startOfDay(for: Date())
        
        return lastSavedDay != currentDay
    }
    
    static func resetData() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: countKey)
        UserDefaults.standard.set(Date(), forKey: lastSavedDateKey)
    }
}

struct PermanentLottoStorage {
    private let storageKey = "permanentLottoNumbers"
    
    func save(_ newNumbers: [Int]) {
        var savedNumbers = load()
        let newSavedNumber = SavedLottoNumber(date: Date(), numbers: newNumbers)
        savedNumbers.append(newSavedNumber)
        
        if let encoded = try? JSONEncoder().encode(savedNumbers) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func load() -> [SavedLottoNumber] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let numbers = try? JSONDecoder().decode([SavedLottoNumber].self, from: data) else {
            return []
        }
        return numbers
    }
    
    func deleteNumbers(with id: UUID) {
        var savedNumbers = load()
        savedNumbers.removeAll { $0.id == id }
        if let encoded = try? JSONEncoder().encode(savedNumbers) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}
