//
//  HomeTabView.swift
//  LottoMate
//
//  Created by Mirae on 7/26/24.
//

import UIKit
import ReactorKit
import RxSwift
import RxRelay
import BottomSheet
import VisionKit

class HomeViewController: BaseViewController {
    private let reactor = HomeViewReactor()
    var disposeBag = DisposeBag()
    
    private let qrScanResult = BehaviorRelay<QRScanResult?>(value: nil)
    
    private let homeView: HomeView = {
        let view = HomeView()
        return view
    }()
    
    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        homeView.reactor = reactor
        reactor.action.onNext(.fetchInitialData)
        
        changeStatusBarBgColor(bgColor: .commonNavBar)
        
        let config = NavBarConfiguration(
            style: .logoAndSetting,
            leftButtonImage: UIImage(named: "logo_LottoMate"),
            rightButtonImage: UIImage(named: "icon_setting"),
            buttonTintColor: .gray100,
            logoSize: CGSize(width: 83, height: 24),
            isLogoButton: true
        )
        configureNavBar(config)
        
        setupBanner()
//        setupWinningReviewDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 화면에 진입할 때마다 새로운 disposeBag을 생성하여 중복 구독 방지
        disposeBag = DisposeBag()
        
        // 이전 스캔 결과 초기화 (bind() 호출 전에 실행하여 BehaviorRelay의 초기 값 방출 방지)
        qrScanResult.accept(nil)
        reactor.action.onNext(.resetWinningResult)
        
        // QR 스캐너 상태 초기화
        QRScannerManager.shared.resetScanResult()
        
        bind()
        
        // QR 스캐너 사용 후 내비게이션 바 레이아웃 조정
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func bind() {
        reactor.state
            .map { $0.showLotteryTypeDetail }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] showModal in
                if showModal {
                    self?.showLotteryTypeInfoView()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isMapVisible }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?.showMapViewController()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isQrScannerVisible }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?.showQrScanner()
            })
            .disposed(by: disposeBag)
        
        // QR 스캔 결과 처리를 위한 구독
        QRScannerManager.shared.scanResult
            .take(1) // 한 번만 처리하도록 제한
            .subscribe(onNext: { [weak self] urlString in
                guard let self = self,
                      let result = LottoQRParser.parse(from: urlString) else { return }
                
                // 테스트 용도로 항상 로딩뷰 프로세스 실행
//                 self.showLoadingAndCheckWinning(result)
                
                /* 운영 코드 - 테스트 후 주석 해제 */
                // 먼저 당첨 회차인지 확인 (미래 회차 확인)
                let latestLottoRound = self.reactor.currentState.latestLottoRound ?? 0

                // 미래 회차인 경우 로딩뷰 없이 바로 안내 화면 표시
                if result.lottoDrwNo > latestLottoRound {
                    // 미래 회차는 바로 AnnouncementWaitingVC 표시
                    // 임시 결과 객체 생성 (단일 객체)
                    if result.lottoNumbers.isEmpty {
                        // 로또 번호가 없는 경우 기본 처리
                        self.showLoadingAndCheckWinning(result)
                        return
                    }

                    let tempNumber = result.lottoNumbers.first ?? []
                    let tempResult = LottoNumberWithRank(
                        numbers: tempNumber,
                        rank: nil,
                        notAnnouncedYet: true,
                        drwNo: result.lottoDrwNo
                    )

                    if tempResult.isDrawToday {
                        // 추첨일이 오늘인 경우
                        if tempResult.isAfterDrawTime {
                            // 이미 추첨 시간이 지난 경우 서버에서 결과를 확인해야 함
                            // 이 경우에는 로딩 뷰를 표시하고 결과 확인
                            self.showLoadingAndCheckWinning(result)
                        } else {
                            // 아직 추첨 시간이 되지 않은 경우
                            self.showAnnouncementWaitingVC(state: .sameDayBeforeAnnouncement)
                        }
                    } else if let daysRemaining = tempResult.daysUntilDraw, daysRemaining > 0 {
                        // 추첨일이 미래인 경우
                        self.showAnnouncementWaitingVC(state: .daysBeforeAnnouncement(daysRemaining: daysRemaining))
                    } else {
                        // 기타 경우 일반적인 로딩 프로세스 진행
                        self.showLoadingAndCheckWinning(result)
                    }
                } else {
                    // 일반적인 로딩 프로세스 진행 (과거나 현재 회차)
                    self.showLoadingAndCheckWinning(result)
                }
            })
            .disposed(by: disposeBag)
        
        // qrScanResult를 통해 당첨 확인 요청 보내기
        // 이 로직은 showNormalLoadingProcess 메서드에서 qrScanResult를 accept할 때만 실행됨
        qrScanResult
            .skip(1) // 초기 nil 값을 건너뛰고 실제 값만 처리
            .compactMap { $0 }
