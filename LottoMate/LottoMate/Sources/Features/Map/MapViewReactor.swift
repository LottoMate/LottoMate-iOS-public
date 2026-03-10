//
//  MapViewReactor.swift
//  LottoMate
//
//  Created by Mirae on 9/25/24.
//

import UIKit
import ReactorKit
import RxSwift
import CoreLocation
import Moya

/// 지도 바텀 시트 모드
enum BottomSheetViewMode {
    /// 판매점들을 리스트 형태로 보여줍니다.
    case list
    /// 하나의 판매점 정보를 보여줍니다.
    case detail
}

class MapViewReactor: Reactor {
    enum Action {
        case fetchInitialMapData(size: Int, boundary: MapBoundary)
        case filterButtonTapped(boundary: MapBoundary)
        case getCurrentLocation
        case reloadMapData(boundary: MapBoundary)
        case applyLotteryTypeFilter([LotteryType])
        case updateSheetState(SheetState)
        case selectStore(StoreDetailInfo)
        case showStoreList
        case updateBottomSheetContent(BottomSheetViewMode)
        case updateSeoulRegionStatus(Bool)
        case filterBottomSheetDismissed
        /// 위치 권한 업데이트
        case updateLocationAuthorizationStatus(CLAuthorizationStatus)
        /// 판매점 목록을 거리순으로 정렬
        case sortStoresByDistance
        /// 판매점 목록을 랭킹순으로 정렬
        case sortStoresByRank
        case clearSelectedStore
    }
    
    enum Mutation {
        /// 복권 종류 필터 바텀 시트 visible
        case setBottomSheetVisible(Bool)
        case setCurrentLocation(CLLocation, Bool)
        case reloadMapData([StoreInfo])
        case setLoading(Bool)
        case setError(Error)
        case setStoreListData([StoreDetailInfo])
        case setSelectedLotteryType([LotteryType])
        case setFilterButtonTitle(String)
        case setBottomSheetState(SheetState)
        case setSelectedStore(StoreDetailInfo?)
        case setBottomSheetViewMode(BottomSheetViewMode)
        case setInSeoulRegionStatus(Bool)
        case setLocationAuthorizationStatus(CLAuthorizationStatus)
        /// 현재 지도의 경계 정보 설정
        case setCurrentMapBoundary(MapBoundary)
    }
    
    struct State {
        var storeListData: [StoreDetailInfo] = []
        /// 복권 종류 필터 바텀 시트 visible
        var isfilterBottomSheetVisible: Bool = false
        var currentLocation: CLLocation?
        var isDefaultLocation: Bool = true // true이면 농협 본사, false이면 현위치
        var lotteryStores: [StoreInfo] = []
        var isLoading: Bool = true
        var error: Error?
        var selectedLotteryTypes: [LotteryType] = [.lotto, .pensionLottery]
        var filterButtonTitle: String = "복권 전체"
        var bottomSheetState: SheetState = .collapsed
        var bottomSheetViewMode: BottomSheetViewMode = .list
        var selectedStore: StoreDetailInfo?
        var isInSeoulRegion: Bool = true
        var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
        /// 현재 지도의 경계 정보
        var currentMapBoundary: MapBoundary?
    }
    
    let initialState = State()
    
    private let provider: MoyaProvider<MapEndpoint> = NetworkProviderFactory.makeProvider(plugins: [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    ])
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchInitialMapData(let size, let boundary):
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                provider.rx.request(.getStoreList(
                    boundary: boundary,
                    size: 20,
                    dis: true
                ))
                .map(StoreListResponse.self)
                .asObservable()
                .map { response in
                    Mutation.setStoreListData(response.storeInfo.content)
                }
                    .catch { error in
                        return Observable.just(Mutation.setError(error))
                    },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .filterButtonTapped(let boundary):
            return Observable.concat([
                // 복권 종류 필터 버튼을 탭한 시점의 map boundary를 저장
                Observable.just(.setCurrentMapBoundary(boundary)),
                Observable.just(.setBottomSheetVisible(true))
            ])
        
        case .getCurrentLocation:
            return LocationManager.shared.getCurrentLocation()
                .map { result in
                    Mutation.setCurrentLocation(result.location, result.isDefaultLocation)
                }
        
        case .reloadMapData(let boundary):
            // 새로고침 버튼 탭 시
            return Observable.concat([
                Observable.just(.setLoading(true)),
                
                provider.rx.request(.getStoreList(
                    boundary: boundary,
                    type: getLotteryTypeValue(from: currentState.selectedLotteryTypes).type,
                    page: 1,
                    size: 20,
                    dis: true
                ))
                .map(StoreListResponse.self)
                .asObservable()
                .map { response in
                    Mutation.setStoreListData(response.storeInfo.content)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error))
                },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .applyLotteryTypeFilter(let selectedTypes):
            print("DEBUG: selectedTypes - \(selectedTypes)")
            let typeValue = getLotteryTypeValue(from: selectedTypes)
            let buttonTitle = typeValue.title
            
            // 저장된 경계 정보 사용
            guard let boundary = currentState.currentMapBoundary else {
                return Observable.just(Mutation.setError(LottoMateError.emptyMapBoundary))
            }
            
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                Observable.just(Mutation.setSelectedLotteryType(selectedTypes)),
                
