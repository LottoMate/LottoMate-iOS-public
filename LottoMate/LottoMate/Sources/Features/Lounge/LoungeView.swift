//
//  LoungeView.swift
//  LottoMate
//
//  Created by Mirae on 11/18/24.
//

import UIKit
import PinLayout
import FlexLayout

class LoungeView: UIView {
    private let viewModel = LottoMateViewModel.shared
    
    fileprivate let rootFlexContainer = UIView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let topMargin: CGFloat = {
        let topMargin = DeviceMetrics.navigationBarHeight
        return topMargin
    }()
    
    // Modified calculation methods to handle the announcement day
    private func calculateDaysUntilNextLotto() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        
        // If today is Saturday (7), return 0 to indicate it's the announcement day
        if weekday == 7 {
            return 0
        }
        
        let daysUntilSaturday = ((7 - weekday) + 7) % 7
        return daysUntilSaturday == 0 ? 7 : daysUntilSaturday
    }
    
    private func calculateDaysUntilNextPension() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        
        // If today is Wednesday (4), return 0 to indicate it's the announcement day
        if weekday == 4 {
            return 0
        }
        
        let daysUntilWednesday = ((4 - weekday) + 7) % 7
        return daysUntilWednesday == 0 ? 7 : daysUntilWednesday
    }
    
    private lazy var lottoDrawCountdownLabel: UILabel = {
        let label = UILabel()
        let daysUntilLotto = calculateDaysUntilNextLotto()
        
        // Check if today is Lotto announcement day
        if daysUntilLotto == 0 {
            let fullText = "로또 당첨 발표는 오늘이에요!"
            let attributedString = NSMutableAttributedString(
                string: fullText,
                attributes: [
                    .font: Typography.body1.font(),
                    .foregroundColor: UIColor.black
                ]
            )
            
            if let range = fullText.range(of: "오늘") {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttributes([
                    .foregroundColor: UIColor.red50Default,
                    .font: Typography.headline2.font()
                ], range: nsRange)
            }
            label.attributedText = attributedString
            
        } else {
            let fullText = "로또 당첨 발표까지 \(daysUntilLotto)일 남았어요."
            let attributedString = NSMutableAttributedString(
                string: fullText,
                attributes: [
                    .font: Typography.body1.font(),
                    .foregroundColor: UIColor.black
                ]
            )
            
            let dayString = "\(daysUntilLotto)일"
            if let range = fullText.range(of: dayString) {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttributes([
                    .foregroundColor: UIColor.blue50Default,
                    .font: Typography.headline2.font()
                ], range: nsRange)
            }
            label.attributedText = attributedString
        }
        
        return label
    }()
    
    private lazy var pensionLotteryDrawCountdownLabel: UILabel = {
        let label = UILabel()
        let daysUntilPension = calculateDaysUntilNextPension()
        
        // Check if today is Pension Lottery announcement day
        if daysUntilPension == 0 {
            let fullText = "연금복권 당첨 발표는 오늘이에요!"
            let attributedString = NSMutableAttributedString(
                string: fullText,
                attributes: [
                    .font: Typography.body1.font(),
                    .foregroundColor: UIColor.black
                ]
            )
            
            if let range = fullText.range(of: "오늘") {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttributes([
                    .foregroundColor: UIColor.red50Default,
                    .font: Typography.headline2.font()
                ], range: nsRange)
            }
            label.attributedText = attributedString
        } else {
            let fullText = "연금복권 당첨 발표까지 \(daysUntilPension)일 남았어요."
            let attributedString = NSMutableAttributedString(
                string: fullText,
                attributes: [
                    .font: Typography.body1.font(),
                    .foregroundColor: UIColor.black
                ]
            )
            
            let dayString = "\(daysUntilPension)일"
            if let range = fullText.range(of: dayString) {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttributes([
                    .foregroundColor: UIColor.blue50Default,
                    .font: Typography.headline2.font()
                ], range: nsRange)
            }
            label.attributedText = attributedString
        }
        
        return label
    }()
    
    private lazy var drawCountdownView: UIView = {
        let view = UIView()
        
        let lottoIcon = UIImageView()
        let lottoImage = UIImage(named: "icon_lotto")
        lottoIcon.image = lottoImage
        lottoIcon.contentMode = .scaleAspectFit
        
        let pensionLotteryIcon = UIImageView()
        let pensionLotteryImage = UIImage(named: "icon_pensionLottery")
        pensionLotteryIcon.image = pensionLotteryImage
        pensionLotteryIcon.contentMode = .scaleAspectFit
        
        view.flex.direction(.column).gap(8).define { flex in
            flex.addItem().direction(.row).gap(6).define { flex in
                flex.addItem(lottoIcon)
                    .size(24)
                flex.addItem(lottoDrawCountdownLabel)
            }
            .grow(1)
            
            flex.addItem().direction(.row).gap(6).define { flex in
                flex.addItem(pensionLotteryIcon)
                    .size(24)
                flex.addItem(pensionLotteryDrawCountdownLabel)
            }
            .grow(1)
        }
        .padding(20)
        .backgroundColor(.gray10)
        .cornerRadius(16)
        
        return view
    }()
    
    private let showPrizeHistoryButton: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = "역대 당첨금 확인하기"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray100)
        
        let rightArrowIcon = UIImageView()
        let image = UIImage(named: "icon_arrow_right_in_button")
        rightArrowIcon.image = image
        rightArrowIcon.contentMode = .scaleAspectFit
        
        view.flex.direction(.row).gap(4).alignItems(.center).define { flex in
            flex.addItem(label)
            flex.addItem(rightArrowIcon)
                .size(14)
            
        }
        return view
    }()
    
    private let winnerInterviewLabels: UIView = {
        let view = UIView()
        
        let subTitleLabel: UILabel = {
            let label = UILabel()
            label.text = "로또 당첨자 인터뷰"
            styleLabel(for: label, fontStyle: .body1, textColor: .gray100)
            return label
        }()
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "로또 1등 기 받아가요"
            styleLabel(for: label, fontStyle: .title3, textColor: .black)
            return label
        }()
        
        view.flex.direction(.column).gap(2).alignItems(.start).define { flex in
            flex.addItem(subTitleLabel)
            flex.addItem(titleLabel)
        }
        
        return view
    }()
    
    private let horizontalReviewCards = WinningReviewListView()
    
    private let winnerGuideLabels: UIView = {
        let view = UIView()
        
        let subTitleLabel: UILabel = {
            let label = UILabel()
            label.text = "로또 당첨자 가이드"
            styleLabel(for: label, fontStyle: .body1, textColor: .gray100)
            return label
        }()
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "내가 당첨이 됐다면?"
            styleLabel(for: label, fontStyle: .title3, textColor: .black)
            return label
        }()
        
        view.flex.direction(.column).gap(2).alignItems(.start).define { flex in
            flex.addItem(subTitleLabel)
            flex.addItem(titleLabel)
        }
        
        return view
    }()
    
    private let howToClaimCardsListView = WinnerGuideCardsListView(cardType: .howToClaim)
    
    private let moreWinnerGuideButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue5
        view.layer.cornerRadius = 12
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = .blue10
        iconContainer.layer.cornerRadius = 22
        
        let rightArrowIcon: UIImageView = {
            let imageView = UIImageView()
            let image = UIImage(named: "icon_arrow_right_svg")
            imageView.image = image
            imageView.tintColor = .blue30
            return imageView
        }()
        
        let titleLabel = UILabel()
        titleLabel.text = "다른 복권들은 어떻게 할까?"
        titleLabel.numberOfLines = 1
        styleLabel(for: titleLabel, fontStyle: .body1, textColor: .black)
        
        let bodyLabel = UILabel()
        bodyLabel.text = "다른 복권들은 어떻게 할까?"
        bodyLabel.numberOfLines = 1
        styleLabel(for: bodyLabel, fontStyle: .label1, textColor: .gray100)
        
        view.flex
            .direction(.column)
            .gap(16)
            .justifyContent(.center)
            .alignItems(.center)
            .paddingVertical(39)
            .paddingHorizontal(20)
            .grow(1)
            .define { flex in
                // 화살표
                flex.addItem(iconContainer)
                    .size(44)
                    .justifyContent(.center)
                    .alignItems(.center)
                    .define { container in
                        container.addItem(rightArrowIcon)
                            .size(24)
                    }
                
                // 텍스트
                flex.addItem()
                    .direction(.column)
                    .gap(2)
                    .define { labels in
                        labels.addItem(titleLabel)
                        labels.addItem(bodyLabel)
                    }
                
            }
        
        return view
    }()
    
    private func configureLottoCardListViews() {
        // 로또 - 당첨금 받는 방법 카드 데이터
        let howToClaimData: [(number: Int, description: String, detailDescriptions: [String])] = [
            (1, "NH농협에서 당첨된 복권과 함께\n신분증으로 당첨자를 확인해요", []),
            (2, "모두 확인이 되면,\r당첨금을 받게 돼요", []),
            (3, "당첨금은 일시불로 지불되며\r요청 시 현금으로 받을수도 있어요", [])
        ]
        
        howToClaimCardsListView.configure(with: howToClaimData)
    }
    
    private func setupActions() {
        // moreWinnerGuideButton 표시 및 탭 동작 설정
        howToClaimCardsListView.setShowMoreButton(true) // 조건에 따라 true/false 설정
        howToClaimCardsListView.onMoreButtonTapped = { [weak self] in
            self?.showWinnerGuide()
        }
        
        // showPrizeHistoryButton 탭 동작 설정
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePrizeHistoryButtonTap))
        showPrizeHistoryButton.addGestureRecognizer(tapGesture)
        showPrizeHistoryButton.isUserInteractionEnabled = true
    }
    
    private func setupWinningReviewDelegate() {
        horizontalReviewCards.delegate = self
    }
    
    @objc private func handlePrizeHistoryButtonTap() {
        viewModel.selectedLotteryType.onNext(.lotto)
        showLottoWinningInfoView()
    }
    
    private func showLottoWinningInfoView() {
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
    
    private let bannerContainer = UIView()

//    private let voteView = VoteView()
    
//    private let pastVoteLabels: UIView = {
//        let view = UIView()
//        
//        let titleLabel: UILabel = {
//            let label = UILabel()
//            label.text = "지난 투표"
//            styleLabel(for: label, fontStyle: .headline1, textColor: .black)
//            return label
//        }()
//        let subTitleLabel: UILabel = {
//            let label = UILabel()
//            label.text = "내가 참여한 메이트 투표를 확인할 수 있어요."
//            styleLabel(for: label, fontStyle: .label2, textColor: .gray80)
//            return label
//        }()
//        
//        view.flex.direction(.column).alignItems(.start).define { flex in
//            flex.addItem(titleLabel)
//            flex.addItem(subTitleLabel)
//        }
//        return view
//    }()
    
//    private let emptyPastVoteView: UIView = {
//        let view = UIView()
//        let image = CommonImageView(imageName: "ch_noPastVoteView")
//        let label = UILabel()
//        label.text = "지난 투표 중 내가 참여한 투표가 없습니다"
//        styleLabel(for: label, fontStyle: .body2, textColor: .gray100)
//        
//        view.flex.direction(.column)
//            .gap(8)
//            .paddingVertical(56)
//            .backgroundColor(.gray10)
//            .define { flex in
//                flex.addItem(image)
//                    .width(158)
//                    .height(100)
//                    .alignSelf(.center)
//                flex.addItem(label)
//            }
//        return view
//    }()
    
//    private let signInRequiredPastVoteView: UIView = {
//        let view = UIView()
//        let image = CommonImageView(imageName: "ch_pastVoteView_login")
//        let label = UILabel()
//        label.text = "로그인 후 참여한 투표 이력을 확인하세요."
//        styleLabel(for: label, fontStyle: .body2, textColor: .gray100)
//        let button = StyledButton(title: "로그인하기", buttonStyle: .solid(.round, .active), cornerRadius: 19, verticalPadding: 8, horizontalPadding: 16)
//        
//        view.flex.direction(.column)
//            .paddingVertical(56)
//            .backgroundColor(.gray10)
//            .define { flex in
//                flex.addItem(image)
//                    .width(158)
//                    .height(100)
//                    .alignSelf(.center)
//                flex.addItem(label)
//                    .marginTop(8)
//                flex.addItem(button)
//                    .marginTop(16)
//                    .marginHorizontal(142)
//            }
//        return view
//    }()
    
//    let pastVoteHorizontalScrollView = PastVoteHorizontalScrollView()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
        configureLottoCardListViews()
        setupBanner()
        setupActions()
        setupWinningReviewDelegate()
    }
    
    private func setupLayout() {
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
        
        // 카드 높이 계산
        let screenWidth = UIScreen.main.bounds.width
        let cardWidth = screenWidth / 1.4423
        let cardHeight = cardWidth * (186 / 260)
        
        rootFlexContainer.flex
            .direction(.column)
            .paddingTop(topMargin)
            .define { flex in
                flex.addItem(drawCountdownView)
                    .marginTop(20)
                    .marginHorizontal(20)
                
                flex.addItem(showPrizeHistoryButton)
                    .alignSelf(.end)
                    .marginTop(8)
                    .marginBottom(48)
                    .marginHorizontal(20)
                
                flex.addItem(winnerInterviewLabels)
                    .marginLeft(20)
                
                flex.addItem(horizontalReviewCards)
                    .width(100%)
                    .height(248) // small size 카드 높이 202 + dot indicator 높이 6 + padding 40 = 248
                
                flex.addItem(winnerGuideLabels)
                    .marginLeft(20)
                    .marginTop(17)
                
                flex.addItem(howToClaimCardsListView)
                    .height(cardHeight + 40)
                    .width(100%)
                    .marginBottom(34)
                
                flex.addItem(bannerContainer)
                    .width(UIScreen.main.bounds.width - 40)
                    .height(100)
                    .alignSelf(.center)
                    .marginBottom(40)
                
                
//                flex.addItem(banner)
//                    .marginTop(36)
//                    .marginHorizontal(20)
//                flex.addItem(voteView)
//                    .marginTop(52)
//                flex.addItem(pastVoteLabels)
//                    .marginLeft(20)
//                    .marginTop(40)
                // 로그인 상태 - 투표 기록 있을 경우
//                flex.addItem(pastVoteHorizontalScrollView)
//                    .width(100%)
//                    .height(326)
                // 로그인 상태 - 투표 기록 없을 경우
//                flex.addItem(emptyPastVoteView)
//                    .width(100%)
//                    .marginTop(20)
//                    .marginBottom(49)
                // 비로그인 상태
//                flex.addItem(signInRequiredPastVoteView)
//                    .width(100%)
//                    .marginTop(20)
//                    .marginBottom(49)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.all()
        rootFlexContainer.pin.top().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
    }
}

