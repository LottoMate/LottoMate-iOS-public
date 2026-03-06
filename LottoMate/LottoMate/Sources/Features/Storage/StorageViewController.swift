//
//  StorageViewController.swift
//  LottoMate
//
//  Created by Mirae on 10/24/24.
//

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxGesture
import RxRelay

class StorageViewController: BaseViewController {
    // MARK: - Properties
    let reactor = StorageViewReactor()
    
    private let storageView: StorageView = {
        let view = StorageView()
        view.backgroundColor = .white
        return view
    }()
    
    var disposeBag = DisposeBag()

    private let qrScanResult = BehaviorRelay<QRScanResult?>(value: nil)
    
    override func loadView() {
        view = storageView
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        storageView.reactor = reactor
        
        configureNavBar(
            NavBarConfiguration(style: .titleOnly, title: "랜덤 번호")
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 화면에 진입할 때마다 새로운 disposeBag을 생성하여 중복 구독 방지
        disposeBag = DisposeBag()
        bind(reactor: reactor)
        
        // Update tab bar height when view appears
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            storageView.updateTabBarHeight(tabBarHeight)
        }
        
        // QR 스캐너 상태 초기화
        QRScannerManager.shared.resetScanResult()
        
        // 이전 스캔 결과 초기화
        qrScanResult.accept(nil)
        reactor.action.onNext(.resetWinningResult)
        
        // MyNumbers 뷰 강제 업데이트 (번호 등록 후 돌아왔을 때 바로 반영)
        storageView.forceUpdateMyNumbersView()
        
        // QR 스캐너 사용 후 내비게이션 바 레이아웃 조정
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension StorageViewController {
    func bind(reactor: StorageViewReactor) {
        // QR 스캐너 표시 상태 변경 처리
        reactor.state
            .map { $0.showQrScanner }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] showQrScanner in
                if showQrScanner {
                    self?.showQrScanner()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.reactor.action.onNext(.resetQrScannerState)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // QR 스캔 결과 처리
        QRScannerManager.shared.scanResult
            .take(1) // 한 번만 처리하도록 제한
            .subscribe(onNext: { [weak self] urlString in
                guard let self = self,
                      let result = LottoQRParser.parse(from: urlString) else { return }
                self.qrScanResult.accept(result)
            })
            .disposed(by: disposeBag)
        
        // qrScanResult 변경 시 reactor로 전달
        qrScanResult
            .compactMap { $0 }
            .take(1) // 각 결과는 한 번만 처리
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                
                Observable.just(StorageViewReactor.Action.checkWinning(
                    drwNo: result.lottoDrwNo,
                    numbers: result.lottoNumbers
                ))
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        // 당첨 결과 상태 변화 감지 및 화면 표시
        reactor.state
            .map { $0.winningResult }
            .distinctUntilChanged()
            .filter { $0 != nil } // nil이 아닐 때만 처리
            .take(1) // 각 결과는 한 번만 처리
            .subscribe(onNext: { [weak self] winningResult in
                guard let self = self, let result = winningResult else { return }
                
                // 당첨 발표 전인지 확인
                if let firstResult = result.first, firstResult.notAnnouncedYet == true {
                    if firstResult.isDrawToday {
                        // 추첨일이 오늘인 경우
                        if !firstResult.isAfterDrawTime {
                            // 추첨 시간 전인 경우 - 대기 화면 표시
                            self.showAnnouncementWaitingVC(state: .sameDayBeforeAnnouncement)
                        } else {
                            // 추첨 시간 후인 경우 - 결과 다시 확인
                            Observable.just(StorageViewReactor.Action.checkWinning(
                                drwNo: firstResult.drwNo,
                                numbers: [firstResult.numbers]
                            ))
                            .bind(to: reactor.action)
                            .disposed(by: self.disposeBag)
                        }
                    } else if let daysRemaining = firstResult.daysUntilDraw, daysRemaining > 0 {
                        // 추첨일이 미래인 경우
                        self.showAnnouncementWaitingVC(state: .daysBeforeAnnouncement(daysRemaining: daysRemaining))
                    }
                } else {
                    // 이미 발표된 결과 처리
                    print("Show winning result screen: \(result)")
                }
            })
            .disposed(by: disposeBag)

        // "번호 등록하기" 버튼 탭 시 화면 이동
        reactor.state
            .map { $0.navigateToAddNumber }
            .distinctUntilChanged()
            .filter { $0 } // true 일 때만 실행
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let numberEntryVC = NumberEntryViewController()
                // MARK: 네비게ーション 스타일 설정 부분은 프로젝트에 맞게 수정 필요
                numberEntryVC.hidesBottomBarWhenPushed = true // 예시: 탭 바 숨기기
                self.navigationController?.pushViewController(numberEntryVC, animated: true)
                self.reactor.action.onNext(.resetNavigation) // 네비게이션 상태 리셋
            })
            .disposed(by: disposeBag)
    }
    
    private func showQrScanner() {
        if let window = WindowManager.findKeyWindow() {
            if let rootViewController = window.rootViewController {
                let frameView = QrScannerOverlayView()
                Task {
                    QRScannerManager.shared.presentScanner(
                        from: rootViewController,
                        with: frameView
                    )
                }
            }
        }
    }
    
    private func showAnnouncementWaitingVC(state: AnnouncementWaitingState) {
        let announcementWaitingVC = AnnouncementWaitingVC(state: state)
        
        if let window = WindowManager.findKeyWindow(),
           let rootViewController = window.rootViewController {
            announcementWaitingVC.view.frame = window.bounds
            
            rootViewController.addChild(announcementWaitingVC)
            rootViewController.view.addSubview(announcementWaitingVC.view)
            
            announcementWaitingVC.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                announcementWaitingVC.view.transform = .identity
            } completion: { _ in
                announcementWaitingVC.didMove(toParent: rootViewController)
            }
            
            // Add dismiss handler
            announcementWaitingVC.dismissCompletion = { [weak self] in
                self?.qrScanResult.accept(nil) // Reset QR scan result
                
                // Reset the reactor state for winningResult
                self?.reactor.action.onNext(.resetWinningResult)
                
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }
        }
    }
}

protocol LoadingDisplayable: AnyObject {
    var loadingView: RandomNumbersLoadingView? { get set }
    
    func showLoading(with reactor: StorageViewReactor?)
    func hideLoading(completion: (() -> Void)?)
}

extension LoadingDisplayable where Self: UIView {
    func showLoading(with reactor: StorageViewReactor?) {
        loadingView?.removeFromSuperview()
        
        let newLoadingView = RandomNumbersLoadingView()
        newLoadingView.reactor = reactor
        loadingView = newLoadingView
        
        if let window = WindowManager.findKeyWindow() {
            window.addSubview(newLoadingView)
            newLoadingView.frame = window.bounds
            
            loadingView?.transform = CGAffineTransform(translationX: 0, y: window.bounds.height)
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseOut,
                           animations: {
                self.loadingView?.transform = .identity
            })
        }
    }
    
    func hideLoading(completion: (() -> Void)? = nil) {
        guard let window = WindowManager.findKeyWindow() else { return }
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
            // window의 height만큼 아래로 이동
            self.loadingView?.transform = CGAffineTransform(translationX: 0, y: window.bounds.height)
        }, completion: { _ in
            self.loadingView?.removeFromSuperview()
            self.loadingView = nil
            // 랜덤 번호 뷰 새로 고침...?
            completion?()
        })
    }
}

#Preview {
    StorageViewController()
}
