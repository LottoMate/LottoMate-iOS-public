//
//  WinningReviewDetailReactor.swift
//  LottoMate
//
//  Created by Mirae on 12/26/24.
//

import ReactorKit
import RxSwift

final class WinningReviewReactor: Reactor {
    static let shared = WinningReviewReactor()
    
    private init() {}
    
    private let reviewAPIService = WinningReviewAPIService()
    private var maxNumber = 0
    private var currentWinningReviewNos: [Int] = []
    
    enum Action {
        case fetchInitialData
        case fetchWinningReviewList([Int])
        case updateWinningReviewList(tappedNo: Int)
        case fetchWinningReviewDetail(Int)
    }
    
    enum Mutation {
        case setError(LoadingSection, Error)
        case setLoading(LoadingSection, Bool)
        case setMaxNumber(Int)
        case setWinningReviewList([WinningReviewListResponse])
        case updateWinningReviewNos([Int])
        case setWinningReviewDetail(WinningReviewDetailResponse)
    }
    
    struct State {
        var currentReviewNos: [Int] = []
        var errors: [LoadingSection: Error] = [:]
        var loadingStates: Set<LoadingSection> = [.reviewList, .maxNumber, .reviewDetail]
        var winningReviewList: [WinningReviewListResponse] = []
        var winningReviewDetail: WinningReviewDetailResponse?
        
        func error(for section: LoadingSection) -> Error? {
            errors[section]
        }
        
        mutating func setError(_ error: Error?, for section: LoadingSection) {
            if let error = error {
                errors[section] = error
            } else {
                errors.removeValue(forKey: section)
            }
        }
        
        func isLoading(_ section: LoadingSection) -> Bool {
            return loadingStates.contains(section)
        }
    }
    
    let initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchInitialData:
            return Observable.concat([
                .just(.setLoading(.maxNumber, true)),
                
                loadWinningReviewNos()
                    .flatMap { [weak self] savedNos -> Observable<Mutation> in
                        if !savedNos.isEmpty { // 빈 배열도 isEmpty 조건에 맞는지 확실히 확인
                            return self?.fetchReviewsWithSavedNos(savedNos) ?? .empty()
                        } else {
                            return self?.fetchReviewsWithMaxNumber() ?? .empty()
                        }
                    },
                
                .just(.setLoading(.maxNumber, false))
            ])
            
        case .fetchWinningReviewList(let reviewNos):
            return Observable.concat([
                .just(.setLoading(.reviewList, true)),
                
                reviewAPIService.fetchWinningReviewList(reviewNos: reviewNos)
                    .map { Mutation.setWinningReviewList($0) }
                    .catch { .just(.setError(.reviewList, $0)) }
            ])
            
        case .updateWinningReviewList(let tappedReviewNo):
            let newReviewNos = generateNextWinningReviewNos(
                currentNos: currentState.currentReviewNos,
                tappedNo: tappedReviewNo,
                maxNo: maxNumber
            )
            
            return Observable.concat([
                .just(.updateWinningReviewNos(newReviewNos)),
                .just(.setLoading(.reviewList, true)),
                
                reviewAPIService.fetchWinningReviewList(reviewNos: newReviewNos)
                    .map { Mutation.setWinningReviewList($0) }
                    .catch { .just(.setError(.reviewList, $0)) }
            ])
        
        case .fetchWinningReviewDetail(let reviewNo):
            return Observable.concat([
                .just(.setLoading(.reviewDetail, true)),
                reviewAPIService.fetchWinningReviewDetail(reviewNo: reviewNo)
                    .map { Mutation.setWinningReviewDetail($0) }
                    .catch { .just(.setError(.reviewDetail, $0)) }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setError(let section, let error):
            newState.setError(error, for: section)
            newState.loadingStates.remove(section)
            
        case .setLoading(let section, let isLoading):
            if isLoading {
                newState.setError(nil, for: section)
                newState.loadingStates.insert(section)
            } else {
                newState.loadingStates.remove(section)
            }
            
        case .setMaxNumber(let maxNumber):
            self.maxNumber = maxNumber
            
        case .setWinningReviewList(let reviewList):
            newState.winningReviewList = reviewList
            newState.loadingStates.remove(.reviewList)
            // winningReviewList와 currentReviewNos를 동기화
            let reviewNos = reviewList.map { $0.reviewNo }.sorted(by: >)
            newState.currentReviewNos = reviewNos
            self.currentWinningReviewNos = reviewNos
            
        case .updateWinningReviewNos(let newNos):
            self.currentWinningReviewNos = newNos
            newState.currentReviewNos = newNos
        
        case .setWinningReviewDetail(let reviewDetail):
            newState.winningReviewDetail = reviewDetail
            newState.loadingStates.remove(.reviewDetail)
        }
        return newState
    }
}

extension WinningReviewReactor {
    enum LoadingSection: Hashable {
        case maxNumber
        case reviewList
        case reviewDetail
    }
}

extension WinningReviewReactor {
    private func loadWinningReviewNos() -> Observable<[Int]> {
        if let savedNos = UserDefaults.standard.array(forKey: "LastReviewNos") as? [Int] {
            return .just(savedNos)
        } else {
            return .just([])  // 저장된 값이 없을 경우 빈 배열 반환
        }
    }
    
