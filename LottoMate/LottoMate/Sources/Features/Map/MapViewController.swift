//
//  MapView.swift
//  LottoMate
//
//  Created by Mirae on 7/26/24.
//

import UIKit
import CoreLocation
import NMapsMap
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift
import RxGesture
import BottomSheet

class MapViewController: UIViewController, View, CLLocationManagerDelegate {
    fileprivate let rootFlexContainer = UIView()
    
    let reactor = MapViewReactor()
    var disposeBag = DisposeBag()
    
    let mapView = NMFMapView()
    // 현재 위치 마커
    var currentMarker: NMFMarker?
    // 현재 선택된 스토어 마커
    var selectedStoreMarker: NMFMarker?
    
    /// 지도 초기 위치를 저장하는 변수
    private var initialCameraPosition: NMFCameraPosition?
    /// 지도 초기 로딩 여부를 추적하는 변수
    private var isInitialCameraChange = true
    /// 지도가 이동되었는지 추적하는 변수
    private var isMapMoved: Bool = false
    /// 바텀시트 접힐 때 마커 중앙 정렬을 위한 프로그래매틱 이동 여부
    private var isProgrammaticMapMove: Bool = false
    
    let tooltip = CustomTooltip(text: "현재 위치에서 검색하기", position: .right)
    
    var mapHeight: CGFloat = 0
    var tabBarHeight: CGFloat = 0.0
    
    let filterButton = ShadowRoundButton(title: "복권 전체", icon: UIImage(named: "icon_filter"), iconPosition: .left)
    let winningStoreButton = ShadowRoundButton(title: "당첨 판매점")
    let savedStoreButton = ShadowRoundButton(title: "찜")
    let refreshButton = ShadowRoundButton(icon: UIImage(named: "icon_refresh"))
    let currentLocationButton = ShadowRoundButton(icon: UIImage(named: "icon_ location"))
    let listButton = ShadowRoundButton(icon: UIImage(named: "icon_list"))
    let exploreMapButton = ShadowRoundButton(title: "로또 지도 둘러보기", icon: UIImage(named: "icon_arrow_right_svg"), iconPosition: .right)
    
