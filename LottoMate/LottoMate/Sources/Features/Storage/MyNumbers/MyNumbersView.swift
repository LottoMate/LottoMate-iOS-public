//
//  MyNumbersView.swift
//  LottoMate
//
//  Created by Mirae on 11/10/24.
//

import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import RxSwift
import RxGesture


class MyNumbersView: UIView, View {
    var disposeBag = DisposeBag()
    fileprivate let rootFlexContainer = UIView()
    
    private let scanButton = StyledButton(
        title: "QR 스캔하기",
        buttonStyle: .assistive(.small, .active),
        cornerRadius: 8,
        verticalPadding: 6,
        horizontalPadding: 16
    )
    
    private let addNumberButton = StyledButton(
        title: "번호 등록하기",
        buttonStyle: .assistive(.small, .active),
        cornerRadius: 8,
        verticalPadding: 6,
        horizontalPadding: 16
    )
    
    private lazy var qrScanCardView: UIView = {
        let view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "당첨 결과를\r빠르게 확인하려면?"
        titleLabel.numberOfLines = 2
        styleLabel(for: titleLabel, fontStyle: .headline2, textColor: .black)
        
        let characterImage = UIImageView()
        let image = UIImage(named: "ch_QRScan")
        characterImage.image = image
        characterImage.contentMode = .scaleAspectFit
        
        view.flex.direction(.column).gap(12).alignItems(.center).define { flex in
            flex.addItem(titleLabel)
            flex.addItem(characterImage)
                .size(70)
            flex.addItem(scanButton)
                .marginHorizontal(30)
        }
        .paddingVertical(20)
        .backgroundColor(.white)
        .cornerRadius(16)
        .grow(1)
        
        let shadowOffset = CGSize(width: 0, height: 0)
        view.addDropShadow()
        
        return view
    }()
    
    private lazy var saveMyNumbersCardView: UIView = {
        let view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "내 로또 번호를\r저장하려면?"
        titleLabel.numberOfLines = 2
        styleLabel(for: titleLabel, fontStyle: .headline2, textColor: .black)
        
        let characterImage = UIImageView()
        let image = UIImage(named: "ch_saveNumbers")
        characterImage.image = image
        characterImage.contentMode = .scaleAspectFit
        
        view.flex.direction(.column).gap(12).alignItems(.center).define { flex in
            flex.addItem(titleLabel)
            flex.addItem(characterImage)
                .size(70)
            flex.addItem(addNumberButton)
                .marginHorizontal(27.5)
        }
        .paddingVertical(20)
        .backgroundColor(.white)
        .cornerRadius(16)
        .grow(1)
        
        let shadowOffset = CGSize(width: 0, height: 0)
        view.addDropShadow()
        
        return view
    }()
    