//            .take(1) // 각 결과는 한 번만 처리
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                Observable.just(HomeViewReactor.Action.checkWinning(
                    drwNo: result.lottoDrwNo,
                    numbers: result.lottoNumbers
                ))
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        // winningResult를 구독하여 결과에 따라 화면 표시
        // 이 로직은 당첨 확인 결과가 있을 때만 실행됨
        reactor.state
            .map { $0.winningResult }
            .distinctUntilChanged()
            .filter { $0 != nil } // nil이 아닐 때만 처리
            .take(1) // 각 결과는 한 번만 처리
            .subscribe(onNext: { [weak self] winningResult in
                guard let self = self, let result = winningResult else { return }
                
                /* 테스트 용도로 당첨/미당첨에 따라 로딩뷰 표시 다르게 처리
                // 당첨 여부 확인
                let hasWinningNumbers = result.contains { $0.rank != nil && $0.rank! <= 5 }
                
                if hasWinningNumbers {
                    // 당첨된 경우 - 두 번째 로딩뷰 표시 후 결과 화면
                    QRWinningCheckLoadingManager.shared.showSecondLoadingStage()

                    // 1.5초 후에 결과 처리 (로딩 효과를 위한 지연)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        // 로딩 뷰 숨기기
                        QRWinningCheckLoadingManager.shared.hideLoading()
                        // 결과 화면 표시
                        self.showLottoWinningResultVC(result: result)
                    }
                } else {
                    // 미당첨된 경우 - 첫 번째 로딩뷰만 표시하고 바로 결과 화면
                    // 1.5초 후에 결과 처리 (첫 번째 로딩뷰 효과를 위한 지연)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        // 로딩 뷰 숨기기
                        QRWinningCheckLoadingManager.shared.hideLoading()
                        // 결과 화면 표시
                        self.showLottoWinningResultVC(result: result)
                    }
                }
                */
                
                // 당첨 발표 전인 회차인지 확인
                if result.first?.notAnnouncedYet == true, let firstResult = result.first {
                    // 즉시 로딩 뷰 숨기기
                    QRWinningCheckLoadingManager.shared.hideLoading()
                    
                    if firstResult.isDrawToday {
                        // 추첨일이 오늘인 경우
                        if firstResult.isAfterDrawTime {
                            // 이미 추첨 시간이 지난 경우 서버에서 결과를 다시 확인해야 함
                            Observable.just(HomeViewReactor.Action.checkWinning(
                                drwNo: firstResult.drwNo,
                                numbers: [firstResult.numbers]
                            ))
                            .bind(to: self.reactor.action)
                            .disposed(by: self.disposeBag)
                        } else {
                            // 아직 추첨 시간이 되지 않은 경우
                            self.showAnnouncementWaitingVC(state: .sameDayBeforeAnnouncement)
                        }
                    } else if let daysRemaining = firstResult.daysUntilDraw, daysRemaining > 0 {
                        // 추첨일이 미래인 경우
                        self.showAnnouncementWaitingVC(state: .daysBeforeAnnouncement(daysRemaining: daysRemaining))
                    }
                } else {
                    // 당첨 여부 확인
                    let hasWinningNumbers = result.contains { $0.rank != nil && $0.rank! <= 5 }
                    
                    if hasWinningNumbers {
                        // 당첨된 경우 - 두 번째 로딩뷰 표시 후 결과 화면
                        QRWinningCheckLoadingManager.shared.showSecondLoadingStage()

                        // 1.5초 후에 결과 처리 (로딩 효과를 위한 지연)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            // 로딩 뷰 숨기기
                            QRWinningCheckLoadingManager.shared.hideLoading()
                            // 결과 화면 표시
                            self.showLottoWinningResultVC(result: result)
                        }
                    } else {
                        // 미당첨된 경우 - 첫 번째 로딩뷰만 표시하고 바로 결과 화면
                        // 1.5초 후에 결과 처리 (첫 번째 로딩뷰 효과를 위한 지연)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            QRWinningCheckLoadingManager.shared.hideLoading()
                            self.showLottoWinningResultVC(result: result)
                        }
                    }
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    // 로또 당첨 결과 화면 표시
    private func showLottoWinningResultVC(result: [LottoNumberWithRank]) {
        print("📱 showLottoWinningResultVC 호출됨 - 결과 개수: \(result.count)")
        
        // 결과 로깅
        for (index, item) in result.enumerated() {
            print("📱 원본 결과 \(index + 1): 번호 \(item.numbers), 등수 \(item.rank ?? 0), 상금 \(item.prizeMoney ?? 0)")
        }
        
        // 당첨된 결과만 필터링하고 등수별로 정렬 (낮은 등수가 더 높은 등수임 - 1등이 가장 높음)
        let winningResults = result
            .filter { $0.rank != nil && $0.rank! <= 5 }
            .sorted { ($0.rank ?? Int.max) < ($1.rank ?? Int.max) }
        
        print("📱 필터링된 당첨 결과 개수: \(winningResults.count)")
        
        // 필터링된 결과 로깅
        for (index, item) in winningResults.enumerated() {
            print("📱 필터링된 결과 \(index + 1): 번호 \(item.numbers), 등수 \(item.rank ?? 0), 상금 \(item.prizeMoney ?? 0)")
        }
        
        if winningResults.isEmpty {
            // 모두 미당첨된 경우 - 하나의 미당첨 화면만 표시
            print("📱 미당첨 결과 화면 표시")
            let notWinningVC = LottoWinningResultVC(results: result)
            showLottoResultViewController(notWinningVC)
        } else {
            // 당첨된 결과가 있는 경우 - 여러 화면을 순차적으로 표시
            print("📱 당첨 결과 순차적으로 표시 시작 - \(winningResults.count)개")
            showWinningResultsSequentially(winningResults)
        }
    }
    
    // 당첨 결과를 순차적으로 표시하는 메서드
    private func showWinningResultsSequentially(_ results: [LottoNumberWithRank]) {
        print("📱 showWinningResultsSequentially 호출됨 - 결과 개수: \(results.count)")
        
        for (index, result) in results.enumerated() {
            print("📱 결과 확인 \(index + 1): 번호 \(result.numbers), 등수 \(result.rank ?? 0), 상금 \(result.prizeMoney ?? 0)")
        }
        
        guard !results.isEmpty else { return }
        
        // 화면을 순차적으로 표시하기 위한 ViewController 배열 생성
        var resultVCs: [LottoWinningResultVC] = []
        
        // 각 결과에 대한 ViewController 생성
        for (index, result) in results.enumerated() {
            print("📱 VC 생성 \(index + 1): 등수 \(result.rank ?? 0)")
            
            // 각 결과를 단일 요소 배열로 래핑하여 VC 생성
            let resultVC = LottoWinningResultVC(results: [result])
            resultVC.setCurrentResultIndex(0) // 항상 첫 번째 결과로 설정 (단일 결과임)
            
            resultVCs.append(resultVC)
        }
        
        // 각 VC에 다음 VC로 이동하는 콜백 설정
        for i in 0..<resultVCs.count {
            let currentVC = resultVCs[i]
            
            // 각 VC의 마지막 결과 여부를 명시적으로 설정
            let isLast = (i == resultVCs.count - 1)
            currentVC.setIsLastResult(isLast)
            print("📱 \(i + 1)번째 VC - isLastResult 설정: \(isLast)")
            
            if i < resultVCs.count - 1 {
                // 마지막이 아닌 VC에는 다음 화면으로 이동하는 콜백 설정
                let nextVC = resultVCs[i + 1]
                print("📱 \(i + 1)번째 VC에 다음 버튼 콜백 설정 - 다음 VC: \(i + 2)번째")
                
                // 클로저에서 사용할 인덱스 값을 복사
                let currentIndex = i
                
                currentVC.showNextResult = { [weak self] _ in
                    print("📱 다음 버튼 눌림: \(currentIndex + 1) -> \(currentIndex + 2)")
                    // 현재 VC를 닫고 다음 VC 표시
                    currentVC.dismissAll()
                    self?.showLottoResultViewController(nextVC)
                }
            } else {
                // 마지막 VC에는 완료 콜백 설정
                print("📱 마지막 \(i + 1)번째 VC에 완료 콜백 설정")
                currentVC.dismissCompletion = { [weak self] in
                    // 정리 작업 수행
                    self?.qrScanResult.accept(nil)
                    self?.reactor.action.onNext(.resetWinningResult)
                    self?.view.setNeedsLayout()
                    self?.view.layoutIfNeeded()
                }
            }
        }
        
        // 첫 번째 결과 화면 표시
        if let firstVC = resultVCs.first {
            print("📱 첫 번째 결과 화면 표시 (등수: \(firstVC.winningResults.first?.rank ?? 0))")
            showLottoResultViewController(firstVC)
        }
    }
    
    // 로또 결과 뷰컨트롤러를 표시하는 공통 메서드
    private func showLottoResultViewController(_ viewController: LottoWinningResultVC) {
        if let window = WindowManager.findKeyWindow(),
           let rootViewController = window.rootViewController {
            viewController.view.frame = window.bounds
            
            rootViewController.addChild(viewController)
            rootViewController.view.addSubview(viewController.view)
            
            viewController.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                viewController.view.transform = .identity
            } completion: { _ in
                viewController.didMove(toParent: rootViewController)
            }
        }
    }
    
    func showLotteryTypeInfoView() {
        let lotteryTypeInfoViewController = LotteryTypeInfoViewController()
        lotteryTypeInfoViewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 670) // 사이즈가 맞지 않아서 임의로 조정
        
        presentBottomSheet(viewController: lotteryTypeInfoViewController,
                           configuration: BottomSheetConfiguration(
                            cornerRadius: 32,
                            pullBarConfiguration: .hidden,
                            shadowConfiguration: .default
                           ), canBeDismissed: {
                               true
                           }, dismissCompletion: {
                               self.reactor.action.onNext(.hideLotteryTypeDetailView)
                           })
    }
    
    @objc override func rightButtonTapped() {
        let settingViewController = SettingViewController()
        // reactor 추가 가능 여기서
        
        if let window = WindowManager.findKeyWindow() {
            settingViewController.view.frame = window.bounds
            
            if let rootViewController = window.rootViewController {
                rootViewController.addChild(settingViewController)
                rootViewController.view.addSubview(settingViewController.view)
                
                settingViewController.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)

                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.curveEaseInOut]) {
                    settingViewController.view.transform = .identity
                } completion: { _ in
                    settingViewController.didMove(toParent: rootViewController)
                }
                settingViewController.changeStatusBarBgColor(bgColor: .commonNavBar)
            }
        }
    }
    
    func showMapViewController() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1
        }
    }
    
    func showStorageRandomNumbersView() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 2
            
            if let storageViewController = tabBarController.viewControllers?[2] as? StorageViewController {
                storageViewController.reactor.action.onNext(.didSelectrandomNumber)
            }
        }
    }
    
    func showQrScanner() {
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
    
    func showAnnouncementWaitingVC(state: AnnouncementWaitingState) {
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
                self?.qrScanResult.accept(nil) // QR 스캔 결과 초기화
                
                // Reset the HomeViewReactor state for winningResult
                self?.reactor.action.onNext(.resetWinningResult)
                
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }
        }
    }

    func showWinningReviewDetail(reviewNo: Int) {
        let detailVC = NativeWinningReviewDetailViewController(reviewNo: reviewNo)

        if let navigationController = self.navigationController {
            navigationController.pushViewController(detailVC, animated: true)
        } else if let window = WindowManager.findKeyWindow(),
                  let rootViewController = window.rootViewController as? UITabBarController,
                  let selectedNav = rootViewController.selectedViewController as? UINavigationController {
            selectedNav.pushViewController(detailVC, animated: true)
        }
    }

    func showLottoWinningInfoView() {
        let viewController = WinningInfoDetailViewController()

        if let window = WindowManager.findKeyWindow() {
            viewController.view.frame = window.bounds
            if let rootViewController = window.rootViewController {
                rootViewController.addChild(viewController)
                rootViewController.view.addSubview(viewController.view)
                viewController.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.curveEaseInOut]) {
                    viewController.view.transform = .identity
                } completion: { _ in
                    viewController.didMove(toParent: rootViewController)
                }
                viewController.changeStatusBarBgColor(bgColor: .commonNavBar)
            }
        }
    }

    // 로딩뷰를 표시하고 당첨 확인 과정을 처리하는 메서드
    private func showLoadingAndCheckWinning(_ qrResult: QRScanResult) {
        // 첫 번째 로딩뷰 표시
        QRWinningCheckLoadingManager.shared.showFirstLoadingStage(
            onComplete: { [weak self] in
                guard let self = self else { return }
                
                // API 호출 테스트가 아닌 경우 (실제 API 사용) - 실제 서비스에서 주석 해제
                self.qrScanResult.accept(qrResult)
                
//                 테스트를 위한 코드 - 실제 서비스에서는 주석 처리
                
                // 테스트 모드 설정
//                enum WinningTestMode {
//                    case noWinning           // 미당첨
//                    case singleWinning       // 단일 당첨
//                    case multipleWinning     // 여러 개 당첨 (1~5등 다양하게)
//                    case jackpot             // 1등 당첨
//                    case mixedResults        // 일부는 당첨, 일부는 미당첨
//                }
//                
//                // 테스트할 모드 선택 (원하는 모드로 변경)
//                let testMode: WinningTestMode = .mixedResults
//                
//                // Mock 데이터 생성을 위한 파라미터 (실제 QR 스캔 결과와 무관하게 사용)
//                let mockDrwNo = 1234  // 가상의 회차 번호
//                let mockNumbersCount = 5  // 몇 개의 번호 세트를 생성할지 (5개 권장)
//                
//                // 즉시 모의 데이터 생성 (중간 지연 제거)
//                var mockResults: [LottoNumberWithRank] = []
//                
//                // 로또 번호 세트 생성 함수 (6개 숫자 배열 생성)
//                func generateRandomLottoNumbers() -> [Int] {
//                    var numbers = Set<Int>()
//                    while numbers.count < 6 {
//                        numbers.insert(Int.random(in: 1...45))
//                    }
//                    return Array(numbers).sorted()
//                }
//                
//                switch testMode {
//                case .noWinning:
//                    // 미당첨 결과 - 모든 번호가 미당첨
//                    for _ in 0..<mockNumbersCount {
//                        let mockNumbers = generateRandomLottoNumbers()
//                        let result = LottoNumberWithRank(
//                            numbers: mockNumbers,
//                            rank: nil,
//                            notAnnouncedYet: false,
//                            drwNo: mockDrwNo
//                        )
//                        mockResults.append(result)
//                    }
//                    
//                case .singleWinning:
//                    // 단일 당첨 결과 - 하나의 등수만 당첨
//                    let winningRank = Int.random(in: 1...5)
//                    
//                    // 첫 번째 세트는 당첨
//                    let winningNumbers = generateRandomLottoNumbers()
//                    let winningResult = LottoNumberWithRank(
//                        numbers: winningNumbers,
//                        rank: winningRank,
//                        notAnnouncedYet: false,
//                        drwNo: mockDrwNo,
//                        prizeMoney: self.getDummyPrizeMoney(for: winningRank)
//                    )
//                    mockResults.append(winningResult)
//                    
//                    // 나머지는 미당첨
//                    for _ in 1..<mockNumbersCount {
//                        let mockNumbers = generateRandomLottoNumbers()
//                        let result = LottoNumberWithRank(
//                            numbers: mockNumbers,
//                            rank: nil,
//                            notAnnouncedYet: false,
//                            drwNo: mockDrwNo
//                        )
//                        mockResults.append(result)
//                    }
//                    
//                case .multipleWinning:
//                    // 여러 당첨 결과 - 각 번호마다 다른 등수로 당첨
//                    for i in 0..<mockNumbersCount {
//                        if i < 5 { // 최대 5등까지만 있음
//                            let rank = i + 1
//                            let mockNumbers = generateRandomLottoNumbers()
//                            let result = LottoNumberWithRank(
//                                numbers: mockNumbers,
//                                rank: rank,
//                                notAnnouncedYet: false,
//                                drwNo: mockDrwNo,
//                                prizeMoney: self.getDummyPrizeMoney(for: rank)
//                            )
//                            mockResults.append(result)
//                        } else {
//                            // 5등까지만 있으니 나머지는 미당첨 처리
//                            let mockNumbers = generateRandomLottoNumbers()
//                            let result = LottoNumberWithRank(
//                                numbers: mockNumbers,
//                                rank: nil,
//                                notAnnouncedYet: false,
//                                drwNo: mockDrwNo
//                            )
//                            mockResults.append(result)
//                        }
//                    }
//                    
//                case .jackpot:
//                    // 1등 당첨 결과 - 모든 번호가 1등
//                    for _ in 0..<mockNumbersCount {
//                        let mockNumbers = generateRandomLottoNumbers()
//                        let result = LottoNumberWithRank(
//                            numbers: mockNumbers,
//                            rank: 1,
//                            notAnnouncedYet: false,
//                            drwNo: mockDrwNo,
//                            prizeMoney: self.getDummyPrizeMoney(for: 1)
//                        )
//                        mockResults.append(result)
//                    }
//                    
//                case .mixedResults:
//                    // 혼합 결과 - 다양한 등수와 미당첨 혼합
//                    // 1등, 3등, 미당첨, 2등, 5등 순서로 생성
//                    let ranks = [1, 3, nil, 2, 5]
//                    
//                    for i in 0..<min(mockNumbersCount, ranks.count) {
//                        let mockNumbers = generateRandomLottoNumbers()
//                        let rank = ranks[i]
//                        let prizeMoney = rank != nil ? self.getDummyPrizeMoney(for: rank!) : 0
//                        
//                        let result = LottoNumberWithRank(
//                            numbers: mockNumbers,
//                            rank: rank,
//                            notAnnouncedYet: false,
//                            drwNo: mockDrwNo,
//                            prizeMoney: prizeMoney
//                        )
//                        mockResults.append(result)
//                    }
//                    
//                    // 추가 번호가 필요한 경우 미당첨으로 처리
//                    if mockNumbersCount > ranks.count {
//                        for _ in ranks.count..<mockNumbersCount {
//                            let mockNumbers = generateRandomLottoNumbers()
//                            let result = LottoNumberWithRank(
//                                numbers: mockNumbers,
//                                rank: nil,
//                                notAnnouncedYet: false,
//                                drwNo: mockDrwNo
//                            )
//                            mockResults.append(result)
//                        }
//                    }
//                }
//                
//                // 로그로 생성된 결과 확인
//                print("📱 테스트 모드: \(testMode)")
//                for (index, result) in mockResults.enumerated() {
//                    print("📱 결과 \(index + 1): 번호 \(result.numbers), 등수 \(result.rank ?? 0), 상금 \(result.prizeMoney ?? 0)")
//                }
//                
//                // 당첨 여부 확인
//                let hasWinningNumbers = mockResults.contains { $0.rank != nil && $0.rank! <= 5 }
//                
//                if hasWinningNumbers {
//                    // 당첨된 경우 - 두 번째 로딩뷰 표시
//                    QRWinningCheckLoadingManager.shared.showSecondLoadingStage()
//                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                        QRWinningCheckLoadingManager.shared.hideLoading()
//                        self.showLottoWinningResultVC(result: mockResults)
//                    }
//                } else {
//                    // 미당첨 테스트 - 첫 번째 로딩뷰만 표시하고 바로 결과 화면으로 이동
//                    QRWinningCheckLoadingManager.shared.hideLoading()
//                    self.showLottoWinningResultVC(result: mockResults)
//                } // MARK: 테스트 모드 코드 끝
            }
        )
    }
    
    // 등수별 더미 당첨금액 반환 (LottoWinningResultVC에서 복사해온 메서드)
    private func getDummyPrizeMoney(for rank: Int) -> Int {
        switch rank {
        case 1:
            return Int.random(in: 1_500_000_000...50_000_000_000)  // 약 15억~500억원
        case 2:
            return Int.random(in: 50_000_000...80_000_000)  // 약 5천만~8천만원
        case 3:
            return Int.random(in: 1_200_000...1_800_000)  // 약 120~180만원
        case 4:
            return 50_000  // 5만원 (고정)
        case 5:
            return 5_000   // 5천원 (고정)
        default:
            return 0
        }
    }
}

