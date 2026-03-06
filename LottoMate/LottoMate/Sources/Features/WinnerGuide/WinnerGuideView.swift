//
//  WinnerGuideView.swift
//  LottoMate
//
//  Created by Mirae on 3/26/25.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift

class WinnerGuideView: UIView {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    fileprivate let rootFlexContainer = UIView()
    
    private let topMargin: CGFloat = {
        let topMargin = DeviceMetrics.statusWithNavigationBarHeight + 16
        return topMargin
    }()
    
    private let lotteryTypeButtonsView = WinnerGuideLotteryTypeButtonsView()
    
    private let contentView = UIView()
    
    private let disposeBag = DisposeBag()
    
    private let claimPeriodCautionView: UIView = {
        let view = UIView()
        let topImage = CommonImageView(imageName: "ch_QRScan")
        
        let bodyLabel = UILabel()
        bodyLabel.numberOfLines = 2
        let fullText = "당첨 결과 발표 후부터 1년 내로 당첨금을 찾아야 해요\r정해진 기간이 지나면 받을 수 없으니 꼭 주의하세요"
        let attributedString = NSMutableAttributedString(string: fullText)
        let baseAttributes: [NSAttributedString.Key: Any] = Typography.label1.attributes()
        attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: fullText.count))
        let highlightText = "1년 내로"
        if let range = fullText.range(of: highlightText) {
            let nsRange = NSRange(range, in: fullText)
            var highlightAttributes = Typography.label2.attributes()
            highlightAttributes[.foregroundColor] = UIColor.red50Default
            attributedString.addAttributes(highlightAttributes, range: nsRange)
        }
        bodyLabel.attributedText = attributedString
        
        let subLabel = UILabel()
        subLabel.numberOfLines = 2
        subLabel.text = "지급 마지막 날짜가 공휴일 또는 주말일 경우 다음날까지 찾아갈 수 있어요. 수령하지 않은 당첨금은 복권기금으로 포함됩니다"
        styleLabel(for: subLabel, fontStyle: .caption1, textColor: .gray100)
        
        view.flex
            .direction(.column)
            .alignItems(.center)
            .padding(20)
            .backgroundColor(.gray10)
            .cornerRadius(16)
            .define { flex in
                
                flex.addItem(topImage)
                    .size(48)
                
                flex.addItem()
                    .direction(.column)
                    .gap(8)
                    .define { flex in
                        flex.addItem(bodyLabel)
                            .marginTop(12)
                        flex.addItem(subLabel)
                    }
            }
        return view
    }()
    
    private let prizeClaimGuideLabel = CommonHeadline1Label(text: "등수별 당첨금 수령 장소 & 준비물")
    private let howToClaimLabel = CommonHeadline1Label(text: "당첨금 받는 방법")
    private let howToClaimSubLabel: UILabel = {
        let label = UILabel()
        label.text = "소득세, 주민세 등 원천징수를 적용한 금액을 당첨금으로 받게 됩니다."
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
        return label
    }()
    private let cautionLabel = CommonHeadline1Label(text: "주의사항")
    
    private let howToClaimCardsListView = WinnerGuideCardsListView(cardType: .howToClaim)
    private let cautionCardsListView = WinnerGuideCardsListView(cardType: .caution)
    
    private let bannerContainer = UIView()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
        setupBindings()
        configureCardListViews(for: .lotto)
        setupBanner()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                flex.addItem(claimPeriodCautionView)
                    .marginHorizontal(20)
                    .marginBottom(36)
                
                flex.addItem(lotteryTypeButtonsView)
                    .marginHorizontal(20)
                    .marginBottom(24)
                
                flex.addItem(prizeClaimGuideLabel)
                    .alignSelf(.start)
                    .marginHorizontal(20)
                    .marginBottom(20)
                
                flex.addItem(contentView)
                    .direction(.column)
                    .marginHorizontal(20)
                    .marginBottom(48)
                
                flex.addItem()
                    .direction(.column)
                    .alignItems(.start)
                    .define { flex in
                        flex.addItem(howToClaimLabel)
                            .marginBottom(8)
                            .marginHorizontal(20)
                        
                        flex.addItem(howToClaimSubLabel)
                            .marginHorizontal(20)
                        
                        flex.addItem(howToClaimCardsListView)
                            .height(cardHeight + 40)
                            .width(100%)
                            .marginBottom(28)
                        
                        flex.addItem(cautionLabel)
                            .marginHorizontal(20)
                        
                        flex.addItem(cautionCardsListView)
                            .height(cardHeight + 40)
                            .width(100%)
                            .marginBottom(16)
                            
                    }
                
                flex.addItem(bannerContainer)
                    .width(UIScreen.main.bounds.width - 40)
                    .height(100)
                    .alignSelf(.center)
                    .marginBottom(36)
            }
    }
    
    private func setupBindings() {
        lotteryTypeButtonsView.selectedLotteryType
            .subscribe(onNext: { [weak self] lotteryType in
                guard let self = self else { return }
                
                self.contentView.subviews.forEach { $0.removeFromSuperview() }
                
                switch lotteryType {
                case .lotto:
                    let lottoContentView = self.createLottoContentView()
                    self.contentView.flex.addItem(lottoContentView)
                case .pensionLottery:
                    let pensionContentView = self.createPensionLotteryContentView()
                    self.contentView.flex.addItem(pensionContentView)
                case .speeto:
                    let speetoContentView = self.createSpeetoContentView()
                    self.contentView.flex.addItem(speetoContentView)
                }
                
                self.configureCardListViews(for: lotteryType)
                self.setNeedsLayout()
            })
            .disposed(by: disposeBag)
        
        configureCardListViews(for: .lotto)
    }
    
    private func configureCardListViews(for lotteryType: LotteryType) {
        switch lotteryType {
        case .lotto:
            configureLottoCardListViews()
        case .pensionLottery:
            configurePensionLotteryCardListViews()
        case .speeto:
            configureSpeetoCardListViews()
        }
        
        // Reset scroll position to the beginning
        resetCardListsScrollPosition()
    }
    
    private func resetCardListsScrollPosition() {
        // Immediately reset scroll position to the leftmost point (x: 0)
        howToClaimCardsListView.findScrollView()?.setContentOffset(.zero, animated: false)
        cautionCardsListView.findScrollView()?.setContentOffset(.zero, animated: false)
    }
    
    private func configureLottoCardListViews() {
        // 로또 - 당첨금 받는 방법 카드 데이터
        let howToClaimData: [(number: Int, description: String, detailDescriptions: [String])] = [
            (1, "NH농협에서 당첨된 복권과 함께\n신분증으로 당첨자를 확인해요", []),
            (2, "모두 확인이 되면,\r당첨금을 받게 돼요", []),
            (3, "당첨금은 일시불로 지불되며\r요청 시 현금으로 받을수도 있어요", [])
        ]
        
        // 로또 - 주의사항 카드 데이터
        let cautionData: [(number: Int, description: String, detailDescriptions: [String])] = [
            (1, "19세 미만은 복권을\r살 수 없어요", []),
            (2, "당첨 복권을 잃어버리면\r당첨금을 받을 수 없어요", []),
            (3, "복권이 훼손되어도 1/2 이상 살아있고\r컴퓨터가 인식 가능하면 당첨 정보를\r확인할 수 있어요", [])
        ]
        
        howToClaimCardsListView.configure(with: howToClaimData)
        cautionCardsListView.configure(with: cautionData)
    }
    
    private func configurePensionLotteryCardListViews() {
        // 연금복권 - 당첨금 받는 방법 카드 데이터
        let howToClaimData: [(number: Int, description: String, detailDescriptions: [String])] = [
            (1, "동행복권 본사 방문 전 꼭 전화로\r방문예약을 하세요", ["월 - 금 오전 10시 - 오후 3시", "고객센터 : 1566 - 5520"]),
            (2, "예약한 날짜/시간에 동행복권\r본점에 방문해요", []),
            (3, "동행복권에서\r당첨된 복권, 신분증으로\r당첨자를 확인해요", []),
            (4, "모두 확인이 되면, 당첨금을 받아요", ["*연금식 당첨금은 방문 후 다음달 20일부터\r받아요 (공휴일인 경우 20일 전날에 받아요)", "*일반 당첨금은 한 번에 받아요"])
        ]
        
        // 연금복권 - 주의사항 카드 데이터
        let cautionData: [(number: Int, description: String, detailDescriptions: [String])] = [
            (1, "19세 미만은\r복권을 살 수 없어요", []),
            (2, "당첨 복권을 잃어버리면\r당첨금을 받을 수 없어요", []),
            (3, "당첨금을 받을 수 있는 권리를\r타인에게 양도할 수 없으며, 금융권\r담보로 사용할 수 없어요", []),
            (4, "오염 및 훼손된 연금복권은 동행복권\r지점을 방문하거나 우편접수로 복권\r당첨 확인 검사를 요청할 수 있어요", ["*검사비는 소지자가 부담합니다"])
        ]
        
        howToClaimCardsListView.configure(with: howToClaimData)
        cautionCardsListView.configure(with: cautionData)
    }
    
    private func configureSpeetoCardListViews() {
        // 스피또 - 당첨금 받는 방법 카드 데이터
        let howToClaimData: [(number: Int, description: String, detailDescriptions: [String])] = [
            (1, "동행복권 본사 방문 전 꼭 전화로\r방문예약을 하세요", ["월 - 금 오전 10시 - 오후 3시", "고객센터 : 1566 - 5520"]),
            (2, "예약한 날짜/시간에 동행복권\r본점에 방문해요", []),
            (3, "동행복권에서\r당첨된 복권, 신분증으로\r당첨자를 확인해요", []),
            (4, "모두 확인이 되면, 당첨금을 받아요", ["*연금식 당첨금은 방문 후 다음달 20일에\r받아요. (공휴일인 경우 20일 전날에 받아요)", "*일반 당첨금은 한 번에 받아요"]),
            (5, "게임을 구성한 그림, 숫자 등 기호가\r오염 또는 훼손되어 확인할 수 없으면\r당첨금을 받을 수 없어요", [])
        ]
        
        // 스피또 - 주의사항 카드 데이터
        let cautionData: [(number: Int, description: String, detailDescriptions: [String])] = [
            (1, "19세 미만은\r복권을 살 수 없어요", []),
            (2, "당첨 복권을 잃어버리면\r당첨금을 받을 수 없어요", []),
            (3, "아래의 경우 교환, 환불이 가능해요", ["*긁는 부분이 긁히지 않는 경우", "*당첨 내역을 초과해서 당첨된 경우", "*인쇄 오류가 인정되는 경우"])
        ]
        
        howToClaimCardsListView.configure(with: howToClaimData)
        cautionCardsListView.configure(with: cautionData)
    }
    
    // 로또 콘텐츠 뷰
    private func createLottoContentView() -> UIView {
        let view = UIView()
        
        let imgForFirst = CommonImageView(imageName: "guide_winning_ticket_and_id")
        let imgForSecondAndThird = CommonImageView(imageName: "guide_winning_ticket_and_id")
        let imgForFourthAndFifth = CommonImageView(imageName: "guide_winning_ticket")
        
        let firstPlaceIcon = CommonImageView(imageName: "icon_place")
        let secondAndThirdPlaceIcon = CommonImageView(imageName: "icon_place")
        let fourthAndFifthPlaceIcon = CommonImageView(imageName: "icon_place")
        
        let firstPrizeLabel = UILabel()
        firstPrizeLabel.text = "1등"
        styleLabel(for: firstPrizeLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        let secondAndThirdPrizeLabel = UILabel()
        secondAndThirdPrizeLabel.text = "2등, 3등"
        styleLabel(for: secondAndThirdPrizeLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        let fourthAndFifthPrizeLabel = UILabel()
        fourthAndFifthPrizeLabel.text = "4등, 5등"
        styleLabel(for: fourthAndFifthPrizeLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        // 장소 레이블 반복 생성
        func createLocationLabel() -> UILabel {
            let label = UILabel()
            label.text = "장소"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
            return label
        }
        let firstPrizeLocationLabel = createLocationLabel()
        let secondAndThirdPrizeLocationLabel = createLocationLabel()
        let fourthAndFifthPrizeLocationLabel = createLocationLabel()
        
        // 준비물 레이블 반복 생성
        func createRequirementsLabel() -> UILabel {
            let label = UILabel()
            label.text = "준비물"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
            return label
        }
        let firstPrizeRequirementsLabel = createRequirementsLabel()
        let secondAndThirdPrizeRequirementsLabel = createRequirementsLabel()
        let fourthAndFifthPrizeRequirementsLabel = createRequirementsLabel()
        
        // 당첨복권, 신분증 레이블 생성
        func createRequirementsContentLabel(requiresIDCard: Bool) -> UILabel {
            let label = UILabel()
            label.text = requiresIDCard ? "당첨복권, 신분증" : "당첨복권"
            styleLabel(for: label, fontStyle: .label2, textColor: .black)
            return label
        }
        let firstPrizeRequirementsContentLabel = createRequirementsContentLabel(requiresIDCard: true)
        let secondAndThirdPrizeRequirementsContentLabel = createRequirementsContentLabel(requiresIDCard: true)
        let fourthAndFifthPrizeRequirementsContentLabel = createRequirementsContentLabel(requiresIDCard: false)
        
        // 수령 장소 레이블
        func createClaimPlaceLabel(text: String) -> UILabel {
            let label = UILabel()
            label.text = text
            styleLabel(for: label, fontStyle: .label2, textColor: .black)
            return label
        }
        let firstPrizeClaimPlace = createClaimPlaceLabel(text: "NH농협 본점")
        let secondAndThirdPrizeClaimPlace = createClaimPlaceLabel(text: "NH농협 전국지점")
        let fourthAndFifthPrizeClaimPlace = createClaimPlaceLabel(text: "전국 복권 판매점")
        
        // 당첨금 설명 레이블
        let firstRowDescription = UILabel()
        firstRowDescription.text = "매월 700만원씩 20년간 지급 (총 16억 8천만원)"
        styleLabel(for: firstRowDescription, fontStyle: .caption2, textColor: .gray100)
        
        let secondRowDescription = UILabel()
        secondRowDescription.text = "매월 100만원씩 10년간 지급 (총 1억 2천만원)"
        styleLabel(for: secondRowDescription, fontStyle: .caption2, textColor: .gray100)
        
        let thirdRowDescription = UILabel()
        thirdRowDescription.text = "일시금 1천만원 지급"
        styleLabel(for: thirdRowDescription, fontStyle: .caption2, textColor: .gray100)
        
        let bonusRowDescription = UILabel()
        bonusRowDescription.text = "일시금 300만원 지급"
        styleLabel(for: bonusRowDescription, fontStyle: .caption2, textColor: .gray100)
        
        view.flex
            .direction(.column)
            .gap(16)
            .paddingVertical(24)
            .paddingHorizontal(28)
            .backgroundColor(.white)
            .cornerRadius(16)
            .define { flex in
                
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(imgForFirst)
                            .size(60)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .define { flex in
                                flex.addItem(firstPrizeLabel)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(2)
                                    .define { flex in
                                        flex.addItem()
                                            .direction(.row)
                                            .alignItems(.center)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(firstPrizeLocationLabel)
                                                flex.addItem(firstPrizeClaimPlace)
                                                flex.addItem(firstPlaceIcon)
                                                    .size(14)
                                            }
                                        flex.addItem()
                                            .direction(.row)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(firstPrizeRequirementsLabel)
                                                flex.addItem(firstPrizeRequirementsContentLabel)
                                            }
                                    }
                            }
                    }
                
                flex.addItem().backgroundColor(.gray20).height(1).width(100%)
                
                // 2등, 3등 섹션 추가
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(imgForSecondAndThird)
                            .size(60)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .define { flex in
                                flex.addItem(secondAndThirdPrizeLabel)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(2)
                                    .define { flex in
                                        flex.addItem()
                                            .direction(.row)
                                            .alignItems(.center)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(secondAndThirdPrizeLocationLabel)
                                                flex.addItem(secondAndThirdPrizeClaimPlace)
                                                flex.addItem(secondAndThirdPlaceIcon)
                                                    .size(14)
                                            }
                                        flex.addItem()
                                            .direction(.row)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(secondAndThirdPrizeRequirementsLabel)
                                                flex.addItem(secondAndThirdPrizeRequirementsContentLabel)
                                            }
                                    }
                            }
                    }
                
                flex.addItem().backgroundColor(.gray20).height(1).width(100%)
                
                // 4등, 5등 섹션 추가
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(imgForFourthAndFifth)
                            .size(60)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .define { flex in
                                flex.addItem(fourthAndFifthPrizeLabel)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(2)
                                    .define { flex in
                                        flex.addItem()
                                            .direction(.row)
                                            .alignItems(.center)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(fourthAndFifthPrizeLocationLabel)
                                                flex.addItem(fourthAndFifthPrizeClaimPlace)
                                                flex.addItem(fourthAndFifthPlaceIcon)
                                                    .size(14)
                                            }
                                        flex.addItem()
                                            .direction(.row)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(fourthAndFifthPrizeRequirementsLabel)
                                                flex.addItem(fourthAndFifthPrizeRequirementsContentLabel)
                                            }
                                    }
                            }
                    }
            }
        
        view.addDropShadow()
        return view
    }
    
    // 연금복권 콘텐츠 뷰
    private func createPensionLotteryContentView() -> UIView {
        let view = UIView()
        
        let imgForFirstAndSecond = CommonImageView(imageName: "guide_winning_ticket_id_copy")
        let imgForSecondAndThird = CommonImageView(imageName: "guide_winning_ticket_and_id")
        let imgForRemainingRanks = CommonImageView(imageName: "guide_winning_ticket")
        let imgForBonus = CommonImageView(imageName: "guide_winning_ticket_id_copy")
        
        let firstRowPlaceIcon = CommonImageView(imageName: "icon_place")
        let secondRowPlaceIcon = CommonImageView(imageName: "icon_place")
        let thirdRowPlaceIcon = CommonImageView(imageName: "icon_place")
        let bonusPlaceIcon = CommonImageView(imageName: "icon_place")
        
        let firstRowLabel = UILabel()
        firstRowLabel.text = "1등, 2등"
        styleLabel(for: firstRowLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        let secondRowLabel = UILabel()
        secondRowLabel.text = "3등, 4등"
        styleLabel(for: secondRowLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        let thirdRowLabel = UILabel()
        thirdRowLabel.text = "5등, 6등, 7등"
        styleLabel(for: thirdRowLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        let bonusLabel = UILabel()
        bonusLabel.text = "보너스"
        styleLabel(for: bonusLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        // 장소 레이블 반복 생성
        func createLocationLabel() -> UILabel {
            let label = UILabel()
            label.text = "장소"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
            return label
        }
        let firstRowLocationLabel = createLocationLabel()
        let secondRowLocationLabel = createLocationLabel()
        let thirdRowLocationLabel = createLocationLabel()
        
        // 준비물 레이블 반복 생성
        func createRequirementsLabel() -> UILabel {
            let label = UILabel()
            label.text = "준비물"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
            return label
        }
        let firstRowRequirementsLabel = createRequirementsLabel()
        let secondRowRequirementsLabel = createRequirementsLabel()
        let thirdRowRequirementsLabel = createRequirementsLabel()
        
        // 당첨복권, 신분증 레이블 생성
        func createRequirementsContentLabel(requiresIDCard: Bool, requiresBankbookCopy: Bool = false) -> UILabel {
            let label = UILabel()
            if requiresIDCard && requiresBankbookCopy {
                label.text = "당첨복권, 신분증, 통장사본"
            } else if requiresIDCard {
                label.text = "당첨복권, 신분증"
            } else {
                label.text = "당첨복권"
            }
            styleLabel(for: label, fontStyle: .label2, textColor: .black)
            return label
        }
        let firstRowRequirementsContentLabel = createRequirementsContentLabel(requiresIDCard: true, requiresBankbookCopy: true)
        let secondRowRequirementsContentLabel = createRequirementsContentLabel(requiresIDCard: true)
        let thirdRowRequirementsContentLabel = createRequirementsContentLabel(requiresIDCard: false)
        
        // 수령 장소 레이블
        func createClaimPlaceLabel(text: String) -> UILabel {
            let label = UILabel()
            label.text = text
            styleLabel(for: label, fontStyle: .label2, textColor: .black)
            return label
        }
        let firstRowClaimPlace = createClaimPlaceLabel(text: "동행복권 본사")
        let secondRowClaimPlace = createClaimPlaceLabel(text: "NH농협 전국지점")
        let thirdRowClaimPlace = createClaimPlaceLabel(text: "전국 복권 판매점")
        
        // 당첨금 설명 레이블
        let firstRowDescription = UILabel()
        firstRowDescription.text = "매월 700만원씩 20년간 지급 (총 16억 8천만원)"
        styleLabel(for: firstRowDescription, fontStyle: .caption2, textColor: .gray100)
        
        let secondRowDescription = UILabel()
        secondRowDescription.text = "매월 100만원씩 10년간 지급 (총 1억 2천만원)"
        styleLabel(for: secondRowDescription, fontStyle: .caption2, textColor: .gray100)
        
        let thirdRowDescription = UILabel()
        thirdRowDescription.text = "일시금 1천만원 지급"
        styleLabel(for: thirdRowDescription, fontStyle: .caption2, textColor: .gray100)
        
        let firstDescription = UILabel()
        firstDescription.text = "*연금식 당첨금으로 매달 지급"
        styleLabel(for: firstDescription, fontStyle: .caption1, textColor: .gray80)
        
        let secondDescription = UILabel()
        secondDescription.text = "*연금식 당첨금으로 매달 지급"
        styleLabel(for: secondDescription, fontStyle: .caption1, textColor: .gray80)
        
        view.flex
            .direction(.column)
            .gap(16)
            .paddingVertical(24)
            .paddingHorizontal(28)
            .backgroundColor(.white)
            .cornerRadius(16)
            .define { flex in
                
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(imgForFirstAndSecond)
                            .size(60)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .define { flex in
                                flex.addItem(firstRowLabel)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(2)
                                    .define { flex in
                                        flex.addItem()
                                            .direction(.row)
                                            .alignItems(.center)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(firstRowLocationLabel)
                                                flex.addItem(firstRowClaimPlace)
                                                flex.addItem(firstRowPlaceIcon)
                                                    .size(14)
                                            }
                                        flex.addItem()
                                            .direction(.row)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(firstRowRequirementsLabel)
                                                flex.addItem(firstRowRequirementsContentLabel)
                                            }
                                    }
                                flex.addItem(firstDescription)
                                    .alignSelf(.start)
                            }
                    }
                
                flex.addItem().backgroundColor(.gray20).height(1).width(100%)
                
                // 2등 섹션 추가
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(imgForSecondAndThird)
                            .size(60)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .define { flex in
                                flex.addItem(secondRowLabel)
                                    .marginBottom(4)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(2)
                                    .define { flex in
                                        flex.addItem()
                                            .direction(.row)
                                            .alignItems(.center)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(secondRowLocationLabel)
                                                flex.addItem(secondRowClaimPlace)
                                                flex.addItem(secondRowPlaceIcon)
                                                    .size(14)
                                            }
                                        flex.addItem()
                                            .direction(.row)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(secondRowRequirementsLabel)
                                                flex.addItem(secondRowRequirementsContentLabel)
                                            }
                                    }
                            }
                    }
                
                flex.addItem().backgroundColor(.gray20).height(1).width(100%)
                
                // 3등 섹션 추가
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(imgForRemainingRanks)
                            .size(60)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .define { flex in
                                flex.addItem(thirdRowLabel)
                                    .marginBottom(4)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(2)
                                    .define { flex in
                                        flex.addItem()
                                            .direction(.row)
                                            .alignItems(.center)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(thirdRowLocationLabel)
                                                flex.addItem(thirdRowClaimPlace)
                                                flex.addItem(thirdRowPlaceIcon)
                                                    .size(14)
                                            }
                                        flex.addItem()
                                            .direction(.row)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(thirdRowRequirementsLabel)
                                                flex.addItem(thirdRowRequirementsContentLabel)
                                            }
                                    }
                            }
                    }
                
                flex.addItem().backgroundColor(.gray20).height(1).width(100%)
                
                // 보너스 섹션 추가
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(imgForBonus)
                            .size(60)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .define { flex in
                                flex.addItem(bonusLabel)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(2)
                                    .define { flex in
                                        flex.addItem()
                                            .direction(.row)
                                            .alignItems(.center)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(createLocationLabel())
                                                flex.addItem(createClaimPlaceLabel(text: "동행복권 본사"))
                                                flex.addItem(bonusPlaceIcon)
                                                    .size(14)
                                            }
                                        flex.addItem()
                                            .direction(.row)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(createRequirementsLabel())
                                                flex.addItem(createRequirementsContentLabel(requiresIDCard: true, requiresBankbookCopy: true))
                                            }
                                    }
                                flex.addItem(secondDescription)
                                    .alignSelf(.start)
                            }
                    }
            }
        
        view.addDropShadow()
        return view
    }
    
    // 스피또 콘텐츠 뷰
    private func createSpeetoContentView() -> UIView {
        let view = UIView()
        
        let imgForFirstRow = CommonImageView(imageName: "guide_winning_ticket_and_id")
        let imgForSecondRow = CommonImageView(imageName: "guide_winning_ticket_and_id")
        let imgForThirdRow = CommonImageView(imageName: "guide_winning_ticket")
        let imgForFourthRow = CommonImageView(imageName: "guide_winning_ticket")
        
        let firstRowPlaceIcon = CommonImageView(imageName: "icon_place")
        let secondRowPlaceIcon = CommonImageView(imageName: "icon_place")
        let thirdRowPlaceIcon = CommonImageView(imageName: "icon_place")
        let fourthRowPlaceIcon = CommonImageView(imageName: "icon_place")
        
        let firstRowLabel = UILabel()
        firstRowLabel.text = "1억 이상"
        styleLabel(for: firstRowLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        let secondRowLabel = UILabel()
        secondRowLabel.text = "200만원 초과 1억원 이하"
        styleLabel(for: secondRowLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        let thirdRowLabel = UILabel()
        thirdRowLabel.text = "5만원 초과 200만원 이하"
        styleLabel(for: thirdRowLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        let fourthRowLabel = UILabel()
        fourthRowLabel.text = "5만원 이하"
        styleLabel(for: fourthRowLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        
        // 장소 레이블 반복 생성
        func createLocationLabel() -> UILabel {
            let label = UILabel()
            label.text = "장소"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
            return label
        }
        let firstRowLocationLabel = createLocationLabel()
        let secondRowLocationLabel = createLocationLabel()
        let thirdRowLocationLabel = createLocationLabel()
        let fourthRowLocationLabel = createLocationLabel()
        
        // 준비물 레이블 반복 생성
        func createRequirementsLabel() -> UILabel {
            let label = UILabel()
            label.text = "준비물"
            styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
            return label
        }
        let firstRowRequirementsLabel = createRequirementsLabel()
        let secondRowRequirementsLabel = createRequirementsLabel()
        let thirdRowRequirementsLabel = createRequirementsLabel()
        let fourthRowRequirementsLabel = createRequirementsLabel()
        
        // 당첨복권, 신분증 레이블 생성
        func createRequirementsContentLabel(requiresIDCard: Bool) -> UILabel {
            let label = UILabel()
            label.text = requiresIDCard ? "당첨복권, 신분증" : "당첨복권"
            styleLabel(for: label, fontStyle: .label2, textColor: .black)
            return label
        }
        let firstRowRequirementsContentLabel = createRequirementsContentLabel(requiresIDCard: true)
        let secondRowRequirementsContentLabel = createRequirementsContentLabel(requiresIDCard: true)
        let thirdRowRequirementsContentLabel = createRequirementsContentLabel(requiresIDCard: false)
        let fourthRowRequirementsContentLabel = createRequirementsContentLabel(requiresIDCard: false)
        
        // 수령 장소 레이블
        func createClaimPlaceLabel(text: String) -> UILabel {
            let label = UILabel()
            label.text = text
            styleLabel(for: label, fontStyle: .label2, textColor: .black)
            return label
        }
        let firstRowClaimPlace = createClaimPlaceLabel(text: "동행복권 본사")
        let secondRowClaimPlace = createClaimPlaceLabel(text: "NH농협 전국지점")
        let thirdRowClaimPlace = createClaimPlaceLabel(text: "NH농협 전국지점")
        let fourthRowClaimPlace = createClaimPlaceLabel(text: "전국 복권 판매점")
        
        view.flex
            .direction(.column)
            .gap(16)
            .paddingVertical(24)
            .paddingHorizontal(28)
            .backgroundColor(.white)
            .cornerRadius(16)
            .define { flex in
                
                // 첫번째 행
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(imgForFirstRow)
                            .size(60)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .define { flex in
                                flex.addItem(firstRowLabel)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(2)
                                    .define { flex in
                                        flex.addItem()
                                            .direction(.row)
                                            .alignItems(.center)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(firstRowLocationLabel)
                                                flex.addItem(firstRowClaimPlace)
                                                flex.addItem(firstRowPlaceIcon)
                                                    .size(14)
                                            }
                                        flex.addItem()
                                            .direction(.row)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(firstRowRequirementsLabel)
                                                flex.addItem(firstRowRequirementsContentLabel)
                                            }
                                    }
                            }
                    }
                
                flex.addItem().backgroundColor(.gray20).height(1).width(100%)
                
                // 두번째 행
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(imgForSecondRow)
                            .size(60)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .define { flex in
                                flex.addItem(secondRowLabel)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(2)
                                    .define { flex in
                                        flex.addItem()
                                            .direction(.row)
                                            .alignItems(.center)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(secondRowLocationLabel)
                                                flex.addItem(secondRowClaimPlace)
                                                flex.addItem(secondRowPlaceIcon)
                                                    .size(14)
                                            }
                                        flex.addItem()
                                            .direction(.row)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(secondRowRequirementsLabel)
                                                flex.addItem(secondRowRequirementsContentLabel)
                                            }
                                    }
                            }
                    }
                
                flex.addItem().backgroundColor(.gray20).height(1).width(100%)
                
                // 세번째 행
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(imgForThirdRow)
                            .size(60)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .define { flex in
                                flex.addItem(thirdRowLabel)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(2)
                                    .define { flex in
                                        flex.addItem()
                                            .direction(.row)
                                            .alignItems(.center)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(thirdRowLocationLabel)
                                                flex.addItem(thirdRowClaimPlace)
                                                flex.addItem(thirdRowPlaceIcon)
                                                    .size(14)
                                            }
                                        flex.addItem()
                                            .direction(.row)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(thirdRowRequirementsLabel)
                                                flex.addItem(thirdRowRequirementsContentLabel)
                                            }
                                    }
                            }
                    }
                
                flex.addItem().backgroundColor(.gray20).height(1).width(100%)
                
                // 네번째 행
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(imgForFourthRow)
                            .size(60)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .define { flex in
                                flex.addItem(fourthRowLabel)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(2)
                                    .define { flex in
                                        flex.addItem()
                                            .direction(.row)
                                            .alignItems(.center)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(fourthRowLocationLabel)
                                                flex.addItem(fourthRowClaimPlace)
                                                flex.addItem(fourthRowPlaceIcon)
                                                    .size(14)
                                            }
                                        flex.addItem()
                                            .direction(.row)
                                            .gap(4)
                                            .define { flex in
                                                flex.addItem(fourthRowRequirementsLabel)
                                                flex.addItem(fourthRowRequirementsContentLabel)
                                            }
                                    }
                            }
                    }
            }

        view.addDropShadow()
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.all()
        rootFlexContainer.pin.top().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
    }
}

