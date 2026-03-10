//
//  LocationManager.swift
//  LottoMate
//
//  Created by Mirae on 10/14/24.
//

import CoreLocation
import RxSwift
import RxCocoa
import RxRelay

class LocationManager: NSObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let authorizationStatus = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    private let currentLocation = BehaviorRelay<CLLocation?>(value: nil)
    private let disposeBag = DisposeBag()
    
    // 농협은행 본사 위치 (서울 중구 새문안로 16 농협중앙회 중앙본부)
    private let defaultLocation = CLLocation(latitude: 37.5664991184072, longitude: 126.968555570622)
    
    private let isUsingDefaultLocation = BehaviorRelay<Bool>(value: true)
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if #available(iOS 14.0, *) {
            authorizationStatus.accept(locationManager.authorizationStatus)
        } else {
            authorizationStatus.accept(CLLocationManager.authorizationStatus())
        }
    }
    
    func requestLocationAuthorization() -> Observable<CLAuthorizationStatus> {
        return Observable.create { observer in
            self.authorizationStatus
                .take(1)
                .subscribe(onNext: { status in
                    if status == .notDetermined {
                        self.locationManager.requestWhenInUseAuthorization()
                    } else {
                        observer.onNext(status)
                        observer.onCompleted()
                    }
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
        .concat(authorizationStatus.asObservable())
        .distinctUntilChanged()
    }
    
    func observeAuthorizationStatus() -> Observable<CLAuthorizationStatus> {
        return authorizationStatus.asObservable().distinctUntilChanged()
    }
    
    struct LocationResult {
        let location: CLLocation
        let isDefaultLocation: Bool
    }
    
    func checkAuthorizationStatus() {
        let currentStatus: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            currentStatus = locationManager.authorizationStatus
        } else {
            currentStatus = CLLocationManager.authorizationStatus()
        }
        
        // 상태가 변경되었는지 확인
        let previousStatus = authorizationStatus.value
        
        if currentStatus != previousStatus {
            // 상태 업데이트
            authorizationStatus.accept(currentStatus)
            
            // 권한 상태 변경 알림 전송
            NotificationCenter.default.post(
                name: .locationAuthorizationStatusChanged,
                object: nil,
                userInfo: ["status": currentStatus]
            )
            
            // 권한이 허용된 경우, 위치 업데이트 시작
            if currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways {
                isUsingDefaultLocation.accept(false)
                locationManager.startUpdatingLocation()
            } else {
                // 권한이 거부된 경우, 기본 위치 사용 플래그 설정
                isUsingDefaultLocation.accept(true)
            }
        }
    }
    
    func getCurrentLocation() -> Observable<LocationResult> {
        return Observable.create { observer in
            
            // 권한 상태 확인
            let authStatus = self.authorizationStatus.value
            
            // 권한이 허용되지 않은 경우 기본 위치 반환
            if authStatus != .authorizedWhenInUse && authStatus != .authorizedAlways {
                self.isUsingDefaultLocation.accept(true)
                
                observer.onNext(LocationResult(
                    location: self.defaultLocation,
                    isDefaultLocation: true
                ))
                
                observer.onCompleted()
                return Disposables.create()
            }
            
            let authorizationDisposable = self.authorizationStatus
                .filter { $0 == .authorizedWhenInUse || $0 == .authorizedAlways }
                .take(1)
                .subscribe(onNext: { _ in
                    self.locationManager.startUpdatingLocation()
                })
            
            let locationDisposable = self.currentLocation
                .compactMap { $0 }
                .take(1)
                .subscribe(onNext: { location in
                    observer.onNext(LocationResult(
                        location: location,
                        isDefaultLocation: false
                    ))
                    observer.onCompleted()
                })
            
            return Disposables.create([authorizationDisposable, locationDisposable])
        }
    }
    
    func getDefaultLocation() -> CLLocation {
        return defaultLocation
    }
    
    func loadStoreList() -> Observable<[StoreInfo]> {
        return Observable.create { observer in
            // 샘플 데이터 로드 시뮬레이션
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { // 1초 지연을 주어 네트워크 요청을 시뮬레이션
                guard let storeList = JSONLoader.loadStoreList()?.storeInfo else {
                    observer.onError(NSError(domain: "com.example.LottoMate", code: 0, userInfo: [NSLocalizedDescriptionKey: "No sample data available"]))
                    return
                }
                
                observer.onNext(storeList)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            authorizationStatus.accept(manager.authorizationStatus)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus.accept(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation.accept(location)
        locationManager.stopUpdatingLocation()
    }
}
