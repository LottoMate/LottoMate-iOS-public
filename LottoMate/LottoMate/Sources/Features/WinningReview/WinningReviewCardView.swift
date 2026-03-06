//
//  ThumbnailCardView.swift
//  LottoMate
//
//  Created by Mirae on 9/13/24.
//

import UIKit
import PinLayout
import FlexLayout
import SkeletonView
import Kingfisher

class WinningReviewCardView: UIView {
    enum CardSize {
        case large   // 홈화면용
        case small   // 라운지, 당첨후기 상세 뷰용
        
        var height: CGFloat {
            switch self {
            case .large: return 278
            case .small: return 202
            }
        }
        var width: CGFloat {
            switch self {
            case .large: return 322
            case .small: return 220
            }
        }
        var titleFont: Typography {
            switch self {
            case .large: return .headline1
            case .small: return .label2
            }
        }
        var imageHeight: CGFloat {
            switch self {
            case .large: return 58
            case .small: return 50
            }
        }
    }
    private let cardSize: CardSize
    fileprivate let rootFlexContainer = UIView()
    
    var imageView = UIImageView()
    var imageName: String = ""
    
    let lotteryInfoLabel = UILabel()
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    
    private var reviewNo: Int?
    var onTap: ((Int) -> Void)?
    
    init(size: CardSize = .small) {
        self.cardSize = size
        super.init(frame: .zero)
        setupView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        rootFlexContainer.addGestureRecognizer(tapGesture)
        rootFlexContainer.isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        if let reviewNo = reviewNo {
            onTap?(reviewNo)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        rootFlexContainer.backgroundColor = .white
        rootFlexContainer.layer.cornerRadius = 16
        rootFlexContainer.addDropShadow()
        
        setupLabels()
        setupImageView()
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(rootFlexContainer)
        rootFlexContainer.flex
            .direction(.column)
            .height(cardSize.height)
            .maxWidth(cardSize.width)
            .define { flex in
                flex.addItem(imageView)
                    .height(cardSize.imageHeight%)
                    .minWidth(0)
                    .maxWidth(.infinity)
                
                flex.addItem()
                    .direction(.column)
                    .alignItems(.start)
                    .paddingTop(13)
                    .paddingBottom(6)
                    .paddingLeft(16)
                    .paddingRight(57)
                    .define { flex in
                        flex.addItem(lotteryInfoLabel)
                            .width(100%)
                        flex.addItem(titleLabel)
                        flex.addItem(dateLabel)
                    }
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    func setupLabels() {
        lotteryInfoLabel.text = "연금복권 1등"
        lotteryInfoLabel.isSkeletonable = true
        styleLabel(for: lotteryInfoLabel, fontStyle: .caption1, textColor: .gray80, alignment: .left)
        
        titleLabel.text = "사회 초년생 시절부터 꾸준히 구매해서 1등 당첨"
        titleLabel.isSkeletonable = true
        titleLabel.numberOfLines = 2
        styleLabel(for: titleLabel, fontStyle: cardSize.titleFont, textColor: .black, alignment: .left)
        
        dateLabel.text = "YYYY.MM.DD"
        dateLabel.isSkeletonable = true
        styleLabel(for: dateLabel, fontStyle: .caption2, textColor: .gray80, alignment: .left)
    }
    
    func setupImageView() {
        imageView.isSkeletonable = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func configure(with data: WinningReviewListResponse) {
        self.reviewNo = data.reviewNo
        self.lotteryInfoLabel.text = data.reviewPlace
        self.titleLabel.text = data.reviewTitle
        self.dateLabel.text = data.intrvDate.reformatDate
        
        if let thumbnailURL = data.reviewThumb, let url = URL(string: thumbnailURL) {
            imageView.kf.setImage(
                with: url,
                options: [.cacheOriginalImage]
            )
        } else {
            // 이미지 주소가 없는 경우
            imageView.image = UIImage(named: "ch_reviewPlaceholderImage")
        }
    }
    
//    func showLoadingState() {
//        [imageView, lotteryInfoLabel, titleLabel, dateLabel].forEach { view in
//            view?.showAnimatedGradientSkeleton()
//        }
//    }
//    
//    func hideLoadingState() {
//        [imageView, lotteryInfoLabel, titleLabel, dateLabel].forEach { view in
//            view?.hideSkeleton()
//        }
//    }
}

#Preview {
    let view = WinningReviewCardView()
    return view
}
