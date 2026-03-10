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