extension WinnerGuideView: BannerNavigationDelegate {
    private func setupBanner() {
        let banner = BannerManager.shared.createRandomBanner(navigationDelegate: self)
        self.bannerContainer.flex.addItem(banner)
    }
    
    func navigate(to bannerType: BannerType) {
        switch bannerType {
        case .winningStore:
            showMapViewController()

        case .winnerReview:
            showWinningReviewDetail()

        case .getRandomLottoNumbers:
            showStorageRandomNumbersView()

        case .expandServicetoMyArea:
            let urlString = "https://www.google.com" // TODO: 실제 URL로 변경 필요
            if let viewController = parentViewController {
                WebViewController.present(from: viewController, urlString: urlString, title: "서비스 지역 확대")
            }

        case .winningLottoInfo:
            LottoMateViewModel.shared.selectedLotteryType.onNext(.lotto)
            showLottoWinningInfoView()

        case .qrCodeScanner:
            showQrScanner()

        case .winnerGuide:
            // 이미 당첨자 가이드 화면이므로 아무것도 하지 않음
            break
        }
    }

    private func showMapViewController() {
        if let viewController = parentViewController,
           let tabBarController = viewController.tabBarController {
            tabBarController.selectedIndex = 1
        }
    }

    private func showWinningReviewDetail() {
        let currentReviewNos = WinningReviewReactor.shared.currentState.currentReviewNos

        if let maxNo = currentReviewNos.max() {
            navigateToReviewDetail(reviewNo: maxNo)
        } else {
            WinningReviewAPIService().fetchWinningReviewMaxNumber()
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] maxNo in
                    self?.navigateToReviewDetail(reviewNo: maxNo)
                })
                .disposed(by: disposeBag)
        }
    }

    private func navigateToReviewDetail(reviewNo: Int) {
        let detailVC = NativeWinningReviewDetailViewController(reviewNo: reviewNo)

        if let viewController = parentViewController {
            if let navigationController = viewController.navigationController {
                navigationController.pushViewController(detailVC, animated: true)
            } else if let window = WindowManager.findKeyWindow(),
                      let rootViewController = window.rootViewController as? UITabBarController,
                      let selectedNav = rootViewController.selectedViewController as? UINavigationController {
                selectedNav.pushViewController(detailVC, animated: true)
            }
        }
    }

    private func showStorageRandomNumbersView() {
        if let viewController = parentViewController,
           let tabBarController = viewController.tabBarController {
            tabBarController.selectedIndex = 2

            if let storageViewController = tabBarController.viewControllers?[2] as? StorageViewController {
                storageViewController.reactor.action.onNext(.didSelectrandomNumber)
            }
        }
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

extension UIView {
    func findScrollView() -> UIScrollView? {
        // Check if this view is a UIScrollView
        if let scrollView = self as? UIScrollView {
            return scrollView
        }
        
        // Recursively search in subviews
        for subview in subviews {
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
            
            // Recursively search in this subview
            if let scrollView = subview.findScrollView() {
                return scrollView
            }
        }
        
        return nil
    }
}

#Preview {
    let view = ViewTemplate()
    return view
}
