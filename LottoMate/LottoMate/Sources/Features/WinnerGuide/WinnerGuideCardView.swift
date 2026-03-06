import UIKit
import PinLayout
import FlexLayout

class WinnerGuideCardView: UIView {
    enum CardType {
        case howToClaim
        case caution
    }
    
    fileprivate let rootFlexContainer = UIView()
    
    private let numberCircleView = UIView()
    private let numberLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let detailDescriptionsContainer = UIView()
    private var detailDescriptionLabels: [UILabel] = []
    private let phoneIcon = CommonImageView(imageName: "icon_call")
    
    private let cardType: CardType
    private var phoneNumber: String?
    
    init(cardType: CardType) {
        self.cardType = cardType
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // 카드 사이즈 고정 설정
        let screenWidth = UIScreen.main.bounds.width
        let cardWidth = screenWidth / 1.4423
        let cardHeight = cardWidth * (186 / 260)
        frame.size = CGSize(width: cardWidth, height: cardHeight)
        
        rootFlexContainer.backgroundColor = .white
        rootFlexContainer.layer.cornerRadius = 12
        rootFlexContainer.addDropShadow()
        
        let circleColor: UIColor = cardType == .howToClaim ? .blue5 : .red5
        
        numberCircleView.backgroundColor = circleColor
        numberCircleView.layer.cornerRadius = 15
        
        descriptionLabel.numberOfLines = 0
        
        phoneIcon.contentMode = .scaleAspectFit
        phoneIcon.isHidden = true
        phoneIcon.isUserInteractionEnabled = true
        
        // 접근성 설정 추가
        phoneIcon.accessibilityLabel = "고객센터 전화하기"
        phoneIcon.accessibilityTraits = .button
        phoneIcon.accessibilityHint = "고객센터에 전화를 겁니다"
        
        // 전화 아이콘에 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(phoneIconTapped))
        phoneIcon.addGestureRecognizer(tapGesture)
        
        setupLayout()
    }
    
    @objc private func phoneIconTapped() {
        guard let phoneNumber = phoneNumber else { return }
        
        // 전화번호에서 하이픈과 공백 제거
        let cleanedNumber = phoneNumber.replacingOccurrences(of: "[\\s-]", with: "", options: .regularExpression)
        
        // 탭 시각적 피드백 제공
        UIView.animate(withDuration: 0.1, animations: {
            self.phoneIcon.alpha = 0.5
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.phoneIcon.alpha = 1.0
            }
        })
        
        if let url = URL(string: "tel://\(cleanedNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func setupLayout() {
        addSubview(rootFlexContainer)
        rootFlexContainer.flex
            .direction(.column)
            .paddingHorizontal(20)
            .paddingVertical(24)
            .define { flex in
                flex.addItem()
                    .direction(.column)
                    .alignItems(.start)
                    .define { flex in
                        flex.addItem(numberCircleView)
                            .size(30)
                            .justifyContent(.center)
                            .alignItems(.center)
                            .define { flex in
                                flex.addItem(numberLabel)
                            }
                        
                        flex.addItem(descriptionLabel)
                            .marginTop(16)
                            
                        flex.addItem(detailDescriptionsContainer)
                            .marginTop(6)
                    }
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 카드 사이즈 유지
        let screenWidth = UIScreen.main.bounds.width
        let cardWidth = screenWidth / 1.4423
        let cardHeight = cardWidth * (186 / 260)
        
        // 세부사항이 있는 경우 높이 조정 (자동으로 FlexLayout에서 조정)
        rootFlexContainer.flex.width(cardWidth)
        rootFlexContainer.flex.height(cardHeight)
        
        
        // 컨테이너를 전체 뷰에 맞춤
        rootFlexContainer.pin.all()
        
        // 수동으로 레이아웃 계산
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        // 직접 numberLabel을 중앙에 배치
        numberLabel.pin.center(to: numberCircleView.anchor.center)
    }
    
    func configure(number: Int, description: String, detailDescriptions: [String] = []) {
        numberLabel.text = "\(number)"
        let textColor: UIColor = cardType == .howToClaim ? .blue50Default : .red50Default
        styleLabel(for: numberLabel, fontStyle: .headline1, textColor: textColor, alignment: .center)
        
        descriptionLabel.text = description
        styleLabel(for: descriptionLabel, fontStyle: .body1, textColor: .black, alignment: .left)
        
        // 기존 세부사항 레이블 제거
        detailDescriptionLabels.forEach { $0.removeFromSuperview() }
        detailDescriptionLabels.removeAll()
        
        // 세부사항이 있는 경우에만 표시
        if !detailDescriptions.isEmpty {
            detailDescriptionsContainer.flex.define { flex in
                for (index, detailText) in detailDescriptions.enumerated() {
                    if detailText.contains("고객센터 : 1566 - 5520") {
                        // 전화번호 저장
                        let pattern = "\\d+\\s*-\\s*\\d+"
                        if let range = detailText.range(of: pattern, options: .regularExpression) {
                            phoneNumber = String(detailText[range])
                        } else {
                            // 직접 하드코딩된 번호 사용 (fallback)
                            phoneNumber = "15665520"
                        }
                        
                        let containerView = UIView()
                        let detailLabel = UILabel()
                        detailLabel.text = detailText
                        detailLabel.numberOfLines = 0
                        styleLabel(for: detailLabel, fontStyle: .caption1, textColor: .gray120, alignment: .left)
                        
                        containerView.flex.direction(.row).alignItems(.center).gap(4).define { flex in
                            flex.addItem(detailLabel)
                            flex.addItem(phoneIcon).size(14)
                        }
                        
                        flex.addItem(containerView)
                            .marginTop(index == 0 ? 0 : 4)
                        
                        phoneIcon.isHidden = false
                        detailDescriptionLabels.append(detailLabel)
                    } else {
                        let detailLabel = UILabel()
                        detailLabel.text = detailText
                        detailLabel.numberOfLines = 0
                        styleLabel(for: detailLabel, fontStyle: .caption1, textColor: .gray120, alignment: .left)
                        
                        flex.addItem(detailLabel)
                            .marginTop(index == 0 ? 0 : 4)
                        
                        detailDescriptionLabels.append(detailLabel)
                    }
                }
            }
            detailDescriptionsContainer.isHidden = false
        } else {
            detailDescriptionsContainer.isHidden = true
        }
        
        setNeedsLayout()
    }
}

#Preview {
    let view = WinnerGuideCardView(cardType: .howToClaim)
    view.configure(
        number: 1, 
        description: "당첨번호와 일치하는지 먼저 확인해요.\n당첨번호 확인은 로또메이트 앱에서 가능합니다.",
        detailDescriptions: [
            "※ 당첨번호 확인은 로또 발표일 이후에 가능합니다.",
            "※ 로또 추첨은 매주 토요일 오후에 진행됩니다.",
            "※ 더 많은 당첨 정보를 확인하세요."
        ]
    )
    return view
} 