    private func fetchReviewsWithSavedNos(_ savedNos: [Int]) -> Observable<Mutation> {
        // maxNumber가 0이면 먼저 가져오기
        if maxNumber == 0 {
            return reviewAPIService.fetchWinningReviewMaxNumber()
                .flatMap { [weak self] maxNumber -> Observable<Mutation> in
                    self?.maxNumber = maxNumber
                    
                    return .concat([
                        .just(.setMaxNumber(maxNumber)),
                        .just(.updateWinningReviewNos(savedNos)),
                        .just(.setLoading(.reviewList, true)),
                        self?.reviewAPIService.fetchWinningReviewList(reviewNos: savedNos)
                            .map { Mutation.setWinningReviewList($0) }
                            .catch { .just(.setError(.reviewList, $0)) } ?? .empty()
                    ])
                }
                .catch { .just(.setError(.maxNumber, $0)) }
        }
        
        return .concat([
            .just(.updateWinningReviewNos(savedNos)),
            .just(.setLoading(.reviewList, true)),
            reviewAPIService.fetchWinningReviewList(reviewNos: savedNos)
                .map { Mutation.setWinningReviewList($0) }
                .catch { .just(.setError(.reviewList, $0)) }
        ])
    }
    
    private func fetchReviewsWithMaxNumber() -> Observable<Mutation> {
        return reviewAPIService.fetchWinningReviewMaxNumber()
            .flatMap { [weak self] maxNumber -> Observable<Mutation> in
                
                self?.maxNumber = maxNumber
                
                guard let initialReviewNos = self?.generateInitialWinningReviewNos(from: maxNumber),
                      !initialReviewNos.isEmpty else {
                    return .just(.setError(.maxNumber, NSError(domain: "ReviewError",
                                                               code: -1,
                                                               userInfo: [NSLocalizedDescriptionKey: "Failed to generate review numbers"])))
                }
                
                return .concat([
                    .just(.setMaxNumber(maxNumber)),
                    .just(.updateWinningReviewNos(initialReviewNos)),
                    .just(.setLoading(.reviewList, true)),
                    self?.reviewAPIService.fetchWinningReviewList(reviewNos: initialReviewNos)
                        .map { Mutation.setWinningReviewList($0) }
                        .catch { .just(.setError(.reviewList, $0)) } ?? .empty()
                ])
            }
            .catch { .just(.setError(.maxNumber, $0)) }
    }
    
    private func generateInitialWinningReviewNos(from maxNumber: Int) -> [Int] {
        return (0..<5).map { maxNumber - $0 }
    }
    
    private func generateNextWinningReviewNos(currentNos: [Int], tappedNo: Int, maxNo: Int) -> [Int] {
        print("currentReviewNos: \(currentNos) \(tappedNo) \(maxNo)")
        
        // maxNo가 0이면 에러 - 이 경우는 발생하면 안됨
        guard maxNo > 0 else {
            print("⚠️ Error: maxNo is 0, returning currentNos")
            return currentNos
        }
        
        // Get previously tapped numbers from UserDefaults
        let defaults = UserDefaults.standard
        let tappedReviewNos = defaults.array(forKey: "tappedReviewNos") as? [Int] ?? []
        
        // 1. 탭한 번호를 현재 리스트에서 제거
        var newNos = currentNos.filter { $0 != tappedNo }
        
        // newNos가 비어있으면 초기 리스트 생성
        if newNos.isEmpty {
            defaults.set([Int](), forKey: "tappedReviewNos")
            return generateInitialWinningReviewNos(from: maxNo)
        }
        
        // 2. 5개가 될 때까지 새로운 번호 추가
        while newNos.count < 5 {
            // 현재 리스트에서 가장 작은 번호 찾기
            guard let minNo = newNos.min(), minNo >= 1 else {
                // 리스트가 비었거나 최소값이 1 미만이면 초기 리스트 생성
                defaults.set([Int](), forKey: "tappedReviewNos")
                return generateInitialWinningReviewNos(from: maxNo)
            }
            
            // 가장 작은 번호보다 작은 번호 중에서, 아직 읽지 않은 번호 찾기
            var potentialNewNumber = minNo - 1
            var found = false
            
            while potentialNewNumber >= 1 {
                // 아직 읽지 않았고, 현재 리스트에도 없는 번호라면 추가
                if !tappedReviewNos.contains(potentialNewNumber) && !newNos.contains(potentialNewNumber) {
                    newNos.append(potentialNewNumber)
                    found = true
                    break
                }
                potentialNewNumber -= 1
            }
            
            // 더 이상 추가할 번호가 없으면 중단 (1 미만으로 내려갔거나 모두 읽은 경우)
            if !found {
                break
            }
        }
        
        // 유효한 번호만 필터링 (1 이상)
        newNos = newNos.filter { $0 >= 1 }
        
        // 필터링 후 비어있으면 초기 리스트 생성
        if newNos.isEmpty {
            defaults.set([Int](), forKey: "tappedReviewNos")
            return generateInitialWinningReviewNos(from: maxNo)
        }
        
        return newNos.sorted(by: >)
    }
}