    private let myLotteryStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "내 로또 현황"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black, alignment: .left)
        return label
    }()
    
    private var lotteryDashboardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // 저장된 복권 번호 개수
    private var mySavedLottoNumbers: Int = 0
    
    // NN 값이 변화하기 때문에 file 범위에 선언.
    private let availableResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "내 로또 NN 개" // attributedText로 변경 시 NN 스타일 다름.
        styleLabel(for: label, fontStyle: .headline1, textColor: .black)
        return label
    }()
    // NN 값이 변화하기 때문에 file 범위에 선언.
    private let pendingResultsLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.text = "내 로또 NN 개"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black)
        return label
    }()
    
    private lazy var resultReadyStatusCardView: UIView = {
        let view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "지금 바로\r당첨 확인 가능한"
        titleLabel.numberOfLines = 2
        styleLabel(for: titleLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        let myLottoLabel = UILabel()
        myLottoLabel.text = "내 로또"
        styleLabel(for: myLottoLabel, fontStyle: .label2, textColor: .black)
        
        let countLabel = UILabel()
        countLabel.text = "2"
        styleLabel(for: countLabel, fontStyle: .label2, textColor: .red50Default)
        
        let countSubLabel = UILabel()
        countSubLabel.text = "개"
        styleLabel(for: countSubLabel, fontStyle: .label2, textColor: .black)
        
        let characterImage = CommonImageView(imageName: "pocket_my_number_available")
        
        view.flex.direction(.column)
            .define { flex in
                flex.addItem(titleLabel)
                flex.addItem()
                    .direction(.row)
                    .define { flex in
                        flex.addItem(myLottoLabel)
                            .marginRight(2)
                        flex.addItem(countLabel)
                        flex.addItem(countSubLabel)
                    }
                flex.addItem(characterImage)
                    .size(36)
                    .marginTop(-6)
                    .alignSelf(.end)
            }
            .padding(16)
            .backgroundColor(.white)
            .cornerRadius(16)
            .grow(1)
        
        let shadowOffset = CGSize(width: 0, height: 0)
        view.addDropShadow()
        
        return view
    }()
    
    private lazy var resultPendingStatusCardView: UIView = {
        let view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "아직\r당첨 발표 전인"
        titleLabel.numberOfLines = 2
        styleLabel(for: titleLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        let myLottoLabel = UILabel()
        myLottoLabel.text = "내 로또"
        styleLabel(for: myLottoLabel, fontStyle: .label2, textColor: .black)
        
        let countLabel = UILabel()
        countLabel.text = "2"
        styleLabel(for: countLabel, fontStyle: .label2, textColor: .red50Default)
        
        let countSubLabel = UILabel()
        countSubLabel.text = "개"
        styleLabel(for: countSubLabel, fontStyle: .label2, textColor: .black)
        
        let characterImage = CommonImageView(imageName: "pocket_my_number_before")
        
        view.flex.direction(.column)
            .define { flex in
                flex.addItem(titleLabel)
                flex.addItem()
                    .direction(.row)
                    .define { flex in
                        flex.addItem(myLottoLabel)
                            .marginRight(2)
                        flex.addItem(countLabel)
                        flex.addItem(countSubLabel)
                    }
                flex.addItem(characterImage)
                    .size(36)
                    .marginTop(-6)
                    .alignSelf(.end)
            }
            .padding(16)
            .backgroundColor(.white)
            .cornerRadius(16)
            .grow(1)
        
        let shadowOffset = CGSize(width: 0, height: 0)
        view.addDropShadow()
        
        return view
    }()
    
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
    
    private let myLotteryHistoryLabel: UILabel = {
        let label = UILabel()
        label.text = "내 로또 내역"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black, alignment: .left)
        return label
    }()
    
    private let contentContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    // N 값이 변화하기 때문에 file 범위에 선언.
    private let lotterySummaryStatsFirstLabel: UILabel = {
        let label = UILabel()
        label.text = "2024년 8월부터 로또를 총 NN개 구매했어요."
        styleLabel(for: label, fontStyle: .body1, textColor: .black, alignment: .left)
        return label
    }()
    
    private let lotterySummaryStatsSecondLabel: UILabel = {
        let label = UILabel()
        label.text = "당첨 N개 미당첨 N개로 내 당첨률은 NN%이에요."
        styleLabel(for: label, fontStyle: .body1, textColor: .black, alignment: .left)
        return label
    }()
    
    private lazy var lotterySummaryStatsView: UIView = {
        let view = UIView()
        
        view.flex.direction(.column).gap(4).define { flex in
            flex.addItem(lotterySummaryStatsFirstLabel)
            flex.addItem(lotterySummaryStatsSecondLabel)
        }
        .padding(20)
        .backgroundColor(.gray10)
        .cornerRadius(16)
        
        return view
    }()
    
    private var myLotteryNumbersListView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.flex.paddingBottom(20)
        return view
    }()
    
    private var currentDisplayCount = 3
    
    private let moreNumbersButtonView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "더 보기"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray100)
        
        let imageView = UIImageView()
        let image = UIImage(named: "icon_arrow_down")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        view.flex.direction(.row).gap(4).alignSelf(.center).alignItems(.center).paddingTop(8).define { flex in
            flex.addItem(label)
            flex.addItem(imageView)
                .size(14)
        }
        return view
    }()
    
    private let emptyMyLotteryNumbersView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray10
        
        let imageView = UIImageView()
        let image = UIImage(named: "ch_emptyRandomNumbers")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "아직 저장한 내 로또가 없어요."
        styleLabel(for: label, fontStyle: .body2, textColor: .gray100)
        
