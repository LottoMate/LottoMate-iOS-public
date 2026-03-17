//
//  HomeView.swift
//  LottoMate
//
//  Created by Mirae on 11/11/24.
//

import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import RxSwift
import RxGesture

class HomeView: UIView, View {
    fileprivate let rootFlexContainer = UIView()
    var disposeBag = DisposeBag()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        return scrollView
    }()
    
    private let topMargin: CGFloat = {
        let topMargin = DeviceMetrics.navigationBarHeight
        return topMargin
    }()
    
    private let tabBarHeight = DeviceMetrics.tabBarHeight
    
    let drawCountdownView = DrawCountdownView()
    
    private let myLotteryStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "내 로또 현황"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black, alignment: .left)
        return label
    }()
    
    private let lottoLeftArrowIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "icon_arrow_left_svg")
        imageView.image = image
        imageView.tintColor = .gray100
        return imageView
    }()
    
    let lottoRightArrowIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "icon_arrow_right_svg")
        imageView.image = image
        imageView.tintColor = .gray100
        return imageView
    }()
    
    let pensionLeftArrowIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "icon_arrow_left_svg")
        imageView.image = image
        imageView.tintColor = .gray100
        return imageView
    }()
    
    let pensionRightArrowIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "icon_arrow_right_svg")
        imageView.image = image
        imageView.tintColor = .gray100
        return imageView
    }()
    
    let speetoLeftArrowIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "icon_arrow_left_svg")
        imageView.image = image
        imageView.tintColor = .gray100
        return imageView
    }()
    
    let speetoRightArrowIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "icon_arrow_right_svg")
        imageView.image = image
        imageView.tintColor = .gray100
        return imageView
    }()
    
    private let thisWeekResultLabel = CommonHeadline1Label(text: "이번 주 당첨 결과")
    private let lottoDreamLabel = CommonHeadline1Label(text: "로또 당첨을 꿈꾼다면?")
    private let lotteryTypeButtonsView = SquereButtonForHome()
    
    private let thisWeekResultViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    private let thisWeekLottoResultView: UIView = {
        let view = UIView()
        return view
    }()
    private let thisWeekPensionLotteryResultView: UIView = {
        let view = UIView()
        return view
    }()
    private let thisWeekSpeetoResultView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var allResultViews: [UIView] {
        [
            thisWeekLottoResultView,
            thisWeekPensionLotteryResultView,
            thisWeekSpeetoResultView
        ]
    }
    
    let showLottoWinningInfoButton: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = "당첨 정보 보기"
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
    
    let showPensionWinningInfoButton: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = "당첨 정보 보기"
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
    
    let showSpeetoWinningInfoButton: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = "당첨 정보 보기"
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
    
    private let checkWinningView: UIView = {
        let view = UIView()
        let image = CommonImageView(imageName: "checkWinning")
        let subTitleLabel: UILabel = {
            let label = UILabel()
            label.text = "내 로또는 과연 몇 등일까?"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray100)
            return label
        }()
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "당첨 확인하기"
            styleLabel(for: label, fontStyle: .headline2, textColor: .black)
            return label
        }()
        
        view.flex.direction(.column).alignItems(.start).define { flex in
            flex.addItem(image)
                .marginBottom(8)
            flex.addItem(subTitleLabel)
            flex.addItem(titleLabel)
        }
        .paddingVertical(16)
        .paddingHorizontal(20)
        .backgroundColor(.white)
        .cornerRadius(16)
        
        view.addDropShadow()
        
        return view
    }()
    
    private let checkWinningStoreView: UIView = {
        let view = UIView()
        let image = CommonImageView(imageName: "mapMarker")
        let subTitleLabel: UILabel = {
            let label = UILabel()
            label.text = "로또 사러 어디로 가지?"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray100)
            return label
        }()
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "근처 명당 보기"
            styleLabel(for: label, fontStyle: .headline2, textColor: .black)
            return label
        }()
        
        view.flex.direction(.column).alignItems(.start).define { flex in
            flex.addItem(image)
                .marginBottom(8)
            flex.addItem(subTitleLabel)
            flex.addItem(titleLabel)
        }
        .paddingVertical(16)
        .paddingHorizontal(20)
        .backgroundColor(.white)
        .cornerRadius(16)
        
        view.addDropShadow()
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
    
    let horizontalReviewCards = WinningReviewListView(cardSize: .large)
    
    let bannerContainer = UIView()
    
    //    private let voteView = VoteView()
    
    private let warningView: UIView = {
        let view = UIView()
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "주의해주세요"
            styleLabel(for: label, fontStyle: .headline2, textColor: .gray100, alignment: .left)
            return label
        }()
        
        let warningTextArray = [
            " •  19세 미만은 로또를 구매할 수 없어요",
            " •  1인당 1회 10만원만 구매할 수 있어요",
            " •  모든 복권은 종류 상관 없이 현금으로만 구매할 수 있어요",
            " •  동행복권 및 스포츠 토토에서만 살 수 있어요"
        ]
        
        view.flex.direction(.column).define { flex in
            flex.addItem(titleLabel)
                .marginBottom(10)
            flex.addItem()
                .direction(.column)
                .gap(4)
                .alignItems(.start)
                .define { flex in
                    warningTextArray.forEach { text in
                        let warningText: UILabel = {
                            let label = UILabel()
                            label.text = text
                            label.numberOfLines = 2
                            styleLabel(for: label, fontStyle: .label1, textColor: .gray100, alignment: .left)
                            return label
                        }()
                        flex.addItem(warningText)
                    }
                }
        }
        .padding(20)
        .backgroundColor(.gray10)
        .cornerRadius(16)
        .grow(1)
        
        return view
    }()
    
    // MARK: Footer 관련 버튼 뷰
    
    private let noticeButton: UILabel = {
        let label = UILabel()
        label.text = "공지사항"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
        return label
    }()
    
    private let privacyPolicyButton: UILabel = {
        let label = UILabel()
        label.text = "개인정보 처리방침"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
        return label
    }()
    
    private let locationServiceTermsButton: UILabel = {
        let label = UILabel()
        label.text = "위치기반 서비스 이용약관"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
        return label
    }()
    
    private let updateButton: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "업데이트"
        styleLabel(for: label, fontStyle: .caption1, textColor: .blue50Default)
        
        view.flex
            .direction(.column)
            .define { flex in
                flex.addItem(label)
                flex.addItem()
                    .height(1)
                    .width(100%)
                    .backgroundColor(.blue50Default)
            }
        
        return view
    }()
    
    private lazy var versionInfoView: UIView = {
        let view = UIView()
        
        /// 실제 앱의 버전 정보
        var appVersion: String {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
            return "\(version)"
        }
        
        // 버전 정보 레이블
        let versionInfoLabel = UILabel()
        versionInfoLabel.text = "버전정보 \(appVersion)"
        styleLabel(for: versionInfoLabel, fontStyle: .caption1, textColor: .gray80)
        
        // 업데이트 타입 확인
        let updateType = UpdateCheckService.shared.getCurrentUpdateType()
        
        view.flex
            .direction(.row)
            .gap(6)
            .alignItems(.center)
            .define { flex in
                flex.addItem(versionInfoLabel)
                
                // 선택적 업데이트가 있는 경우에만 노출
                if updateType == .recommended {
                    flex.addItem(updateButton)
                }
            }
        
        
        return view
    }()
    
    private let askButton: UILabel = {
        let label = UILabel()
        label.text = "문의하기"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
        return label
    }()
    
    private let emailButton: UILabel = {
        let label = UILabel()
        label.text = "Lottomate@gmail.com"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
        return label
    }()
    
    private let copyrightButton: UILabel = {
        let label = UILabel()
        label.text = "@ LottoMate All right reserved"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
        return label
    }()
    
    private func createBarLabel() -> UILabel {
        let label = UILabel()
        label.text = "|"
        styleLabel(for: label, fontStyle: .caption2, textColor: .gray80)
        return label
    }
    
    private lazy var footerView: UIView = {
        let view = UIView()
        
        view.flex
            .direction(.column)
            .backgroundColor(.white)
            .define { flex in
                flex.addItem()
                    .width(100%)
                    .backgroundColor(.gray20)
                    .height(1)
                
                flex.addItem()
                    .direction(.column)
                    .paddingTop(24)
                    .paddingBottom(34)
                    .paddingLeft(20)
                    .alignItems(.start)
                    .gap(12)
                    .define { innerFlex in
//                        innerFlex.addItem()
//                            .direction(.row)
//                            .gap(11)
//                            .define { firstRow in
//                                firstRow.addItem(noticeButton)
//                                firstRow.addItem(createBarLabel())
//                                firstRow.addItem(privacyPolicyButton)
//                                firstRow.addItem(createBarLabel())
//                                firstRow.addItem(locationServiceTermsButton)
//                            }
                        
                        innerFlex.addItem()
                            .direction(.row)
                            .gap(11)
                            .define { secondRow in
                                secondRow.addItem(versionInfoView)
//                                secondRow.addItem(createBarLabel())
//                                secondRow.addItem(askButton)
                                secondRow.addItem(createBarLabel())
                                secondRow.addItem(emailButton)
                            }
                        
                        innerFlex.addItem(copyrightButton)
                    }
            }
        
        return view
    }()
    
    
    init() {
        super.init(frame: .zero)
        setupLayout()
        setupWinningReviewDelegate()
        setupActions()
    }
    
    private func setupLayout() {
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
        setupThisWeekResultContainer()
        
        let cardWidth = (UIScreen.main.bounds.width - 55) / 2
        
        rootFlexContainer.flex
            .direction(.column)
            .paddingTop(topMargin)
            .define { flex in
                flex.addItem(drawCountdownView)
                    .height(64)
                    .marginTop(20)
                    .marginBottom(36)
                    .marginHorizontal(20)
                flex.addItem(thisWeekResultLabel)
                    .alignSelf(.start)
                    .marginLeft(20)
                    .marginBottom(6)
                flex.addItem(lotteryTypeButtonsView)
                flex.addItem(thisWeekResultViewContainer)
                    .grow(1)
                flex.addItem(lottoDreamLabel)
                    .marginTop(48)
                    .alignSelf(.start)
                    .marginLeft(20)
                flex.addItem()
                    .direction(.row)
                    .gap(15)
                    .define { flex in
                        flex.addItem(checkWinningStoreView)
                            .width(cardWidth)
                        flex.addItem(checkWinningView)
                            .width(cardWidth)
                    }
                    .paddingHorizontal(20)
                    .marginTop(16)
                flex.addItem(winnerInterviewLabels)
                    .marginTop(48)
                    .marginLeft(20)
                flex.addItem(horizontalReviewCards)
                    .width(100%)
                    .height(324) // large size 카드의 높이 278 + dot indicator의 높이 6 + padding 40 = 324
                flex.addItem(bannerContainer)
                    .marginTop(48)
                    .marginHorizontal(20)
                    .height(100)
                //                flex.addItem(voteView)
                //                    .marginTop(48)
                flex.addItem(warningView)
                    .marginTop(36)
                    .marginBottom(36)
                    .marginHorizontal(20)
                
                // 푸터
                flex.addItem(footerView)
            }
    }
    
    private func setupThisWeekResultContainer() {
        thisWeekResultViewContainer.flex.define { flex in
            flex.addItem(thisWeekLottoResultView)
                .grow(1)
            flex.addItem(thisWeekPensionLotteryResultView)
                .grow(1)
                .isIncludedInLayout(false)
            flex.addItem(thisWeekSpeetoResultView)
                .grow(1)
                .isIncludedInLayout(false)
        }
        
        updateThisWeekResultView(for: .lotto)
    }
    
    private func refreshLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func visibleResultView(for type: LotteryType) -> UIView {
        switch type {
        case .lotto:
            return thisWeekLottoResultView
        case .pensionLottery:
            return thisWeekPensionLotteryResultView
        case .speeto:
            return thisWeekSpeetoResultView
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

extension HomeView {
    func bind(reactor: HomeViewReactor) {
        
        lotteryTypeButtonsView.reactor = reactor
        
        reactor.state
            .map { $0.selectedLotteryType }
            .subscribe(onNext: { [weak self] type in
                self?.updateThisWeekResultView(for: type)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.latestLotteryResult }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind { [weak self] result in
                self?.setUpThisWeekLottoResultView(for: result)
                self?.setUpThisWeekPensionLotteryView(for: result)
                self?.setUpThisWeekSpeetoResultView() // 데이터 연동 후 파라미터 추가 필요
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.lottoRoundResult }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                let lottoData = result.lottoResult
                self?.setUpThisWeekLottoResultView(for: lottoData)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.pensionRoundResult }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                let pensionData = result.pensionLotteryResult
                self?.setUpThisWeekPensionLotteryView(for: pensionData)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLottoRightArrowIconHidden }
            .distinctUntilChanged()
            .bind(to: lottoRightArrowIcon.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isPensionRightArrowIconHidden }
            .distinctUntilChanged()
            .bind(to: pensionRightArrowIcon.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isSpeetoRightArrowIconHidden }
            .distinctUntilChanged()
            .bind(to: speetoRightArrowIcon.rx.isHidden)
            .disposed(by: disposeBag)
        
        lottoLeftArrowIcon.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.fetchPreviousLottoRound }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        lottoRightArrowIcon.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.fetchNextLottoRound }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pensionLeftArrowIcon.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.fetchPreviousPensionRound }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pensionRightArrowIcon.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.fetchNextPensionRound }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        showLottoWinningInfoButton.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.showWinningInfo(.lotto) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        showPensionWinningInfoButton.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.showWinningInfo(.pensionLottery) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        showSpeetoWinningInfoButton.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.showWinningInfo(.speeto) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        checkWinningStoreView.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.showMapViewController }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        checkWinningView.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.checkWinningViewTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        noticeButton.rx.tapGesture()
            .when(.recognized)
            .map { _ in HomeViewReactor.Action.noticeButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func updateThisWeekResultView(for type: LotteryType) {
        let targetView = visibleResultView(for: type)
        
        allResultViews.forEach { resultView in
            let isVisible = resultView === targetView
            resultView.isHidden = !isVisible
            resultView.flex.isIncludedInLayout(isVisible)
        }
        
        refreshLayout()
    }
    
    func setUpThisWeekLottoResultView(for result: LottoResultType) {
        thisWeekLottoResultView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        let components = HomeLottoResultComponentsBuilder.build(
            result: result,
            owner: self,
            winningInfoButton: showLottoWinningInfoButton
        )

        // MARK: Layout Views
        thisWeekLottoResultView.flex.direction(.column).define { flex in
            flex.addItem(components.mainContainer).direction(.column).define { flex in
                flex.addItem(components.resultRoundBadge)
                    .paddingHorizontal(12)
                    .paddingVertical(4)
                    .backgroundColor(.gray10)
                    .cornerRadius(8)
                    .marginTop(32)
                    .marginHorizontal(81.5)
                
                flex.addItem(components.prizeMoneyLabel)
                    .marginTop(12)
                flex.addItem(components.prizeMoneyPerWinnerInfoLabel)
                flex.addItem(components.winningNumberBalls)
                    .marginTop(12)
                    .alignSelf(.center)
                
                flex.addItem(lottoLeftArrowIcon)
                    .size(24)
                    .position(.absolute)
                    .start(13)
                    .marginTop(100)
                
                flex.addItem(lottoRightArrowIcon)
                    .size(24)
                    .position(.absolute)
                    .end(13)
                    .marginTop(100)
            }
            flex.addItem(components.winningInfoFooter)
                .paddingVertical(16)
                .paddingHorizontal(20)
                .backgroundColor(.gray10)
                .cornerRadius(8)
                .marginTop(32)
                .marginHorizontal(20)
        }
        refreshLayout()
    }
    
    func setUpThisWeekPensionLotteryView(for result: PensionResultType) {
        thisWeekPensionLotteryResultView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        let data = result
        let resultRoundBadge = HomeResultViewFactory.makeResultRoundBadge(
            roundText: "\(data.pensionDrwNum)회 1등 당첨금",
            dateText: "\(data.pensionDrwDate.reformatDate) 추첨"
        )
        let winningInfoFooter = HomeResultViewFactory.makeWinningInfoFooter(
            guideText: "💸 2등은 당첨금이 얼마일까?",
            buttonView: showPensionWinningInfoButton
        )
        
        let mainContainer: UIView = {
            let view = UIView()
            return view
        }()
        let prizeMoneyLabel: UILabel = {
            let label = UILabel()
            label.text = "20년 x 월 700만원"
            styleLabel(for: label, fontStyle: .title2, textColor: .black)
            return label
        }()
        let prizeMoneyPerWinnerInfoLabel = HomeResultViewFactory.makeHighlightedInfoLabel(
            text: "당첨자는 20년 동안 매월 700만원 씩 받아요",
            highlights: ["20년", "매월 700만원"]
        )
        let winningNumberBalls = HomeResultViewFactory.makePensionWinningNumberBalls(owner: self, numbers: data.pensionNum)
        // MARK: Layout Views
        thisWeekPensionLotteryResultView.flex.direction(.column).define { flex in
            flex.addItem(mainContainer).direction(.column).define { flex in
                flex.addItem(resultRoundBadge)
                    .paddingHorizontal(12)
                    .paddingVertical(4)
                    .backgroundColor(.gray10)
                    .cornerRadius(8)
                    .marginTop(32)
                    .marginHorizontal(81.5)
                
                flex.addItem(prizeMoneyLabel)
                    .marginTop(12)
                flex.addItem(prizeMoneyPerWinnerInfoLabel)
                    .marginTop(4)
                flex.addItem(winningNumberBalls)
                    .alignSelf(.center)
                    .marginTop(16)
                
                flex.addItem(pensionLeftArrowIcon)
                    .size(24)
                    .position(.absolute)
                    .start(13)
                    .marginTop(100)
                
                flex.addItem(pensionRightArrowIcon)
                    .size(24)
                    .position(.absolute)
                    .end(13)
                    .marginTop(100)
            }
            flex.addItem(winningInfoFooter)
                .paddingVertical(16)
                .paddingHorizontal(20)
                .backgroundColor(.gray10)
                .cornerRadius(8)
                .marginTop(32)
                .marginHorizontal(20)
        }
        refreshLayout()
    }
    
    //    func setUpThisWeekSpeetoResultView(for result: SpeetoResultType) {
    func setUpThisWeekSpeetoResultView() {
        let resultRoundBadge = HomeResultViewFactory.makeResultRoundBadge(
            roundText: "54회 1등 당첨금",
            dateText: "2024.06.29 스피또 2000 기준",
            roundTextColor: .black,
            dateTextColor: .gray100,
            axis: .column
        )
        let winningInfoFooter = HomeResultViewFactory.makeWinningInfoFooter(
            guideText: "💸 2등은 당첨금이 얼마일까?",
            buttonView: showSpeetoWinningInfoButton
        )
        
        let mainContainer: UIView = {
            let view = UIView()
            return view
        }()
        let prizeMoneyLabel: UILabel = {
            let label = UILabel()
            label.text = "10억원"
            styleLabel(for: label, fontStyle: .title1, textColor: .black)
            return label
        }()
        let remainingWinningChancesLabel = HomeResultViewFactory.makeHighlightedInfoLabel(
            text: "1등 복권 6장 남았어요",
            highlights: ["6장"]
        )
        let lotteryReleaseRate: UILabel = {
            let label = UILabel()
            label.text = "현재까지 출고율"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray100)
            return label
        }()
        let realseRate: UILabel = {
            let label = UILabel()
            label.text = "72%"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray100)
            return label
        }()
        let firstPrizeRemaining: UILabel = {
            let label = UILabel()
            let remainingCount = 0
            let totalCount = 6
            label.text = "1등 : \(remainingCount)/\(totalCount)"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
            return label
        }()
        let secondPrizeRemaining: UILabel = {
            let label = UILabel()
            let remainingCount = 11
            let totalCount = 18
            label.text = "2등 : \(remainingCount)/\(totalCount)"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
            return label
        }()
        let thirdPrizeRemaining: UILabel = {
            let label = UILabel()
            let remainingCount = 102
            let totalCount = 150
            label.text = "3등 : \(remainingCount)/\(totalCount)"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
            return label
        }()
        let separatorLabel1: UILabel = {
            let label = UILabel()
            label.text = "|"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray40)
            return label
        }()
        let separatorLabel2: UILabel = {
            let label = UILabel()
            label.text = "|"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray40)
            return label
        }()
        
        thisWeekSpeetoResultView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        thisWeekSpeetoResultView.flex.direction(.column).define { flex in
            flex.addItem(mainContainer).direction(.column).define { flex in
                // 상단 회차 정보
                flex.addItem(resultRoundBadge)
                    .paddingVertical(8)
                    .paddingHorizontal(20)
                    .backgroundColor(.gray10)
                    .cornerRadius(8)
                    .marginTop(32)
                    .alignSelf(.center)
                
                // 당첨금과 남은 복권 정보
                flex.addItem(prizeMoneyLabel)
                    .marginTop(12)
                
                // 1등 복권 6장 남았어요
                flex.addItem(remainingWinningChancesLabel)
                    .marginTop(4)
                
                // 출고율 정보 컨테이너
                flex.addItem()
                    .direction(.row)
                    .alignSelf(.center)
                    .gap(4)
                    .define { flex in
                        flex.addItem(lotteryReleaseRate)
                        flex.addItem(realseRate)
                    }
                
                flex.addItem()
                    .direction(.row)
                    .gap(8)
                    .alignSelf(.center)
                    .marginTop(12)
                    .define { flex in
                        flex.addItem(firstPrizeRemaining)
                        flex.addItem(separatorLabel1)
                        flex.addItem(secondPrizeRemaining)
                        flex.addItem(separatorLabel2)
                        flex.addItem(thirdPrizeRemaining)
                    }
                
                
                // 좌우 화살표 아이콘
                flex.addItem(speetoLeftArrowIcon)
                    .size(24)
                    .position(.absolute)
                    .start(13)
                    .marginTop(100)
                
                flex.addItem(speetoRightArrowIcon)
                    .size(24)
                    .position(.absolute)
                    .end(13)
                    .marginTop(100)
            }
            
            // 하단 당첨 정보 버튼
            flex.addItem(winningInfoFooter)
                .paddingVertical(16)
                .paddingHorizontal(20)
                .backgroundColor(.gray10)
                .cornerRadius(8)
                .marginTop(32)
                .marginHorizontal(20)
        }
        
        refreshLayout()
    }
}