    lazy var bottomSheet: CustomBottomSheetViewController = {
        let contentVC = StoreBottomSheetContainerViewController()
        let bottomSheet = CustomBottomSheetViewController(
            contentViewController: contentVC, minHeight: 48
        )
        bottomSheet.bind(reactor: reactor)
        return bottomSheet
    }()
    
    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.08) // Color Asset으로 등록하기
        view.alpha = 0
        return view
    }()
    
    // 오픈 안내 바텀시트
    private let regionAvailabilityBottomSheetVC: RegionAvailabilityBottomSheetVC = {
        let contentVC = RegionAvailabilityBottomSheetVC()
        return contentVC
    }()
    
    lazy var filterBottomSheet: LotteryTypeFilterBottomSheetViewController = {
        let contentVC = LotteryTypeFilterBottomSheetViewController()
        contentVC.bind(reactor: reactor)
        contentVC.preferredContentSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.width / 1.3
        )
        return contentVC
    }()
    
    private var isCurrentlyInSeoul = true
    // 서울시 행정구역 경계를 표현하는 좌표
    private let seoulBoundary: [NMGLatLng] = [
        NMGLatLng(lat: 37.6920, lng: 126.9038), // 은평구 북서쪽
        NMGLatLng(lat: 37.6920, lng: 126.9800), // 도봉구 북쪽
        NMGLatLng(lat: 37.6850, lng: 127.0568), // 도봉구 북동쪽
        NMGLatLng(lat: 37.6687, lng: 127.1052), // 노원구 북동쪽
        NMGLatLng(lat: 37.6268, lng: 127.1412), // 중랑구 동쪽
        NMGLatLng(lat: 37.5788, lng: 127.1613), // 강동구 동쪽
        NMGLatLng(lat: 37.5298, lng: 127.1455), // 강동구 남동쪽
        NMGLatLng(lat: 37.5057, lng: 127.1130), // 송파구 남동쪽
        NMGLatLng(lat: 37.4762, lng: 127.0410), // 강남구 남쪽
        NMGLatLng(lat: 37.4651, lng: 126.9959), // 서초구 남쪽
        NMGLatLng(lat: 37.4663, lng: 126.9224), // 관악구 남서쪽
        NMGLatLng(lat: 37.4871, lng: 126.8766), // 금천구 남서쪽
        NMGLatLng(lat: 37.5233, lng: 126.8398), // 양천구 서쪽
        NMGLatLng(lat: 37.5675, lng: 126.8260), // 강서구 서쪽
        NMGLatLng(lat: 37.6069, lng: 126.8352), // 강서구 북서쪽
        NMGLatLng(lat: 37.6647, lng: 126.8684), // 은평구 북서쪽
        NMGLatLng(lat: 37.6920, lng: 126.9038)  // 다시 처음으로
    ]
    
    // 서울 중심부 좌표
    private let seoulCenter = NMGLatLng(lat: 37.5665851, lng: 126.9782038)
    
    // 서울 바운딩 박스 생성 함수
    private func createSeoulBounds() -> NMGLatLngBounds {
        var minLat = Double.greatestFiniteMagnitude
        var minLng = Double.greatestFiniteMagnitude
        var maxLat = -Double.greatestFiniteMagnitude
        var maxLng = -Double.greatestFiniteMagnitude
        
        // 모든 좌표를 확인하여 최소/최대 값 찾기
        for point in seoulBoundary {
            minLat = min(minLat, point.lat)
            minLng = min(minLng, point.lng)
            maxLat = max(maxLat, point.lat)
            maxLng = max(maxLng, point.lng)
        }
        
        return NMGLatLngBounds(
            southWest: NMGLatLng(lat: minLat, lng: minLng),
            northEast: NMGLatLng(lat: maxLat, lng: maxLng)
        )
    }
    
    // 두 영역이 겹치는지 확인하는 함수
    private func isOverlapping(bounds1: NMGLatLngBounds, bounds2: NMGLatLngBounds) -> Bool {
        // 두 직사각형 영역이 겹치지 않는 조건
        if bounds1.northEast.lng < bounds2.southWest.lng || // 첫 번째 영역이 두 번째 영역 왼쪽에 있음
           bounds1.southWest.lng > bounds2.northEast.lng || // 첫 번째 영역이 두 번째 영역 오른쪽에 있음
           bounds1.northEast.lat < bounds2.southWest.lat || // 첫 번째 영역이 두 번째 영역 아래에 있음
           bounds1.southWest.lat > bounds2.northEast.lat {  // 첫 번째 영역이 두 번째 영역 위에 있음
            return false
        }
        return true
    }
    
    // 점이 다각형 내부에 있는지 확인하는 함수 (Ray-Casting 알고리즘)
    private func isPointInPolygon(point: NMGLatLng, polygon: [NMGLatLng]) -> Bool {
        let x = point.lng
        let y = point.lat
        
        var inside = false
        var j = polygon.count - 1
        
        for i in 0..<polygon.count {
            let xi = polygon[i].lng
            let yi = polygon[i].lat
            let xj = polygon[j].lng
            let yj = polygon[j].lat
            
            let intersect = ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi)
            if intersect {
                inside = !inside
            }
            
            j = i
        }
        
        return inside
    }
    
    // 현재 보이는 지도 영역이 서울을 포함하는지 확인
    func checkIfVisibleRegionIncludesSeoul() {
        // 현재 보이는 지도의 영역 가져오기
        let visibleBounds = mapView.contentBounds.boundsLatLngs
        let southWest = visibleBounds[0]  // 좌측 하단
        let northEast = visibleBounds[1]  // 우측 상단
        
        // 현재 줌 레벨 가져오기
        let zoomLevel = mapView.zoomLevel
        
        // 줌 레벨이 높을 때(확대했을 때)는 중심점만 체크
        if zoomLevel >= 14 { // 줌 레벨 14 이상은 상당히 확대된 상태
            // 화면 중심점 계산
            let centerLat = (northEast.lat + southWest.lat) / 2
            let centerLng = (northEast.lng + southWest.lng) / 2
            let centerPoint = NMGLatLng(lat: centerLat, lng: centerLng)
            
            // 중심점이 서울 내부에 있는지 확인
            let isInSeoul = isPointInPolygon(point: centerPoint, polygon: seoulBoundary)
            
            // UI 업데이트
            updateUIForSeoulVisibility(isInSeoul: isInSeoul)
            return
        }
        
        // 줌 레벨이 낮을 때(축소했을 때)는 기존 로직 사용
        // 서울 영역 생성
        let seoulBounds = createSeoulBounds()
        
        let nmgLatLng: NMGLatLngBounds = NMGLatLngBounds(southWest: southWest, northEast: northEast)
        
        // 방법 1: 간단한 바운딩 박스 기반 겹침 확인 (덜 정확하지만 빠름)
        let isSimpleOverlap = isOverlapping(bounds1: nmgLatLng, bounds2: seoulBounds)
        
        // 방법 2: 폴리곤 기반 체크 (더 정확하지만 계산 비용이 더 큼)
        // 보이는 영역의 중심점이 서울 폴리곤 내부에 있는지 확인
        let centerLat = (northEast.lat + southWest.lat) / 2
        let centerLng = (northEast.lng + southWest.lng) / 2
        let centerPoint = NMGLatLng(lat: centerLat, lng: centerLng)
        
        let isInPolygon = isPointInPolygon(point: centerPoint, polygon: seoulBoundary)
        
        // 최종 판단: 바운딩 박스 기반 체크와 폴리곤 기반 체크 결합
        // 중심점이 서울 폴리곤 내부에 있거나, 보이는 영역과 서울 영역이 겹치면 서울로 판단
        let isInSeoul = isInPolygon || isSimpleOverlap
        
        // UI 업데이트
        updateUIForSeoulVisibility(isInSeoul: isInSeoul)
    }
    
    // 서울 포함 여부에 따른 UI 업데이트
    private func updateUIForSeoulVisibility(isInSeoul: Bool) {
        // 상태가 변경되었을 때만 UI 업데이트 실행
        if isInSeoul != isCurrentlyInSeoul || isCurrentlyInSeoul == true {
            isCurrentlyInSeoul = isInSeoul
            
            // 리액터 상태 업데이트 - 바텀시트 내 notInSeoulView 표시 여부 연동
            reactor.action.onNext(.updateSeoulRegionStatus(isInSeoul))
            
            if isInSeoul {
                // 서울 지역인 경우
                TextButtonToastView.hide()
                
                // exploreMapButton 숨기기
                UIView.animate(withDuration: 0.3) {
                    self.exploreMapButton.alpha = 0
                } completion: { _ in
                    self.exploreMapButton.isHidden = true
                }
            } else {
                // 서울 지역이 아닌 경우
                // 토스트 표시
                TextButtonToastView.show(message: "오픈 준비 중인 지역이에요", horizontalPadding: 56)
                
                // exploreMapButton 표시
                self.exploreMapButton.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.exploreMapButton.alpha = 1
                }
            }
        }
    }
    
    func moveToSeoul() {
        // center 서울 시청으로 변경하기
        let cameraUpdate = NMFCameraUpdate(scrollTo: seoulCenter, zoomTo: 17)
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
    
    // 디버깅용: 서울 경계를 지도에 표시
    private func showSeoulBoundary() {
        if let polyline = NMFPolygonOverlay(seoulBoundary) {
            polyline.fillColor = UIColor.blue.withAlphaComponent(0.1)
            polyline.outlineColor = UIColor.blue
            polyline.outlineWidth = 3
            polyline.mapView = mapView
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // status bar view를 찾아서 숨김
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first,
           let statusBarView = window.viewWithTag(987654) {
            statusBarView.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // status bar view를 다시 보이게 함
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first,
           let statusBarView = window.viewWithTag(987654) {
            statusBarView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLocationAuthorizationChange(_:)),
            name: .locationAuthorizationStatusChanged,
            object: nil
        )
        
        self.view.backgroundColor = .white
        
        showRegionAvailabilityBottomSheet()
        
        mapView.zoomLevel = 17
        initialCameraPosition = mapView.cameraPosition
        updateRefreshButton(isActive: false)
        
//        showSeoulBoundary()
        
        reactor.action.onNext(.fetchInitialMapData(size: 20, boundary: getCurrentMapBoundary()))
        reactor.action.onNext(.getCurrentLocation)
        bind(reactor: reactor)
        
        addChild(bottomSheet)
        view.addSubview(bottomSheet.view)
        bottomSheet.didMove(toParent: self)
        bottomSheet.view.addDropShadow()
        
        let screenHeight = UIScreen.main.bounds.height
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            self.tabBarHeight = tabBarHeight
        }
        mapHeight = screenHeight - self.tabBarHeight
        
        mapView.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: mapView.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor)
        ])
        
        exploreMapButton.isHidden = true
        exploreMapButton.alpha = 0
        
        rootFlexContainer.flex.define { flex in
            flex.addItem(mapView)
                .minWidth(0)
                .maxWidth(.infinity)
                .height(mapHeight)
            
            flex.addItem(filterButton)
                .width(98)
                .height(38)
                .marginTop(8)
                .marginLeft(20)
                .position(.absolute)  // 버튼을 지도 위에 오버레이
            
            // 당첨 판매점만 보기 필터 버튼
//            flex.addItem(winningStoreButton)
//                .width(98)
//                .height(38)
//                .position(.absolute)
            
            // 찜한 판매점 보기 필터 버튼
//            flex.addItem(savedStoreButton)
//                .width(45)
//                .height(38)
//                .marginTop(8)
//                .position(.absolute)
            
            flex.addItem(tooltip)
                .width(125)
                .height(30)
                .position(.absolute)
            
            flex.addItem(refreshButton)
                .width(40)
                .height(40)
                .position(.absolute)
            
            flex.addItem(currentLocationButton)
                .width(40)
                .height(40)
                .position(.absolute)
            
            flex.addItem(listButton)
                .width(40)
                .height(40)
                .position(.absolute)
            
            flex.addItem(exploreMapButton)
                .width(151)
                .height(38)
                .position(.absolute)
            
            flex.addItem(bottomSheet.view)
                .width(100%)
                .position(.absolute)
        }
        view.addSubview(rootFlexContainer)
        bottomSheet.addToParent(self)
    }
    
    // deinit에 추가
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 지도가 완전히 로드된 후에 델리게이트 설정
        mapView.addCameraDelegate(delegate: self)
        bottomSheet.delegate = self
        // 지도가 완전히 로드된 후에 초기 지도가 서울에 포함되는지 확인
        checkIfVisibleRegionIncludesSeoul()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.top().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        filterButton.pin.top(view.safeAreaInsets)
        savedStoreButton.pin.top(view.safeAreaInsets).right().marginRight(20)
        winningStoreButton.pin.left(of: savedStoreButton, aligned: .center).marginRight(8)
        
        currentLocationButton.pin.above(of: bottomSheet.view, aligned: .left).marginLeft(20).marginBottom(28)
        refreshButton.pin.above(of: bottomSheet.view, aligned: .right).marginRight(20).marginBottom(28)
        tooltip.pin.left(of: refreshButton, aligned: .center).marginRight(8)
        listButton.pin.above(of: refreshButton, aligned: .center).marginBottom(20)
        exploreMapButton.pin.above(of: bottomSheet.view, aligned: .center).marginBottom(28)
    }
    
    func bind(reactor: MapViewReactor) {
        if let containerContent = bottomSheet.contentViewController as? StoreBottomSheetContainerViewController {
            containerContent.reactor = reactor
        }
        
        LocationManager.shared.getCurrentLocation()
            .take(1)
            .subscribe(onNext: { [weak self] locationResult in
                guard let self = self else { return }
                
                let location = locationResult.location
                
                let cameraUpdate = NMFCameraUpdate(
                    scrollTo: NMGLatLng(
                        lat: location.coordinate.latitude,
                        lng: location.coordinate.longitude
                    )
                )
                cameraUpdate.animation = .easeIn
                self.mapView.moveCamera(cameraUpdate)
                
                if !locationResult.isDefaultLocation {
                    // 현재 위치 마커 업데이트
                    self.updateMarker(at: location)
                }
            })
            .disposed(by: disposeBag)
        
        // 로딩
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    LoadingViewManager.shared.showLoading()
                } else {
                    LoadingViewManager.shared.hideLoading()
                }
            })
            .disposed(by: disposeBag)
        
        // 복권 종류 필터 버튼 Action
        filterButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // 현재 지도의 경계 정보를 액션과 함께 전달
                let boundary = self.getCurrentMapBoundary()
                self.reactor.action.onNext(.filterButtonTapped(boundary: boundary))
            })
            .disposed(by: disposeBag)
        
        // 복권 종류 필터 버튼 State
        reactor.state
            .map { $0.isfilterBottomSheetVisible }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isVisible in
                print("isVisible: \(isVisible)")
                if isVisible {
                    self?.showLotteryTypeFilter()
                }
            })
            .disposed(by: self.disposeBag)
        
        // 현재 위치 버튼 Action 수정
        currentLocationButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                // 현재 위치 권한 상태 확인
                let authStatus: CLAuthorizationStatus
                if #available(iOS 14.0, *) {
                    authStatus = CLLocationManager().authorizationStatus
                } else {
                    authStatus = CLLocationManager.authorizationStatus()
                }
                
                // Clear the selected store marker and reactor state
                if let previousMarker = self.selectedStoreMarker {
                    self.animateMarkerDeselection(marker: previousMarker)
                    self.selectedStoreMarker = nil
                }
                if self.reactor.currentState.selectedStore != nil {
                    self.reactor.action.onNext(.clearSelectedStore)
                }
                
                // 바텀시트를 collapsed 상태로 변경
                self.bottomSheet.collapse()
                
                // 지도의 contentInset 초기화 (중요: 이렇게 해야 마커가 정중앙에 위치)
                self.mapView.contentInset = UIEdgeInsets.zero
                
                // 권한 상태에 따른 처리
                switch authStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    // 권한이 허용된 경우, 현재 위치 요청
                    self.reactor.action.onNext(.getCurrentLocation)
                    
                case .denied, .restricted:
                    // 권한이 거부된 경우, 권한 요청 알림 표시
                    self.showLocationPermissionAlert()
                    
                case .notDetermined:
                    // 권한이 아직 결정되지 않은 경우, 권한 요청
                    CLLocationManager().requestWhenInUseAuthorization()
                    
                @unknown default:
                    // 기타 케이스 처리
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // 현재 위치 버튼 State
        Observable.combineLatest(
            reactor.state.map { $0.currentLocation }.distinctUntilChanged(),
            reactor.state.map { $0.isDefaultLocation }.distinctUntilChanged()
        )
        .compactMap { (location, isDefault) -> (CLLocation, Bool)? in
            guard let location = location else { return nil }
            return (location, isDefault)
        }
        .subscribe(onNext: { [weak self] (location, isDefault) in
            guard let self = self else { return }
            
            // default location이 아닐 경우에만 지도 이동 및 마커 표시
            if !isDefault {
                self.moveToLocation(location)
                self.updateMarker(at: location)
            } else {
                // 기본 위치인 경우 마커 제거
                self.currentMarker?.mapView = nil
            }
        })
        .disposed(by: disposeBag)
        
        // refresh 버튼
        refreshButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                // 현재 지도 영역의 바운더리 가져오기
                if self.isMapMoved {
                    let boundary = self.getCurrentMapBoundary()
                    // 바운더리를 사용하여 리로드 데이터
                    self.reactor.action.onNext(.reloadMapData(boundary: boundary))
                    self.isMapMoved = false
                    self.updateRefreshButton(isActive: false)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.storeListData }
            .distinctUntilChanged()
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] stores in
                // 현재 복권 타입 필터링을 통해 가져온 판매점 데이터만 있음 (수정 필요)
                if stores.count > 0 {
                    do {
                        try self?.addMarkers(for: stores)
                    } catch {
                        let error = LottoMateError.failedToAddMarkers(reason: error.localizedDescription)
                        print("\(error)")
                    }
                } else {
                    ToastView.show(message: "조건에 맞는 지점이 없어요", horizontalPadding: 174)
                }
            })
            .disposed(by: disposeBag)
        
        listButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.bottomSheet.expandToFullHeight()
                
                reactor.action.onNext(.updateBottomSheetContent(.list))
            })
            .disposed(by: disposeBag)
        
        filterBottomSheet.filterApplied
            .map { MapViewReactor.Action.applyLotteryTypeFilter($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 필터 버튼 타이틀 업데이트
        reactor.state
            .map { $0.filterButtonTitle }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] title in
                guard let self = self else { return }
                
                UIView.transition(with: self.filterButton,
                                  duration: 0.1,
                                  options: [.transitionCrossDissolve],
                                  animations: {
                    self.filterButton.setTitle(title)
                }, completion: nil)
            })
            .disposed(by: disposeBag)
        
        exploreMapButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // 서울 시청 좌표로 이동
                self.moveToSeoul()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.bottomSheetState }
            .distinctUntilChanged()
            .withLatestFrom(reactor.state) { ($0, $1) }
            .subscribe(onNext: { [weak self] (bottomSheetState, reactorState) in
                
                let isInSeoul = reactorState.isInSeoulRegion
                let shouldShow = bottomSheetState == .collapsed && !isInSeoul
                
                UIView.animate(withDuration: 0.3) {
                    self?.exploreMapButton.alpha = shouldShow ? 1 : 0
                } completion: { finished in
                    if finished {
                        self?.exploreMapButton.isHidden = !shouldShow
                    }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.locationAuthorizationStatus }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    // 위치 권한이 허용됨 - 필요한 UI 업데이트 수행
                    print("위치 권한이 허용됨")
                    
                case .denied, .restricted:
                    // 위치 권한이 거부됨 - 필요한 UI 업데이트 수행
                    print("위치 권한이 거부됨")
                    // 마커 제거 및 기타 처리
                    self.currentMarker?.mapView = nil
                    
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func moveToLocation(_ location: CLLocation) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude))
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
    
    func updateMarker(at location: CLLocation) {
        // 현재 위치에 이미 마커가 있다면 제거
        currentMarker?.mapView = nil
        
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        marker.iconImage = NMFOverlayImage(name: "currentLocationMarker")
        marker.mapView = mapView
        
        currentMarker = marker
    }
    
    func showLotteryTypeFilter() {
        presentBottomSheet(
            viewController: filterBottomSheet,
            configuration: BottomSheetConfiguration(
                cornerRadius: 0,
                pullBarConfiguration: .hidden,
                shadowConfiguration: .default
            ), canBeDismissed: {
                false
            }, dismissCompletion: {
                
            })
    }
    
    func addMarkers(for stores: [StoreDetailInfo]) throws {
        for store in stores {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: store.addrLat, lng: store.addrLot)
            marker.iconImage = NMFOverlayImage(name: "pin_default") // 기본 마커 이미지
            marker.captionText = store.storeNm // 확인용 (임시)
            marker.mapView = mapView
            
            // 마커와 스토어 데이터를 연결하기 위해 userInfo 사용
            marker.userInfo = ["storeData": store]
            
            // 마커 터치 이벤트 설정
            marker.touchHandler = { [weak self, reactor = self.reactor] (overlay: NMFOverlay) -> Bool in
                guard let self = self else { return false }
                
                // 프로그래매틱 이동 플래그 설정 - 이는 지도 이동 리스너에서 바텀시트를 접지 않게 함
                self.isProgrammaticMapMove = true
                
                // 이전에 선택된 마커가 있다면 애니메이션과 함께 기본 이미지로 변경
                if let previousMarker = self.selectedStoreMarker, previousMarker != overlay {
                    // 선택 해제 애니메이션 적용
                    self.animateMarkerDeselection(marker: previousMarker)
                }
                
                // 현재 터치된 마커를 선택된 마커로 변경
                if let touchedMarker = overlay as? NMFMarker {
                    // 이미 선택된 마커를 다시 탭한 경우는 무시
                    if touchedMarker == self.selectedStoreMarker {
                        self.isProgrammaticMapMove = false
                        return true
                    }
                    
                    // 선택 애니메이션 적용
                    self.animateMarkerSelection(marker: touchedMarker)
                    
                    // 선택된 마커 참조 저장
                    self.selectedStoreMarker = touchedMarker
                    
                    // 마커에 연결된 스토어 데이터 가져오기
                    if let storeData = touchedMarker.userInfo["storeData"] as? StoreDetailInfo {
                        reactor.action.onNext(.selectStore(storeData))
                        
                        // 바텀 시트가 이미 확장된 상태인지 확인
                        if self.bottomSheet.currentState != .collapsed {
                            // 선택될 때는 지도 이동으로 인해 바텀시트가 접히는 것을 방지
                            self.isMapMoved = false
                            
                            // 작은 애니메이션 효과로 내용이 변경됨을 표시 (완전히 collapse 하지 않음)
                            UIView.animate(withDuration: 0.15, animations: {
                                // 바텀시트를 약간만 내림
                                self.bottomSheet.heightConstraint?.constant = self.bottomSheet.heightConstraint?.constant ?? 0 - 20
                                self.view.layoutIfNeeded()
                            }, completion: { _ in
                                // 약간 올라오는 애니메이션
                                UIView.animate(withDuration: 0.3, delay: 0.05, options: .curveEaseOut, animations: {
                                    self.bottomSheet.expandToMidHeight()
                                })
                            })
                            
                            // 바텀시트가 이미 확장된 상태에서는 마커 위치 바로 조정
                            self.centerMapOnSelectedMarker(markerPosition: touchedMarker.position)
                        } else {
                            // 처음부터 접혀있는 경우, 바텀시트 먼저 확장 후 마커 위치 조정
                            
                            // 프로그래매틱 이동 플래그는 유지 (이미 상단에서 설정됨)
                            
                            // 바텀시트 확장
                            self.bottomSheet.collapse() // 이미 접혀있지만 상태 보장을 위해
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                                self?.bottomSheet.expandToMidHeight()
                                
                                // 바텀시트가 확장된 후에 마커 위치 조정 (약간의 딜레이 추가)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                                    guard let self = self else { return }
                                    self.centerMapOnSelectedMarker(markerPosition: touchedMarker.position)
                                }
                            }
                        }
                        
                        // 애니메이션 종료 후에 프로그래매틱 플래그 해제
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.isProgrammaticMapMove = false
                        }
                    }
                }
                
                return true
            }
        }
    }
    
    // 마커 애니메이션 관련 메서드 추가
    func animateMarkerSelection(marker: NMFMarker) {
        // 마커 크기 애니메이션
        marker.iconImage = NMFOverlayImage(name: "pin_select")
        
        // 확대 애니메이션
        UIView.animate(withDuration: 0.15, animations: {
            marker.height = 1.2 * marker.height
            marker.width = 1.2 * marker.width
        }, completion: { _ in
            // 약간 작아지는 애니메이션으로 반동 효과 주기
            UIView.animate(withDuration: 0.1) {
                marker.height = 1.1 * marker.width / 1.2
                marker.width = 1.1 * marker.width / 1.2
            }
        })
    }

    func animateMarkerDeselection(marker: NMFMarker) {
        // 축소 애니메이션
        UIView.animate(withDuration: 0.15, animations: {
            marker.height = marker.height / 1.1
            marker.width = marker.width / 1.1
        }, completion: { _ in
            // 애니메이션 완료 후 기본 이미지로 변경
            marker.iconImage = NMFOverlayImage(name: "pin_default")
        })
    }
    
    func centerMapOnSelectedMarker(markerPosition: NMGLatLng) {
        // 전체 화면 높이
        let screenHeight = UIScreen.main.bounds.height
        // 사용 가능한 전체 높이 (탭바 제외)
        let availableHeight = screenHeight - tabBarHeight
        // 바텀시트 높이 (availableHeight의 57%)
        let bottomSheetHeight = screenHeight * 0.57
        // 바텀시트 위 영역의 높이
        let visibleMapHeight = availableHeight - bottomSheetHeight
        
        // 바텀시트 위쪽 영역 중앙에 마커가 오도록 offset 계산
        let offsetY = visibleMapHeight / 2
        
        // 마커 탭 시에는 항상 바텀시트가 확장될 것을 가정하고 inset 설정
        // 이렇게 하면 탭 즉시 바텀시트 확장을 고려한 위치에 마커가 위치함
        mapView.contentInset = UIEdgeInsets(
            top: offsetY,
            left: 0,
            bottom: bottomSheetHeight, // 바텀시트 높이만큼 인셋 추가
            right: 0
        )
        
        // 먼저 기존 camera position 저장
        let originalPosition = mapView.cameraPosition
        
        // 카메라 이동 생성
        let cameraUpdate = NMFCameraUpdate(scrollTo: markerPosition)
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.3
        
        // 카메라 이동
        mapView.moveCamera(cameraUpdate)
    }
    
    func showRegionAvailabilityBottomSheet() {
        // Check if the bottom sheet has been shown before
        let userDefaults = UserDefaults.standard
        let hasShownBottomSheet = userDefaults.bool(forKey: "hasShownRegionAvailabilityBottomSheet")
        
        // If bottom sheet has already been shown, don't show it again
        if hasShownBottomSheet {
            return
        }
        
        regionAvailabilityBottomSheetVC.confirmButtonTapped
            .subscribe(onNext: { [weak self] _ in
                self?.regionAvailabilityBottomSheetVC.dismiss(animated: true)
                // Save the flag that the bottom sheet has been shown
                UserDefaults.standard.set(true, forKey: "hasShownRegionAvailabilityBottomSheet")
            })
            .disposed(by: disposeBag)
        
        presentBottomSheet(
            viewController: regionAvailabilityBottomSheetVC,
            configuration: BottomSheetConfiguration(
                cornerRadius: 32,
                pullBarConfiguration: .hidden,
                shadowConfiguration: .default
            ), canBeDismissed: {
                false
            }
        )
    }
    
    func getCurrentMapBoundary() -> MapBoundary {
        let visibleBounds = mapView.contentBounds.boundsLatLngs
        let southWest = visibleBounds[0]  // 좌측 하단
        let northEast = visibleBounds[1]  // 우측 상단
        
        // 좌측 상단 (leftLot, leftLat)
        let leftLot = southWest.lng       // 좌측 하단의 경도
        let leftLat = northEast.lat       // 우측 상단의 위도
        
        // 우측 하단 (rightLot, rightLat)
        let rightLot = northEast.lng      // 우측 상단의 경도
        let rightLat = southWest.lat      // 좌측 하단의 위도
        
        // 현재 사용자의 실제 위치를 가져오기
        let personLot: Double
        let personLat: Double
        
        if let currentLocation = reactor.currentState.currentLocation,
           !reactor.currentState.isDefaultLocation {
            // 실제 현재 위치가 있고 기본 위치가 아닌 경우
            personLot = currentLocation.coordinate.longitude
            personLat = currentLocation.coordinate.latitude
            print("🟢 [Boundary Debug] 사용자 실제 위치 사용")
            print("   - personLot: \(personLot)")
            print("   - personLat: \(personLat)")
        } else {
            // 현재 위치가 없거나 기본 위치인 경우 중앙 좌표 사용
            let centerCoord = mapView.cameraPosition.target
            personLot = centerCoord.lng
            personLat = centerCoord.lat
            print("🔴 [Boundary Debug] 지도 중앙 좌표 사용 (기본값)")
            print("   - personLot: \(personLot)")
            print("   - personLat: \(personLat)")
            print("   - isDefaultLocation: \(reactor.currentState.isDefaultLocation)")
            print("   - currentLocation exists: \(reactor.currentState.currentLocation != nil)")
        }
        
        let boundary = MapBoundary(
            leftLot: leftLot,
            leftLat: leftLat,
            rightLot: rightLot,
            rightLat: rightLat,
            personLot: personLot,
            personLat: personLat
        )
        
        print("📍 [Boundary Debug] 최종 Boundary 정보:")
        print("   - leftLot: \(leftLot), leftLat: \(leftLat)")
        print("   - rightLot: \(rightLot), rightLat: \(rightLat)")
        print("   - personLot: \(personLot), personLat: \(personLat)")
        print("   - 지도 중심: lat \(mapView.cameraPosition.target.lat), lng \(mapView.cameraPosition.target.lng)")
        
        return boundary
    }
    
    private func updateRefreshButton(isActive: Bool) {
        // 애니메이션 적용을 위한 지속 시간 상수
        let animationDuration: TimeInterval = 0.3
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            if isActive {
                // 버튼 활성화 상태
                self.refreshButton.filterIcon.tintColor = .blue50Default
                
                // 툴팁 표시 (fade in)
                self.tooltip.alpha = 1
                self.tooltip.isHidden = false
                
            } else {
                // 버튼 비활성화 상태
                self.refreshButton.filterIcon.tintColor = .gray100
                
                // 툴팁 숨김 (fade out)
                self.tooltip.alpha = 0
            }
        }, completion: { _ in
            // 애니메이션 완료 후 작업
            if !isActive {
                // 비활성화 시 즉시 숨김
                self.tooltip.isHidden = true
            }
        })
        
        // Shadow 애니메이션을 별도로 처리
        // CABasicAnimation을 사용하여 shadow 속성에 애니메이션 적용
        let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowOpacityAnimation.fromValue = isActive ? 0 : 0.5
        shadowOpacityAnimation.toValue = isActive ? 0.5 : 0
        shadowOpacityAnimation.duration = animationDuration
        
        let shadowColorAnimation = CABasicAnimation(keyPath: "shadowColor")
        shadowColorAnimation.fromValue = isActive ? UIColor.clear.cgColor : UIColor.blue50Default.cgColor
        shadowColorAnimation.toValue = isActive ? UIColor.blue50Default.cgColor : UIColor.clear.cgColor
        shadowColorAnimation.duration = animationDuration
        
        // 애니메이션 적용 후 최종 값으로 설정
        refreshButton.layer.add(shadowOpacityAnimation, forKey: "shadowOpacity")
        refreshButton.layer.add(shadowColorAnimation, forKey: "shadowColor")
        
        refreshButton.layer.shadowOpacity = isActive ? 0.5 : 0
        refreshButton.layer.shadowColor = isActive ? UIColor.blue50Default.cgColor : UIColor.clear.cgColor
        refreshButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        refreshButton.layer.shadowRadius = 8
        refreshButton.layer.masksToBounds = false
        
        // 렌더링 성능 향상을 위해 shadow path 설정
        refreshButton.layer.shadowPath = UIBezierPath(
            roundedRect: refreshButton.bounds,
            cornerRadius: refreshButton.layer.cornerRadius).cgPath
    }
    
    // 위치 권한 알림 메서드 추가
    func showLocationPermissionAlert() {
        let permissionView = LocationPermissionView.show()
        
        permissionView.onDeny = { [weak self] in
            // 아무 작업 없이 닫기
        }
        
        permissionView.onOpenSettings = { [weak self] in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
}

extension MapViewController: CustomBottomSheetDelegate {
    func bottomSheet(_ sheet: CustomBottomSheetViewController, didChangeState state: SheetState) {
        let shouldHideButtons = state == .expanded
        
        UIView.animate(withDuration: 0.1) {
            // 버튼들의 알파값 조정
            [self.refreshButton, self.currentLocationButton, self.listButton].forEach { button in
                button.alpha = shouldHideButtons ? 0 : 1
                button.isUserInteractionEnabled = !shouldHideButtons
            }
            
            // dimView의 알파값 조정
            self.dimView.alpha = shouldHideButtons ? 1 : 0
        }
        
        // 바텀시트가 접히면 선택된 마커를 전체 화면 기준 중앙에 위치시킴
        if state == .collapsed && selectedStoreMarker != nil {
            // 바텀시트가 사라지면 contentInset을 초기화
            mapView.contentInset = UIEdgeInsets.zero
            
            // 약간의 딜레이 후 마커를 화면 중앙에 위치시킴
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self, let marker = self.selectedStoreMarker else { return }
                
                // 프로그래매틱 이동 플래그 설정
                self.isProgrammaticMapMove = true
                
                let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position)
                cameraUpdate.animation = .easeIn
                cameraUpdate.animationDuration = 0.3
                self.mapView.moveCamera(cameraUpdate)
                
                // 애니메이션 종료 후 플래그 해제
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isProgrammaticMapMove = false
                }
            }
        }
    }
}