//        let button = StyledButton(title: "번호 뽑으러 가기", buttonStyle: .solid(.round, .active), cornerRadius: 19, verticalPadding: 8, horizontalPadding: 16)
        
        view.flex.direction(.column).justifyContent(.center).alignItems(.center).define { flex in
            let screenWidth = UIScreen.main.bounds.width
            let aspectRatio: CGFloat = 3.57
            let size = screenWidth / aspectRatio
            
            flex.addItem(imageView)
                .size(size)
                .marginBottom(16)
            flex.addItem(label)
//                .marginBottom(16)
//            flex.addItem(button)

        }
        .width(100%)
        .height(240)
        .marginTop(12)
        
        return view
    }()
    
    // 임시 배너
//    private let banner = BannerView(bannerBackgroundColor: .yellow5, bannerImageName: "banner_coins", titleText: "행운의 1등 로또\r어디서 샀을까?", bodyText: "당첨 판매점 보러가기")
    
    init() {
        super.init(frame: .zero)
        
        setupStorageObserver()
        setupMoreButtonAction()
        addLotteryDashBoadView()
        addMyLotteryNumbersView()
        updateMyLotteryStatusView()
        
        let cardWidth = (UIScreen.main.bounds.width - 55) / 2
        
        addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.column).define { flex in
            flex.addItem().direction(.row)
                .justifyContent(.center)
                .gap(15)
                .define { flex in
                    flex.addItem(qrScanCardView)
                        .width(cardWidth)
                    flex.addItem(saveMyNumbersCardView)
                        .width(cardWidth)
                }
                .marginBottom(40)
                .paddingHorizontal(20)
            
            flex.addItem(myLotteryStatusLabel)
                .marginHorizontal(20)
            
            flex.addItem(contentContainer)
                .grow(1)
            
            // drawCountdownView와 showPrizeHistoryButton을 항상 표시
            flex.addItem(drawCountdownView)
                .marginTop(8)
                .marginHorizontal(20)
            
            flex.addItem(showPrizeHistoryButton)
                .alignSelf(.end)
                .marginTop(8)
                .marginBottom(48)
                .marginHorizontal(20)
            
//            if mySavedLottoNumbers == 0 {
//                flex.addItem(banner)
//                    .marginTop(32)
//                    .marginBottom(48)
//                    .marginHorizontal(20)
//            }
        }
        .marginTop(24)
    }
    
    private func setupStorageObserver() {
        LotteryStorageManager.shared.entries
            .subscribe(onNext: { [weak self] entries in
                self?.mySavedLottoNumbers = entries.count
                self?.updateMyLotteryStatusView()
                self?.addMyLotteryNumbersView()
                self?.updateDashboardCounts()
                self?.updateLotteryStats()
                self?.setNeedsLayout()
                self?.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupMoreButtonAction() {
        moreNumbersButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let totalSavedEntries = LotteryStorageManager.shared.currentEntries.count
                self.currentDisplayCount = min(self.currentDisplayCount + 3, totalSavedEntries)
                self.addMyLotteryNumbersView()
                self.setNeedsLayout()
                self.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateDashboardCounts() {
        // 현재 날짜를 기준으로 당첨 발표 여부 판단
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let savedEntries = LotteryStorageManager.shared.currentEntries
        
        var availableCount = 0
        var pendingCount = 0
        
        for entry in savedEntries {
            if let drawDate = dateFormatter.date(from: entry.drawDate) {
                // 추첨일로부터 1일 후가 당첨 발표일로 가정
                let announcementDate = Calendar.current.date(byAdding: .day, value: 1, to: drawDate) ?? drawDate
                
                if currentDate >= announcementDate {
                    availableCount += 1
                } else {
                    pendingCount += 1
                }
            }
        }
        
        // 대시보드 카운트 레이블 업데이트
        updateCountLabels(available: availableCount, pending: pendingCount)
    }
    
    private func updateCountLabels(available: Int, pending: Int) {
        // 당첨 확인 가능한 개수 업데이트
        if let countLabel = resultReadyStatusCardView.subviews.first(where: { $0 is UILabel && ($0 as! UILabel).textColor == .red50Default }) as? UILabel {
            countLabel.text = "\(available)"
        }
        
        // 당첨 발표 전인 개수 업데이트  
        if let countLabel = resultPendingStatusCardView.subviews.first(where: { $0 is UILabel && ($0 as! UILabel).textColor == .red50Default }) as? UILabel {
            countLabel.text = "\(pending)"
        }
    }
    
    private func updateLotteryStats() {
        let savedEntries = LotteryStorageManager.shared.currentEntries
        let totalCount = savedEntries.count
        
        if totalCount == 0 {
            lotterySummaryStatsFirstLabel.text = "아직 저장한 복권이 없어요."
            lotterySummaryStatsSecondLabel.text = "복권 번호를 저장하고 당첨 내역을 확인해보세요."
            return
        }
        
        // 가장 오래된 저장 날짜 계산
        let oldestDate = savedEntries.map { $0.createdAt }.min() ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        let startDateString = dateFormatter.string(from: oldestDate)
        
        // 당첨/미당첨 개수 (현재는 isWinning 필드 사용)
        let winningCount = savedEntries.filter { $0.isWinning }.count
        let notWinningCount = totalCount - winningCount
        
        // 당첨률 계산
        let winningRate: Double = totalCount > 0 ? (Double(winningCount) / Double(totalCount)) * 100 : 0
        
        lotterySummaryStatsFirstLabel.text = "\(startDateString)부터 복권을 총 \(totalCount)개 저장했어요."
        lotterySummaryStatsSecondLabel.text = "당첨 \(winningCount)개 미당첨 \(notWinningCount)개로 내 당첨률은 \(String(format: "%.1f", winningRate))%이에요."
    }
    
    /// 외부에서 호출할 수 있는 강제 업데이트 메서드
    func forceUpdateView() {
        mySavedLottoNumbers = LotteryStorageManager.shared.currentEntries.count
        updateMyLotteryStatusView()
        addMyLotteryNumbersView()
        updateDashboardCounts()
        updateLotteryStats()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    func updateMyLotteryStatusView() {
        contentContainer.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        let view: UIView = {
            if mySavedLottoNumbers > 0 {
                return lotteryDashboardView
            } else {
                return emptyMyLotteryNumbersView
            }
        }()
        
        contentContainer.flex.define { flex in
            flex.addItem(view)
                .grow(1)
        }
    }
    
    func addLotteryDashBoadView() {
        lotteryDashboardView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        let cardWidth = (UIScreen.main.bounds.width - 55) / 2
        
        lotteryDashboardView.flex.direction(.column).define { flex in
            flex.addItem()
                .direction(.row)
                .justifyContent(.center)
                .marginBottom(16)
                .gap(15)
                .define { flex in
                    flex.addItem(resultReadyStatusCardView)
                        .width(cardWidth)
                    flex.addItem(resultPendingStatusCardView)
                        .width(cardWidth)
                }
            
            flex.addItem(myLotteryHistoryLabel)
                .marginBottom(8)
            flex.addItem(lotterySummaryStatsView)
                .marginBottom(20)
            flex.addItem(myLotteryNumbersListView)
                .grow(1)
        }
        .paddingHorizontal(20)
        .marginTop(8)
    }
    
    func addMyLotteryNumbersView() {
        myLotteryNumbersListView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        // 저장된 복권 데이터 가져오기
        let savedEntries = LotteryStorageManager.shared.currentEntries
        
        // 저장된 데이터가 없으면 빈 뷰 표시
        guard !savedEntries.isEmpty else {
            return
        }
        
        // 최신 데이터부터 정렬 (생성일 기준)
        let sortedEntries = savedEntries.sorted { $0.createdAt > $1.createdAt }
        
        // LotteryEntry를 LotteryResult로 변환
        let results = sortedEntries.map { $0.toLotteryResult() }
        
        let initialDisplaResults = Array(results.prefix(currentDisplayCount))
        let groupedNumbers = Dictionary(grouping: initialDisplaResults) { $0.drawDate }
        let sortedDates = groupedNumbers.keys.sorted(by: >)
        
        let editButton: UILabel = {
            let label = UILabel()
            label.text = "편집"
            styleLabel(for: label, fontStyle: .label2, textColor: .gray80)
            return label
        }()
        
        myLotteryNumbersListView.flex.direction(.column).gap(16).define { flex in
            
            sortedDates.forEach { date in
                
                let drawRoundAndDateHeaderLabel: UIView = {
                    let view = UIView()
                    let drawRoundLabel = UILabel()
                    if let drawRound = groupedNumbers[date]?.first?.round {
                        drawRoundLabel.text = "\(drawRound)회차"
                    }
                    styleLabel(for: drawRoundLabel, fontStyle: .label1, textColor: .black)
                    let dateLabel = UILabel()
                    dateLabel.text = date.reformatDate
                    styleLabel(for: dateLabel, fontStyle: .caption1, textColor: .gray80)
                    
                    view.flex.direction(.row).alignItems(.end).gap(4).define { flex in
                        flex.addItem(drawRoundLabel)
                        flex.addItem(dateLabel)
                    }
                    .alignSelf(.start)
                    
                    return view
                }()
                
                
                flex.addItem().direction(.column).define { flex in
                    flex.addItem(drawRoundAndDateHeaderLabel)
                        .marginBottom(12)
                    
                    flex.addItem().direction(.column).gap(8).define { flex in
                    if let lotteryResults = groupedNumbers[date] {
                        lotteryResults.forEach { result in
                                let type = result.type
                                let numbers = result.numbers
                                
                                let typeIcon = UIImageView()
                                let iconImage = UIImage(named: type == .lotto645 ? "icon_lotto" : "icon_pensionLottery")
                                typeIcon.image = iconImage
                                
                                flex.addItem().direction(.row).gap(4).alignItems(.center).paddingVertical(4).define { flex in
                                    flex.addItem(typeIcon)
                                        .size(20)
                                    
                                    switch type {
                                    case .lotto645:
                                        flex.addItem().direction(.row).gap(8).define { flex in
                                            numbers.forEach { number in
                                                let numberBall = WinningNumberCircleView()
                                                let color = colorForNumber(number)
                                                numberBall.number = number
                                                numberBall.circleColor = color
                                                
                                                flex.addItem(numberBall)
                                                    .size(28)
                                            }
                                        }
                                    case .lotto720:
                                        flex.addItem().direction(.row).gap(6).define { flex in
                                            numbers.enumerated().forEach { index, number in
                                                let numberBall = WinningNumberCircleView()
                                                let color = colorForPensionNumber(index: index)
                                                numberBall.number = number
                                                numberBall.circleColor = color
                                                
                                                if index == 0 {
                                                    let groupLabel: UILabel = {
                                                        let label = UILabel()
                                                        label.text = "조"
                                                        styleLabel(for: label, fontStyle: .caption1, textColor: .black)
                                                        return label
                                                    }()
                                                    
                                                    flex.addItem().direction(.row).gap(4).define { flex in
                                                        flex.addItem(numberBall)
                                                            .size(28)
                                                        flex.addItem(groupLabel)
                                                    }
                                                } else {
                                                    flex.addItem(numberBall)
                                                        .size(28)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 저장된 데이터가 현재 표시 개수보다 많으면 "더 보기" 버튼 표시
        if currentDisplayCount < results.count {
            myLotteryNumbersListView.flex.define { flex in
                flex.addItem(moreNumbersButtonView)
            }
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
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
}

// MARK: - LotteryEntry to LotteryResult Conversion
extension LotteryEntry {
    func toLotteryResult() -> LotteryResult {
        let myLotteryType: MyLotteryNumberType = self.type == .lotto ? .lotto645 : .lotto720
        return LotteryResult(
            type: myLotteryType,
            round: String(self.round),
            numbers: self.numbers,
            drawDate: self.drawDate
        )
    }
}

extension MyNumbersView {
    func bind(reactor: StorageViewReactor) {
        // qr scan 버튼 clicked action
        scanButton.rx.tapGesture()
            .when(.recognized)
            .map { _ in StorageViewReactor.Action.qrScanButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 번호 등록하기 버튼 clicked action
        addNumberButton.rx.tapGesture()
            .when(.recognized)
            .map { _ in StorageViewReactor.Action.addNumberButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

#Preview {
    let view = MyNumbersView()
    return view
}

