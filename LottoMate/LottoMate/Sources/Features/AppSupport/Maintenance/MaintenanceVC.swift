//
//  NetworkErrorVC.swift
//  LottoMate
//
//  Created by AI Assistant on 4/13/25.
//  점검 중 뷰

import UIKit
import FlexLayout
import PinLayout

class MaintenanceVC: BaseViewController {
    // MARK: - UI Components
    private let containerView = UIView()
    
    private let errorImageView = UIImageView()
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
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
        errorImageView.image = UIImage(named: "pochi_safety_cone_square")
        
        titleLabel.text = "더 좋은 행운이 오도록\r점검하고 있어요"
        titleLabel.numberOfLines = 2
        styleLabel(for: titleLabel, fontStyle: .headline1, textColor: .gray140, alignment: .center)
        
        descriptionLabel.text = "점검시간 : 고쳐질 때까지"
        descriptionLabel.numberOfLines = 2
        styleLabel(for: descriptionLabel, fontStyle: .label1, textColor: .gray140, alignment: .center)
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
                    .marginBottom(16)
                
                flex.addItem(titleLabel)
                    .marginBottom(4)
                
                flex.addItem(descriptionLabel)
            }
    }
    
    // MARK: - Actions
    @objc private func actionButtonTapped() {
        if let action = buttonAction {
            action()
        } else {
            // Refresh the current view instead of navigating back
            setupUI()
            // You could add network retry logic here
        }
    }
} 