                provider.rx.request(.getStoreList(
                    boundary: boundary,
                    type: typeValue.type,
                    page: 1,
                    size: 20 // 임시로 100
                ))
                .map(StoreListResponse.self)
                .asObservable()
                .map { response in
                    print("DEBUG: API response received with \(response.storeInfo.content.count) items")
                    return Mutation.setStoreListData(response.storeInfo.content)
                }
                .flatMap { mutation -> Observable<Mutation> in
                    // API 호출 성공 후 버튼 제목 설정 추가
                    print("DEBUG: Inside flatMap, preparing to emit mutations")
                    return Observable.concat([
                        Observable.just(mutation),
                        Observable.just(Mutation.setFilterButtonTitle(buttonTitle))
                    ])
                }
                .do(onNext: { mutation in
                    print("DEBUG: Emitting mutation: \(mutation)")
                })
                .catch { error in
                    print("DEBUG: Error in API request: \(error)")
                    return Observable.just(Mutation.setError(error))
                },
                
                Observable.just(Mutation.setBottomSheetVisible(false)),
                
                Observable.just(Mutation.setLoading(false))
            ])
        
        case .updateSheetState(let state):
            return (.just(.setBottomSheetState(state)))
        
        case .selectStore(let store):
            return .concat([
                .just(.setSelectedStore(store)),
                .just(.setBottomSheetViewMode(.detail))
            ])
        
        case .showStoreList:
            // 리스트 버튼 동작 중복되는지 확인하기
            return .just(.setBottomSheetViewMode(.list))
        
        case .updateBottomSheetContent(let viewMode):
            return .just(.setBottomSheetViewMode(viewMode))
        
        case .updateSeoulRegionStatus(let isInSeoul):
            return .just(.setInSeoulRegionStatus(isInSeoul))
        
        case .filterBottomSheetDismissed:
            return .just(.setBottomSheetVisible(false))
        
        case .updateLocationAuthorizationStatus(let status):
            return Observable.just(Mutation.setLocationAuthorizationStatus(status))
        
        case .sortStoresByDistance:
            // Sort the current list by distance
            return Observable.just(currentState.storeListData)
                .map { stores in
                    let sortedStores = stores.sorted { store1, store2 in
                        // Parse distance string to Double
                        let distance1 = Double(store1.distance.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? Double.infinity
                        let distance2 = Double(store2.distance.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? Double.infinity
                        
                        return distance1 < distance2
                    }
                    return Mutation.setStoreListData(sortedStores)
                }
        
        case .sortStoresByRank:
            // Sort the current list by rank based on lottoInfos place field
            return Observable.just(currentState.storeListData)
                .map { stores in
                    let sortedStores = stores.sorted { store1, store2 in
                        // Get the minimum place value from lottoInfos for each store
                        // Lower place value is better (1st place is better than 2nd)
                        let minPlace1 = store1.lottoInfos.map { $0.place }.min() ?? Int.max
                        let minPlace2 = store2.lottoInfos.map { $0.place }.min() ?? Int.max
                        
                        // If both stores have the same best place, sort by number of jackpots
                        if minPlace1 == minPlace2 {
                            let totalJackpots1 = store1.lottoInfos.compactMap { $0.lottoJackpot }.reduce(0, +)
                            let totalJackpots2 = store2.lottoInfos.compactMap { $0.lottoJackpot }.reduce(0, +)
                            return totalJackpots1 > totalJackpots2
                        }
                        
                        return minPlace1 < minPlace2
                    }
                    return Mutation.setStoreListData(sortedStores)
                }
        
        case .clearSelectedStore:
            return Observable.just(Mutation.setSelectedStore(nil))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setBottomSheetVisible(let isVisible):
            newState.isfilterBottomSheetVisible = isVisible
        
        case .setCurrentLocation(let location, let isDefault):
            newState.currentLocation = location
            newState.isDefaultLocation = isDefault
        
        case .reloadMapData(let stores):
            newState.lotteryStores = stores
        
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        
        case .setError(let error):
            newState.error = error
        
        case .setStoreListData(let storeListData):
            print("DEBUG: setStoreListData mutation received with \(storeListData.count) items")
            newState.storeListData = storeListData
        
        case .setSelectedLotteryType(let types):
            print("DEBUG: setSelectedLotteryType mutation received with \(types)")
            newState.selectedLotteryTypes = types
        
        case .setFilterButtonTitle(let title):
            print("DEBUG: setFilterButtonTitle mutation received with title: \(title)")
            newState.filterButtonTitle = title
        
        case .setBottomSheetState(let state):
            newState.bottomSheetState = state
        
        case .setSelectedStore(let store):
            newState.selectedStore = store
        
        case .setBottomSheetViewMode(let viewMode):
            newState.bottomSheetViewMode = viewMode
        
        case .setInSeoulRegionStatus(let isInSeoul):
            newState.isInSeoulRegion = isInSeoul
        
        case .setLocationAuthorizationStatus(let status):
            newState.locationAuthorizationStatus = status
            
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                newState.isDefaultLocation = true
            } else {
                newState.isDefaultLocation = false
            }
        
        case .setCurrentMapBoundary(let boundary):
            newState.currentMapBoundary = boundary
        }
        
        return newState
    }
}
 