extension MapViewController: NMFMapViewCameraDelegate {
    // 카메라 이동이 완료된 후 호출
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        if isInitialCameraChange {
            isInitialCameraChange = false
            return
        }
        
        // 프로그래매틱 이동인 경우 (바텀시트 상태 변경에 의한 재중앙 정렬 또는 마커 선택) 처리 건너뛰기
        if isProgrammaticMapMove {
            return
        }
        
        // 현위치로 이동하여 지도 이동 시 NMFMapChangedByDeveloper 조건 필요
        if reason == NMFMapChangedByGesture || reason == NMFMapChangedByDeveloper {
            if !isMapMoved {
                isMapMoved = true
                updateRefreshButton(isActive: true)
            }
            
            // 마커 선택 시에는 지도 이동해도 바텀시트를 접지 않도록 수정
            // 마커를 통한 이동 중에는 지도 이동으로 인한 바텀시트 접기를 방지
            if reason != NMFMapChangedByDeveloper ||
               (reason == NMFMapChangedByDeveloper && selectedStoreMarker == nil) {
                // 지도 이동 시 바텀시트 접기
                if bottomSheet.currentState != .collapsed {
                    bottomSheet.collapse()
                }
            }
            
            // 새로 이동한 장소가 서울에 포함되는지 확인
            checkIfVisibleRegionIncludesSeoul()
        }
    }
    
    // 처음 카메라가 설정될 때는 이동으로 간주하지 않도록 처리
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        if initialCameraPosition == nil {
            initialCameraPosition = mapView.cameraPosition
        }
        // 카메라 이동이 멈추면 서울 영역 포함 여부 확인
        checkIfVisibleRegionIncludesSeoul()
    }
    
    // 위치 권한 변경 처리 메서드
    @objc private func handleLocationAuthorizationChange(_ notification: Notification) {
        guard let status = notification.userInfo?["status"] as? CLAuthorizationStatus else {
            return
        }
        
        // 리액터에 권한 상태 변경 전달
        reactor.action.onNext(.updateLocationAuthorizationStatus(status))
        
        // 권한이 허용된 경우 현재 위치 요청
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            reactor.action.onNext(.getCurrentLocation)
        } else {
            // 권한이 거부된 경우 현재 위치 마커 제거
            currentMarker?.mapView = nil
        }
    }
}

