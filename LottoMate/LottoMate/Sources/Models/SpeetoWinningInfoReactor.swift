//
//  SpeetoWinningInfoReactor.swift
//  LottoMate
//
//  Created by Mirae on 3/11/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

enum SpeetoType: String {
    case s500 = "S500"  // API 값을 rawValue로 사용
    case s1000 = "S1000"
    case s2000 = "S2000"
    
    var displayName: String {
        switch self {
        case .s500: return "스피또 500"
        case .s1000: return "스피또 1000"
        case .s2000: return "스피또 2000"
        }
    }
    
    var buttonText: String {
        switch self {
        case .s500: return "500"
        case .s1000: return "1000"
        case .s2000: return "2000"
        }
    }
    
    // the500 등 기존 값으로도 접근 가능하도록 정적 프로퍼티 제공 (필요한 경우)
    static let the500 = SpeetoType.s500
    static let the1000 = SpeetoType.s1000
    static let the2000 = SpeetoType.s2000
}

final class SpeetoWinningInfoReactor: Reactor {
    
    enum Action {
        case loadSpeetoWinningInfo(type: SpeetoType, page: Int)
        case loadMoreWinningInfo
        case refresh
        case selectSpeetoType(SpeetoType)
    }
    
    enum Mutation {
        case setWinningStores([SpeetoWinningStore], append: Bool)
        case setPageInfo(current: Int, total: Int, totalElements: Int)
        case setLotteryType(SpeetoType)
        case setLoading(Bool)
        case setLoadingMore(Bool)
        case setError(Error?)
    }
    
    struct State {
        var winningStores: [SpeetoWinningStore] = []
        var currentPage: Int = 0
        var totalPages: Int = 0
        var totalElements: Int = 0
        var isLoading: Bool = false
        var isLoadingMore: Bool = false
        var speetoType: SpeetoType = .s2000
        var error: Error? = nil
        var canLoadMore: Bool { return currentPage < totalPages - 1 }
    }
    
    // MARK: - Properties
    
    let initialState: State
    private let speetoService: SpeetoWinningInfoService
    
    // MARK: - Initialization
    
    init(speetoService: SpeetoWinningInfoService = .shared) {
        self.initialState = State()
        self.speetoService = speetoService
    }
    
    // MARK: - Mutate
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .loadSpeetoWinningInfo(type, page):
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.setLotteryType(type)),
                
                speetoService.getSpeetoWinningInfo(
                    lottoType: type.rawValue,
                    page: page
                )
                .flatMap { response -> Observable<Mutation> in
                    let data = response.storeLottoDrwInfoSpeeto
                    return Observable.concat([
                        Observable.just(Mutation.setWinningStores(data.content, append: false)),
                        Observable.just(Mutation.setPageInfo(
                            current: data.pageNum,
                            total: data.totalPages,
                            totalElements: data.totalElements
                        ))
                    ])
                }
                .catch { error -> Observable<Mutation> in
                    return Observable.just(Mutation.setError(error))
                },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .loadMoreWinningInfo:
            let currentState = currentState
            
            // 로딩 중이거나 더 이상 로드할 페이지가 없으면 아무 것도 하지 않음
            if currentState.isLoading || currentState.isLoadingMore || !currentState.canLoadMore {
                return Observable.empty()
            }
            
            let nextPage = currentState.currentPage + 1
            return Observable.concat([
                Observable.just(Mutation.setLoadingMore(true)),
                
                speetoService.getSpeetoWinningInfo(
                    lottoType: currentState.speetoType.rawValue,
                    page: nextPage
                )
                .flatMap { response -> Observable<Mutation> in
                    let data = response.storeLottoDrwInfoSpeeto
                    return Observable.concat([
                        Observable.just(Mutation.setWinningStores(data.content, append: true)),
                        Observable.just(Mutation.setPageInfo(
                            current: data.pageNum,
                            total: data.totalPages,
                            totalElements: data.totalElements
                        ))
                    ])
                }
                .catch { error -> Observable<Mutation> in
                    return Observable.just(Mutation.setError(error))
                },
                
                Observable.just(Mutation.setLoadingMore(false))
            ])
            
        case .refresh:
            return mutate(action: .loadSpeetoWinningInfo(type: currentState.speetoType, page: 0))
            
        case let .selectSpeetoType(type):
            return mutate(action: .loadSpeetoWinningInfo(type: type, page: 0))
        }
    }
    
    // MARK: - Reduce
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setWinningStores(stores, append):
            if append {
                newState.winningStores.append(contentsOf: stores)
            } else {
                newState.winningStores = stores
            }
            
        case let .setPageInfo(current, total, totalElements):
            newState.currentPage = current
            newState.totalPages = total
            newState.totalElements = totalElements
            
        case let .setLotteryType(type):
            newState.speetoType = type
            
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            if isLoading {
                newState.error = nil
            }
            
        case let .setLoadingMore(isLoading):
            newState.isLoadingMore = isLoading
            
        case let .setError(error):
            newState.error = error
        }
        
        return newState
    }
    
    // MARK: - Transform
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return mutation
    }
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        return action
    }
}



