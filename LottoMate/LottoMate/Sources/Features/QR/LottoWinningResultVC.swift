//
//  LottoWinningResultVC.swift
//  LottoMate
//
//  Created by Mirae on 4/28/25.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift

class LottoWinningResultVC: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()

    // MARK: - UI Elements
    fileprivate let rootFlexContainer = UIView()
    
    private let illustrationImageView = UIImageView()
    private let titleLabel = UILabel()
    private let prizeMoneyLabel = UILabel()
    private let approximatePrizeLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let notWinningBodyLabel = UILabel()
    
    private let bannerContainerView = UIView()
    
    let statusBarHeight = DeviceMetrics.statusBarHeight
    
    private let confirmButton = StyledButton(
        title: "확인",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    // MARK: - Properties
    let winningResults: [LottoNumberWithRank]
    var dismissCompletion: (() -> Void)?
    
    // 현재 보여주고 있는 결과의 인덱스
    private var currentResultIndex = 0
    // 다음 결과 보여주기 위한 콜백
    var showNextResult: ((LottoNumberWithRank) -> Void)?
    // 현재 결과가 마지막인지 여부
    private var isLastResult: Bool = false
    // 외부에서 강제로 설정할 수 있는 마지막 결과 여부 플래그
    private var forceLastResult: Bool? = nil
    
    // MARK: - Initialization
    init(results: [LottoNumberWithRank]) {
        self.winningResults = results
        super.init(nibName: nil, bundle: nil)
        
        print("📱 LottoWinningResultVC 초기화: 결과 개수 = \(results.count)")
        for (index, result) in results.enumerated() {
            print("📱   결과 \(index + 1): 등수 \(result.rank ?? 0)")
        }
        
        // 현재 결과가 마지막인지 설정
        updateIsLastResult()
        
        // 버튼 타이틀 설정 (다음 또는 확인)
        updateButtonTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        
        print("📱 LottoWinningResultVC - viewDidLoad: 결과 개수 = \(winningResults.count), showNextResult 콜백 = \(showNextResult != nil ? "설정됨" : "없음")")
        
        // 기존의 populateWithResults 대신 현재 인덱스의 결과만 표시
        if !winningResults.isEmpty {
            populateWithCurrentResult()
        } else {
            showNotWinningUI()
        }
        
        // setupDummyPrizeMoneyIfNeeded() // 더미 금액 설정 비활성화
        setupBanner()
        
        // viewDidLoad에서 한 번 더 버튼 타이틀 업데이트
        updateButtonTitle()
        print("📱 LottoWinningResultVC - viewDidLoad 마지막에 버튼 타이틀 재설정: \(confirmButton.title(for: .normal) ?? "nil")")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 화면이 나타날 때 버튼 타이틀 다시 확인
        updateButtonTitle()
        print("📱 LottoWinningResultVC - viewWillAppear: 버튼 타이틀 = \(confirmButton.title(for: .normal) ?? "nil"), isLastResult = \(isLastResult)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.top(view.safeAreaInsets).bottom().horizontally()
        rootFlexContainer.flex.layout()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Setup status image
        illustrationImageView.contentMode = .scaleAspectFit
        
        // Setup labels
        styleLabel(for: titleLabel, fontStyle: .title3, textColor: .gray120)
        styleLabel(for: prizeMoneyLabel, fontStyle: .display2, textColor: .black)
        styleLabel(for: approximatePrizeLabel, fontStyle: .headline2, textColor: .gray100)
        styleLabel(for: descriptionLabel, fontStyle: .body1, textColor: .gray110)
        
        // Setup button - 버튼 타이틀은 결과 상태에 따라 설정
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        // 버튼 타이틀을 명시적으로 설정
        updateButtonTitle()
        print("📱 LottoWinningResultVC - setupUI에서 버튼 타이틀 설정: \(confirmButton.title(for: .normal) ?? "nil"), isLastResult = \(isLastResult)")
    }
    
    private func setupLayout() {
        view.addSubview(rootFlexContainer)
        
        // Create a container for the content elements that will be centered
        let contentContainer = UIView()
        
        rootFlexContainer.flex
            .direction(.column)
            .define { flex in
                flex.addItem(contentContainer)
                    .grow(1)
                    .shrink(1)
                    .alignItems(.center)
                    .justifyContent(.center)
                    .define { contentFlex in
                        contentFlex.addItem(titleLabel)
                            .alignSelf(.center)
                            .marginBottom(2)
                        
                        contentFlex.addItem(prizeMoneyLabel)
                            .alignSelf(.center)
                            .marginBottom(2)
                            .display(.none)
                        
                        contentFlex.addItem(approximatePrizeLabel)
                            .alignSelf(.center)
                            .marginBottom(24)
                            .display(.none)
                        
                        contentFlex.addItem(notWinningBodyLabel)
                            .alignSelf(.center)
                            .marginBottom(24)
                            .display(.none)
                        
                        contentFlex.addItem(illustrationImageView)
                            .alignSelf(.center)
                            .marginBottom(24)
                        
                        contentFlex.addItem(descriptionLabel)
                            .alignSelf(.center)
                            .display(.none)
                    }
                
                flex.addItem(bannerContainerView)
                    .width(UIScreen.main.bounds.width - 40)
                    .marginBottom(24)
                    .alignSelf(.center)
                
                flex.addItem(confirmButton)
                    .width(UIScreen.main.bounds.width - 40)
                    .paddingHorizontal(20)
                    .marginBottom(32)
                    .alignSelf(.center)
            }
    }
    
    // MARK: - Actions
    @objc private func confirmButtonTapped() {
        print("📱 LottoWinningResultVC - 버튼 탭: isLastResult = \(isLastResult), currentResultIndex = \(currentResultIndex), 버튼 타이틀 = \(confirmButton.title(for: .normal) ?? "nil")")
        
        // 먼저 현재 결과가 당첨인지 확인
        let isCurrentResultWinning = isWinningResult()
        
        if isLastResult {
            if isCurrentResultWinning {
                // 당첨된 경우에만 저장 팝업 표시
//                showSavePopup()
                // 로또 보관소 임시 주석처리하며 팝업도 주석처리 함
                dismissAll()
            } else {
                // 미당첨된 경우 바로 dismiss
                dismissAll()
            }
        } else {
            // 마지막 결과가 아닌 경우 다음 결과 표시
            if let showNext = showNextResult {
                // 현재 결과가 있으면 그것을 전달, 아니면 빈 더미 결과 전달
                let resultToPass = winningResults.first ?? LottoNumberWithRank(
                    numbers: [], rank: nil, notAnnouncedYet: false, drwNo: 0
                )
                print("📱 LottoWinningResultVC - showNextResult 콜백 호출 - 전달 결과: 등수 \(resultToPass.rank ?? 0)")
                showNext(resultToPass)
            } else {
                // 콜백이 없는 경우
                if isCurrentResultWinning {
                    // 당첨된 경우에만 저장 팝업 표시
                    showSavePopup()
                } else {
                    // 미당첨된 경우 바로 dismiss
                    dismissAll()
                }
            }
        }
    }
    
    // 현재 결과가 당첨된 결과인지 확인
    private func isWinningResult() -> Bool {
        guard let currentResult = winningResults[safe: currentResultIndex] else { return false }
        // 등수가 있고 1~5등 사이면 당첨된 결과
        return currentResult.rank != nil && currentResult.rank! <= 5
    }
    
    // 저장 팝업 표시
    private func showSavePopup() {
        let popupView = LottoResultSavePopupView.show()
        
        // "아니오" 버튼 처리
        popupView.onNo = { [weak self] in
            self?.dismissAll()
        }
        
        // "저장하기" 버튼 처리
        popupView.onSave = { [weak self] in
            // 여기에 저장 로직 구현
            // 저장 후 화면 닫기
            self?.dismissAll()
        }
    }
    
    // 모든 화면 닫기
    public func dismissAll() {
        // Handle case where presented modally
        if let presentingVC = self.presentingViewController {
            presentingVC.dismiss(animated: true) { [weak self] in
                self?.dismissCompletion?()
            }
        }
        // Handle case where added as child view controller
        else if let parentVC = self.parent {
            UIView.animate(withDuration: 0.3, animations: {
                // Animate out to the right
                if let superviewWidth = self.view.superview?.bounds.width {
                    self.view.transform = CGAffineTransform(translationX: superviewWidth, y: 0)
                }
            }) { [weak self] _ in
                guard let self = self else { return }
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.dismissCompletion?()
            }
        }
        // Fallback case
        else {
            self.dismiss(animated: true) { [weak self] in
                self?.dismissCompletion?()
            }
        }
    }
    
    // 결과가 마지막인지 여부 업데이트
    private func updateIsLastResult() {
        // 외부에서 강제로 설정한 값이 있으면 그것을 우선 사용
        if let forcedValue = forceLastResult {
            isLastResult = forcedValue
        } else {
            // 내부 로직은 그대로 유지
            isLastResult = currentResultIndex >= winningResults.count - 1
        }
    }
    
    // 버튼 텍스트 업데이트
    private func updateButtonTitle() {
        let buttonTitle = isLastResult ? "확인" : "다음"
        confirmButton.setTitle(buttonTitle, for: .normal)
        // Force layout update
        confirmButton.layoutIfNeeded()
    }
    
    // 특정 인덱스의 결과로 현재 인덱스 설정
    func setCurrentResultIndex(_ index: Int) {
        guard index >= 0, index < winningResults.count else { return }
        currentResultIndex = index
        updateIsLastResult()
        updateButtonTitle()
    }
    
    // 외부에서 강제로 마지막 결과 여부를 설정하는 메서드
    func setIsLastResult(_ isLast: Bool) {
        forceLastResult = isLast
        updateIsLastResult()
        updateButtonTitle()
    }
    
    // 대략적인 당첨금액을 계산하여 표시하는 함수
    private func formatApproximatePrize(amount: Int, rank: Int?) -> String {
        guard let rank = rank, rank <= 5 else { return "" }
        
        // 4등과 5등은 고정 금액
        if rank == 4 {
            return "5만 원"
        } else if rank == 5 {
            return "5천 원"
        }
        
        // 1, 2, 3등은 대략적인 금액 또는 변동금액 표시
        if amount > 0 {
            // 금액이 있는 경우 대략적인 표시
            if amount < 10_000 { // 만원 미만
                return "\(amount)원"
            } else if amount < 10_000_000 { // 천만원 미만 (약 n만 원)
                let manwon = amount / 10_000
                return "약 \(manwon)만 원"
            } else if amount < 100_000_000 { // 1억 미만 (약 n백만 원)
                let millionWon = amount / 10_000_000
                let remainder = (amount % 10_000_000) / 1_000_000
                
                if remainder > 0 {
                    return "약 \(millionWon)천\(remainder)백만 원"
                } else {
                    return "약 \(millionWon)천만 원"
                }
            } else if amount < 1_000_000_000 { // 10억 미만 (약 n억 원)
                let millionWon = amount / 1_000_000
                return "약 \(millionWon)백만 원"
            } else { // 10억 이상 (약 n억 원)
                let billion = amount / 100_000_000
                return "약 \(billion)억 원"
            }
        } else {
            // 금액이 없는 경우 변동금액 표시
            return "변동금액"
        }
    }
    
    // MARK: - Dummy Data for Prize Money
    private func setupDummyPrizeMoneyIfNeeded() {
        // This method is now disabled - we're using fixed prize money for ranks 4-5
        // and actual API values or placeholder text for ranks 1-3
        /*
        // 각 결과에 대해 더미 금액을 설정 (서버에서 오는 값이 없는 경우)
        for (index, result) in winningResults.enumerated() {
            if let rank = result.rank, (result.prizeMoney == nil || result.prizeMoney == 0) {
                // 가변 배열을 만들어 수정된 결과를 저장
                var mutatedResults = winningResults
                
                // 랭크에 맞는 더미 금액 생성
                let dummyPrizeMoney = getDummyPrizeMoney(for: rank)
                
                // 새로운 LottoNumberWithRank 객체 생성
                let updatedResult = LottoNumberWithRank(
                    numbers: result.numbers,
                    rank: result.rank,
                    notAnnouncedYet: result.notAnnouncedYet,
                    drwNo: result.drwNo,
                    prizeMoney: dummyPrizeMoney,
                    drawDate: result.drawDate
                )
                
                // 결과 배열 업데이트
                mutatedResults[index] = updatedResult
                
                // 새 배열을 기존 프로퍼티에 할당할 수 없으므로 UI만 업데이트
                // 실제로는 서버에서 값을 받아오거나 저장소에서 관리해야 함
            }
        }
        */
    }
    
    // 등수별 더미 당첨금액 반환
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
    
    // populateWithCurrentResult 메소드 - 현재 인덱스의 결과로 UI 업데이트
    private func populateWithCurrentResult() {
        guard let currentResult = winningResults[safe: currentResultIndex] else { return }
        
        // 현재 결과의 당첨 여부 확인
        if let rank = currentResult.rank, rank <= 5 {
            // 당첨된 경우
            populateWithWinningResult(currentResult)
        } else {
            // 미당첨된 경우
            showNotWinningUI()
        }
        
        // UI 업데이트 후 버튼 타이틀 다시 확인
        updateButtonTitle()
        print("📱 LottoWinningResultVC - populateWithCurrentResult 후 버튼 타이틀: \(confirmButton.title(for: .normal) ?? "nil")")
    }
    
    // 당첨된 결과로 UI 업데이트
    private func populateWithWinningResult(_ result: LottoNumberWithRank) {
        // 당첨된 경우
        if let rank = result.rank {
            titleLabel.text = "로또 \(rank)등 당첨"
            styleLabel(for: titleLabel, fontStyle: .title3, textColor: .gray120)
            
            // 등수에 따라 다른 이미지 표시
            switch rank {
            case 1:
                // 1등 이미지
                illustrationImageView.image = UIImage(named: "ch_winning_1st")
            case 2:
                // 2등 이미지
                illustrationImageView.image = UIImage(named: "ch_winning_2nd_3rd")
            case 3:
                // 3등 이미지
                illustrationImageView.image = UIImage(named: "ch_winning_2nd_3rd")
            case 4:
                // 4등 이미지
                illustrationImageView.image = UIImage(named: "ch_winning_4th_5th")
            case 5:
                // 5등 이미지
                illustrationImageView.image = UIImage(named: "ch_winning_4th_5th")
            default:
                // 기본 당첨 이미지
                illustrationImageView.image = UIImage(named: "ch_winning_4th_5th")
                approximatePrizeLabel.flex.display(.none)
            }
        } else {
            // 등수 정보가 없는 경우 기본 당첨 이미지
            illustrationImageView.image = UIImage(named: "ch_winning_4th_5th")
            approximatePrizeLabel.flex.display(.none)
        }
        
        // 당첨된 경우 공통 높이 설정
        illustrationImageView.flex.height(UIScreen.main.bounds.width / 1.994)
        
        // 실제 당첨 금액 표시
        var prizeAmount = result.prizeMoney ?? 0
        
        // 4등과 5등은 고정 금액으로 표시
        if let rank = result.rank {
            if rank == 4 {
                prizeMoneyLabel.text = "50,000원"
            } else if rank == 5 {
                prizeMoneyLabel.text = "5,000원"
            } else if rank <= 3 {
                // 1, 2, 3등은 API에서 받은 금액 사용
                if prizeAmount > 0 {
                    prizeMoneyLabel.text = "\(prizeAmount.formattedWithSeparator())원"
                } else {
                    // API에서 금액이 없는 경우 "변동" 표시
                    prizeMoneyLabel.text = "금액 변동 (회차마다 상이)"
                }
            }
        } else {
            // 등수 정보가 없는 경우 (미당첨인데 여기까지 왔다면)
            prizeMoneyLabel.text = "-"
        }
        
        prizeMoneyLabel.numberOfLines = 2
        styleLabel(for: prizeMoneyLabel, fontStyle: .display2, textColor: .black)
        prizeMoneyLabel.flex.display(.flex)
        
        // 대략적인 당첨금액 표시
        let approximateAmount = formatApproximatePrize(amount: prizeAmount, rank: result.rank)
        approximatePrizeLabel.text = approximateAmount
        styleLabel(for: approximatePrizeLabel, fontStyle: .headline2, textColor: .gray100)
        approximatePrizeLabel.flex.display(.flex)
        
        descriptionLabel.text = "당첨금 수령 방법은 가이드를 확인해 주세요"
        styleLabel(for: descriptionLabel, fontStyle: .body1, textColor: .gray110)
        descriptionLabel.flex.display(.flex)
        
        notWinningBodyLabel.flex.display(.none)
        
        // 레이아웃 업데이트
        rootFlexContainer.flex.layout()
    }
    
    // 미당첨 UI 표시
    private func showNotWinningUI() {
        illustrationImageView.image = UIImage(named: "ch_notWinning")
        illustrationImageView.flex.height(UIScreen.main.bounds.width / 1.7857)
        titleLabel.text = "아쉽게 미당첨"
        styleLabel(for: titleLabel, fontStyle: .title2, textColor: .black)
        notWinningBodyLabel.text = "다음 기회엔 꼭 당첨되기를 바라요!"
        styleLabel(for: notWinningBodyLabel, fontStyle: .headline1, textColor: .gray110)
        notWinningBodyLabel.flex.display(.flex)
        
        prizeMoneyLabel.flex.display(.none)
        approximatePrizeLabel.flex.display(.none)
        descriptionLabel.flex.display(.none)
        
        // 버튼 텍스트를 "확인"으로 변경
        confirmButton.setTitle("확인", for: .normal)
        isLastResult = true  // 미당첨은 항상 마지막 결과로 취급
        
        // 레이아웃 업데이트
        rootFlexContainer.flex.layout()
    }
    
    // 기존 populateWithResults 메소드 대체 (호출되지 않도록 함)
    private func populateWithResults() {
        // 이 메소드는 더 이상 사용하지 않음
        // 대신 populateWithCurrentResult를 사용
    }
}

// MARK: - Banner Navigation Delegate
extension LottoWinningResultVC: BannerNavigationDelegate {
    private func setupBanner() {
        // 당첨 여부 확인 (rank가 1~5인 경우 당첨)
        let hasWinning = winningResults.contains { result in
            if let rank = result.rank, rank >= 1 && rank <= 5 {
                return true
            }
            return false
        }

        // 당첨된 경우에는 .winnerGuide, 미당첨된 경우에는 .winningStore 노출
        let bannerType: BannerType = hasWinning ? .winnerGuide : .winningStore
        let banner = BannerManager.shared.createBanner(type: bannerType, navigationDelegate: self)
        self.bannerContainerView.flex.addItem(banner)
    }
    
    func navigate(to bannerType: BannerType) {
        switch bannerType {
        case .winningStore:
            showMapViewController()

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
            showQrScanner()

        case .winnerGuide:
            showWinnerGuide()
        }
    }

    func showMapViewController() {
        // 현재 뷰 컨트롤러를 닫고, 지도 탭으로 이동
        // dismiss 전에 rootViewController를 미리 캡처
        guard let window = WindowManager.findKeyWindow(),
              let navigationController = window.rootViewController as? UINavigationController,
              let tabBarController = navigationController.viewControllers.first as? UITabBarController else {
            dismissAll()
            return
        }

        // dismissCompletion을 임시로 저장
        let originalCompletion = dismissCompletion

        // dismiss 완료 후 지도 탭으로 이동하도록 completion 설정
        dismissCompletion = {
            tabBarController.selectedIndex = 1
            // 원래의 completion도 호출
            originalCompletion?()
        }

        dismissAll()
    }

    func showWinningReviewDetail(reviewNo: Int) {
        let detailVC = NativeWinningReviewDetailViewController(reviewNo: reviewNo)

        if let window = WindowManager.findKeyWindow(),
           let navigationController = window.rootViewController as? UINavigationController,
           let tabBarController = navigationController.viewControllers.first as? UITabBarController,
           let selectedNav = tabBarController.selectedViewController as? UINavigationController {
            selectedNav.pushViewController(detailVC, animated: true)
        }
    }

    func showStorageRandomNumbersView() {
        if let window = WindowManager.findKeyWindow(),
           let navigationController = window.rootViewController as? UINavigationController,
           let tabBarController = navigationController.viewControllers.first as? UITabBarController {
            tabBarController.selectedIndex = 2

            if let storageViewController = tabBarController.viewControllers?[2] as? StorageViewController {
                storageViewController.reactor.action.onNext(.didSelectrandomNumber)
            }
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

    func showQrScanner() {
        if let window = WindowManager.findKeyWindow(),
           let rootViewController = window.rootViewController {
            let frameView = QrScannerOverlayView()
            Task {
                QRScannerManager.shared.presentScanner(
                    from: rootViewController,
                    with: frameView
                )
            }
        }
    }

    func showWinnerGuide() {
        let winnerGuideVC = WinnerGuideVC()
        if let window = WindowManager.findKeyWindow(),
           let rootViewController = window.rootViewController {
            winnerGuideVC.view.frame = window.bounds
            
            rootViewController.addChild(winnerGuideVC)
            rootViewController.view.addSubview(winnerGuideVC.view)
            
            // Start off-screen to the right
            winnerGuideVC.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
            
            // Animate in from the right
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                winnerGuideVC.view.transform = .identity
            } completion: { _ in
                winnerGuideVC.didMove(toParent: rootViewController)
            }
            
            // Set the status bar background color to match the nav bar
            winnerGuideVC.changeStatusBarBgColor(bgColor: .commonNavBar)
        }
    }
}

// 안전한 배열 접근을 위한 확장
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