extension LoungeView: BannerNavigationDelegate {
    private func setupBanner() {
        let banner = BannerManager.shared.createBanner(type: .qrCodeScanner, navigationDelegate: self)
        self.bannerContainer.flex.addItem(banner)
    }
    
    func navigate(to bannerType: BannerType) {
        switch bannerType {
        case .qrCodeScanner:
            showQrScanner()
        default:
            break
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
    
    private func showWinningReviewDetail(reviewNo: Int) {
        print("🎯 LoungeView: Showing review detail for reviewNo: \(reviewNo)")
        
        let detailVC = NativeWinningReviewDetailViewController(reviewNo: reviewNo)
        
        // 현재 view의 view controller를 찾아서 navigation controller를 통해 push
        if let viewController = self.parentViewController {
            if let navigationController = viewController.navigationController {
                print("✅ LoungeView: Pushing detail view via navigation controller")
                navigationController.pushViewController(detailVC, animated: true)
            } else {
                print("⚠️ LoungeView: No navigation controller found, attempting to find from window")
                // Navigation controller가 없으면 window에서 찾기
                if let window = WindowManager.findKeyWindow(),
                   let rootViewController = window.rootViewController as? UITabBarController,
                   let selectedNav = rootViewController.selectedViewController as? UINavigationController {
                    print("✅ LoungeView: Found navigation controller from tab bar")
                    selectedNav.pushViewController(detailVC, animated: true)
                } else {
                    print("❌ LoungeView: Failed to find navigation controller")
                }
            }
        } else {
            print("❌ LoungeView: Failed to find view controller")
        }
    }
    
    // Helper property to find the view controller that owns this view
    private var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

extension LoungeView: WinningReviewListViewDelegate {
    func didTapReviewCard(with reviewNo: Int) {
        showWinningReviewDetail(reviewNo: reviewNo)
    }
}

#Preview {
    let view = LoungeView()
    return view
}
