import UIKit
import PinLayout
import FlexLayout

class WinnerGuideCardsListView: UIView {
    fileprivate let rootFlexContainer = UIView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    private let cardType: WinnerGuideCardView.CardType
    private var cards: [WinnerGuideCardView] = []
    
    // 카드 맨 뒷쪽 버튼 뷰
    private var trailingView: UIView?
    private var shouldShowTrailingView: Bool = false
    private var shouldShowMoreButton: Bool = false
    
    // 더보기 버튼 탭 핸들러
    var onMoreButtonTapped: (() -> Void)?
    
    // 더보기 버튼
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
        
        view.addDropShadow()
        
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
    
    init(cardType: WinnerGuideCardView.CardType) {
        self.cardType = cardType
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(scrollView)
        scrollView.addSubview(rootFlexContainer)
        
        // 더보기 버튼 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMoreButtonTap))
        moreWinnerGuideButtonView.addGestureRecognizer(tapGesture)
        moreWinnerGuideButtonView.isUserInteractionEnabled = true
    }
    
    @objc private func handleMoreButtonTap() {
        onMoreButtonTapped?()
    }
    
    // 기존 configure 메서드 (하위 호환성 유지)
    func configure(with cardData: [(number: Int, description: String)]) {
        let extendedData: [(number: Int, description: String, detailDescriptions: [String])] = cardData.map { 
            (number: $0.number, description: $0.description, detailDescriptions: [])
        }
        configure(with: extendedData)
    }
    
    // 상세 설명 지원하는 새로운 configure 메서드
    func configure(with cardData: [(number: Int, description: String, detailDescriptions: [String])]) {
        // 기존 카드 제거
        rootFlexContainer.subviews.forEach { $0.removeFromSuperview() }
        cards.removeAll()
        
        // 카드 생성
        for data in cardData {
            let card = WinnerGuideCardView(cardType: cardType)
            card.configure(number: data.number, description: data.description, detailDescriptions: data.detailDescriptions)
            
            rootFlexContainer.addSubview(card)
            cards.append(card)
        }
        
        // moreWinnerGuideButtonView 추가
        rootFlexContainer.addSubview(moreWinnerGuideButtonView)
        
        setNeedsLayout()
    }
    
    func setTrailingView(_ view: UIView?, showCondition: Bool) {
        self.trailingView = view
        self.shouldShowTrailingView = showCondition
        
        if showCondition, let view = view {
            rootFlexContainer.addSubview(view)
        } else {
            trailingView?.removeFromSuperview()
        }
        
        setNeedsLayout()
    }
    
    func setShowMoreButton(_ show: Bool) {
        self.shouldShowMoreButton = show
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 스크롤 뷰를 전체 영역에 맞춤
        scrollView.pin.all()
        
        // 카드 크기 계산
        let screenWidth = UIScreen.main.bounds.width
        let cardWidth = screenWidth / 1.4423
        let cardHeight = cardWidth * (186 / 260)
        let cardSpacing: CGFloat = 16
        let sideMargin: CGFloat = 20
        
        var xOffset: CGFloat = sideMargin
        
        // 카드 배치
        for (index, card) in cards.enumerated() {
            let isLastCard = index == cards.count - 1
            
            card.pin
                .left(xOffset)
                .width(cardWidth)
                .height(cardHeight)
            
            xOffset += cardWidth
            
            // 마지막 카드가 아니면 간격 추가
            if !isLastCard {
                xOffset += cardSpacing
            }
        }
        
        
        // moreWinnerGuideButtonView 배치 (조건부)
        if shouldShowMoreButton {
            xOffset += cardSpacing
            
            moreWinnerGuideButtonView.pin
                .left(xOffset)
                .width(cardWidth)
                .height(cardHeight)
            
            // Flex layout을 사용하는 뷰의 경우 레이아웃 계산 필요
            moreWinnerGuideButtonView.flex.layout()
            moreWinnerGuideButtonView.isHidden = false
            
            xOffset += cardWidth
        } else {
            moreWinnerGuideButtonView.isHidden = true
        }
        
        // 마지막 카드 뒤에 오른쪽 마진 추가
        if !cards.isEmpty {
            xOffset += sideMargin
        }
        
        // rootFlexContainer의 너비를 모든 카드를 포함할 수 있도록 설정
        rootFlexContainer.pin
            .vCenter()
            .left()
            .height(cardHeight)
            .width(xOffset)
        
        // 스크롤 뷰의 콘텐츠 사이즈 설정
        scrollView.contentSize = CGSize(width: xOffset, height: cardHeight)
        
        // 디버깅을 위한 출력
        if !cards.isEmpty {
            print("Cards count: \(cards.count)")
            print("Content width: \(xOffset)")
            print("Scroll view content size: \(scrollView.contentSize)")
        }
    }
}

#Preview {
    let view = WinnerGuideCardsListView(cardType: .howToClaim)
    view.configure(with: [
        (number: 1, 
         description: "당첨번호와 일치하는지 먼저 확인해요.\n당첨번호 확인은 로또메이트 앱에서 가능합니다.",
         detailDescriptions: ["※ 당첨번호 확인은 로또 발표일 이후에 가능합니다."]),
        (number: 2, 
         description: "당첨금 수령 기간과 장소를 확인해요.\n당첨금은 발표일로부터 1년 이내에만 받을 수 있습니다.",
         detailDescriptions: ["※ 고액 당첨의 경우 로또 판매점이 아닌 은행에서 수령가능합니다.", 
                            "※ 신분증을 꼭 지참해주세요."]),
        (number: 3, 
         description: "신분증과 당첨 복권을 준비해요.\n등수에 따라 필요한 준비물이 다를 수 있으니 확인하세요.",
         detailDescriptions: [])
    ])
    return view
} 
