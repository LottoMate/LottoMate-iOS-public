//
//  NumberEntryReactor.swift
//  LottoMate
//
//  Created by Mirae on 1/31/25.
//

import ReactorKit
import RxSwift

final class NumberEntryReactor: Reactor {
    
    enum Action {
        // 사용자 입력 액션 정의
    }
    
    enum Mutation {
        // 상태 변경을 위한 뮤테이션 정의
    }
    
    struct State {
        // 뷰의 상태 정의
    }
    
    let initialState: State
    private let disposeBag = DisposeBag()
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        // Action을 Mutation으로 변환
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        // Mutation을 통해 새로운 State 생성
        var newState = state
        return newState
    }
}