extension HomeViewController: BannerNavigationDelegate {
    private func setupBanner() {
        let banner = BannerManager.shared.createRandomBanner(navigationDelegate: self) // 랜덤
//        let banner = BannerManager.shared.createBanner(type: .expandServicetoMyArea, navigationDelegate: self) // 테스트용
        
        homeView.bannerContainer.flex.addItem(banner)
    }
    
    func navigate(to bannerType: BannerType) {
        switch bannerType {
        case .winningStore:
            self.showMapViewController()
        
        case .winnerReview:
            let currentReviewNos = WinningReviewReactor.shared.currentState.currentReviewNos

            if let maxNo = currentReviewNos.max() {
                showWinningReviewDetail(reviewNo: maxNo)
            } else {
                WinningReviewAPIService().fetchWinningReviewMaxNumber()
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] maxNo in
                        self?.showWinningReviewDetail(reviewNo: maxNo)
                    })
                    .disposed(by: disposeBag)
            }

        case .getRandomLottoNumbers:
            showStorageRandomNumbersView()
            
        case .expandServicetoMyArea:
            let urlString = "https://www.google.com" // TODO: 실제 URL로 변경 필요
            WebViewController.present(from: self, urlString: urlString, title: "서비스 지역 확대")

        case .winningLottoInfo:
            LottoMateViewModel.shared.selectedLotteryType.onNext(.lotto)
            showLottoWinningInfoView()
            
        case .qrCodeScanner:
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

        case .winnerGuide:
            showWinnerGuide()
        }
    }
    
    func showWinnerGuide() {
        let winnerGuideVC = WinnerGuideVC()
        if let window = WindowManager.findKeyWindow(),
           let rootViewController = window.rootViewController {
            winnerGuideVC.view.frame = window.bounds
            
            rootViewController.addChild(winnerGuideVC)
            rootViewController.view.addSubview(winnerGuideVC.view)
            
            winnerGuideVC.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                winnerGuideVC.view.transform = .identity
            } completion: { _ in
                winnerGuideVC.didMove(toParent: rootViewController)
            }

            winnerGuideVC.changeStatusBarBgColor(bgColor: .commonNavBar)
        }
    }
}

