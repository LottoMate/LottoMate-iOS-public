//
//  BannerView.swift
//  LottoMate
//
//  Created by Mirae on 8/27/24.
//

import UIKit
import PinLayout
import FlexLayout

protocol BannerNavigationDelegate: AnyObject {
    func navigate(to bannerType: BannerType)
}

class BannerView: UIView {
    fileprivate let rootFlexContainer = UIView()
    private let bannerType: BannerType
    weak var navigationDelegate: BannerNavigationDelegate?
//    private let tapAction: BannerAction
    
    /// 배너에 들어가는 캐릭터 이미지
    var bannerImage = UIImageView()
    /// 배너 타이틀 레이블
    let titleTextLabel = UILabel()
    /// 배너 바디 레이블
    let bodyTextLabel = UILabel()
    
    init(bannerType: BannerType, navigationDelegate: BannerNavigationDelegate) {
        self.bannerType = bannerType
        self.navigationDelegate = navigationDelegate
//        self.tapAction = action
        
        super.init(frame: .zero)
        
        let config = bannerType.configuration
        setupBanner(with: config)
        setupTapGesture()
        
        addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.row)
            .justifyContent(.spaceBetween)
            .paddingTop(15)
            .paddingLeft(20)
            .paddingRight(18)
            .paddingBottom(7)
            .define { flex in
                flex.addItem().direction(.column)
                    .define { flex in
                        flex.addItem(titleTextLabel)
                            .marginBottom(4)
                        flex.addItem(bodyTextLabel)
                    }
                flex.addItem(bannerImage)
            }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBanner(with config: BannerConfiguration) {
        backgroundColor = config.backgroundColor
        layer.cornerRadius = 16
        
        titleTextLabel.text = config.title
        titleTextLabel.numberOfLines = 2
        titleTextLabel.frame = CGRect(x: 0, y: 0, width: 94, height: 48)
        styleLabel(for: titleTextLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
        bodyTextLabel.text = config.body
        styleLabel(for: bodyTextLabel, fontStyle: .caption1, textColor: .gray90, alignment: .left)
        
        if let imageName = config.imageName {
            bannerImage.image = UIImage(named: imageName)
            bannerImage.contentMode = .scaleAspectFit
            bannerImage.frame = CGRect(x: 0, y: 0, width: config.imageSize.width, height: config.imageSize.height)
        } else {
            bannerImage.image = UIImage(named: "banner_winners")
            bannerImage.contentMode = .scaleAspectFit
            bannerImage.frame = CGRect(x: 0, y: 0, width: 122, height: 76)
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        navigationDelegate?.navigate(to: bannerType)
    }
}
