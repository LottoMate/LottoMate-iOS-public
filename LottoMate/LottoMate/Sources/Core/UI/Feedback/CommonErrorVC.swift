//
//  CommonErrorVC.swift
//  LottoMate
//
//  Created by Mirae on 4/9/25.
//

import UIKit
import FlexLayout
import PinLayout

class CommonErrorVC: BaseViewController {
    // MARK: - UI Components
    private let containerView = UIView()
    
    // Main error illustration - this needs to be updated with the actual downloaded image
    private let errorImageView = UIImageView()
    
    // Error message components from Figma
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // Action button
    private let actionButton = StyledButton(
        title: "이전 화면으로 돌아가기",
        buttonStyle: .solid(.round, .active),
        cornerRadius: 19,
        verticalPadding: 8,
        horizontalPadding: 16
    )
    
    // MARK: - Properties
    private var buttonAction: (() -> Void)?
    
    // MARK: - Initialization
    init(buttonAction: (() -> Void)? = nil) {
        self.buttonAction = buttonAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let config = NavBarConfiguration(
            style: .backButtonOnly,
            buttonTintColor: .gray100
        )
        configureNavBar(config)
        
        setupUI()
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.top().horizontally().bottom()
        containerView.flex.layout()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        errorImageView.contentMode = .scaleAspectFit
        errorImageView.image = UIImage(named: "ch_common_error")
        
        titleLabel.text = "작은 문제가 발생했어요"
        styleLabel(for: titleLabel, fontStyle: .headline1, textColor: .gray140, alignment: .center)
        
        descriptionLabel.text = "행운을 불러오는 중 문제가 발생했습니다\r잠시 후 다시 시도해주세요"
        descriptionLabel.numberOfLines = 2
        styleLabel(for: descriptionLabel, fontStyle: .body2, textColor: .gray140, alignment: .center)
        
        // Button action
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        view.addSubview(containerView)
        
        containerView.flex.direction(.column)
            .alignItems(.center)
            .justifyContent(.center)
            .define { flex in
                let screenWidth = UIScreen.main.bounds.width
                let aspectRatio: CGFloat = 3.125
                let imageSize = screenWidth / aspectRatio
                
                flex.addItem(errorImageView)
                    .size(imageSize)
                    .marginBottom(20)
                
                flex.addItem(titleLabel)
                    .marginBottom(4)
                
                flex.addItem(descriptionLabel)
                    .marginBottom(28)
                
                flex.addItem(actionButton)
                    .width(154)
                    .height(38)
            }
    }
    
    // MARK: - Actions
    @objc private func actionButtonTapped() {
        if let action = buttonAction {
            action()
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}
