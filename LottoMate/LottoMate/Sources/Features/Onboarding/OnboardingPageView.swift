//
//  OnboardingPageView.swift
//  LottoMate
//
//  Created by Cursor on 6/14/24.
//

import UIKit
import FlexLayout
import PinLayout

class OnboardingPageView: UIView {
    // MARK: - Properties
    private let step: Int
    private let title: String
    private let imageName: String
    
    // MARK: - UI Components
    private let containerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Initializer
    init(step: Int, title: String, imageName: String) {
        self.step = step
        self.title = title
        self.imageName = imageName
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .white
        addSubview(containerView)
        
        // 타이틀 설정
        titleLabel.text = title
        styleLabel(for: titleLabel, fontStyle: .title3, textColor: .black, alignment: .center)
        
        // 이미지 설정
        if let image = UIImage(named: imageName) {
            imageView.image = image
        }
        
        setupLayout()
    }
    
    private func setupLayout() {
        containerView.flex
            .direction(.column)
            .gap(44)
            .alignItems(.center)
            .justifyContent(.center)
            .define { flex in
            // 타이틀
            flex.addItem(titleLabel)
                .alignSelf(.center)
            
            // 이미지
            flex.addItem(imageView)
                .width(UIScreen.main.bounds.width / 1.6025)
                .alignSelf(.center)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
} 