extension HomeView {
    private func showWinningReviewDetail(reviewNo: Int) {
        print("🎯 HomeView: Showing review detail for reviewNo: \(reviewNo)")
        
        let detailVC = NativeWinningReviewDetailViewController(reviewNo: reviewNo)
        
        // 현재 view의 view controller를 찾아서 navigation controller를 통해 push
        if let viewController = self.parentViewController {
            if let navigationController = viewController.navigationController {
                print("✅ HomeView: Pushing detail view via navigation controller")
                navigationController.pushViewController(detailVC, animated: true)
            } else {
                print("⚠️ HomeView: No navigation controller found, attempting to find from window")
                // Navigation controller가 없으면 window에서 찾기
                if let window = WindowManager.findKeyWindow(),
                   let rootViewController = window.rootViewController as? UITabBarController,
                   let selectedNav = rootViewController.selectedViewController as? UINavigationController {
                    print("✅ HomeView: Found navigation controller from tab bar")
                    selectedNav.pushViewController(detailVC, animated: true)
                } else {
                    print("❌ HomeView: Failed to find navigation controller")
                }
            }
        } else {
            print("❌ HomeView: Failed to find view controller")
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
    
    private func setupWinningReviewDelegate() {
        self.horizontalReviewCards.delegate = self
    }
    
    private func setupActions() {
        // 업데이트 버튼 탭 제스처 추가
        updateButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                UpdateCheckService.shared.openAppStore()
            })
            .disposed(by: disposeBag)
    }
}

extension HomeView: WinningReviewListViewDelegate {
    func didTapReviewCard(with reviewNo: Int) {
        showWinningReviewDetail(reviewNo: reviewNo)
    }
}

#Preview {
    let view = HomeView()
    return view
}
