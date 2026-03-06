//
//  ForcedAppUpdateVC.swift
//  LottoMate
//
//  Created by Mirae on 4/8/25.
//

import UIKit

class ForcedAppUpdateVC: UIViewController {
    private let containerView = UIView()
    
    private let statusBarHeight = DeviceMetrics.statusBarHeight
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "로또메이트가\r새로 업데이트 했어요"
        label.numberOfLines = 2
        styleLabel(for: label, fontStyle: .title2, textColor: .black, alignment: .center)
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.text = "더 편리한 로또메이트를 사용하기 위해\r앱 스토어로 이동해요"
        label.numberOfLines = 2
        styleLabel(for: label, fontStyle: .body1, textColor: .black, alignment: .center)
        return label
    }()
    
    private let image = CommonImageView(imageName: "pochi_safety_cone")
    
    private let updateButton = StyledButton(
        title: "업데이트 하기",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupView()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.top().horizontally().bottom()
        containerView.flex.layout()
    }
    
    private func setupView() {
        view.addSubview(containerView)
        
        let topMargin = (UIScreen.main.bounds.height - statusBarHeight) / 5.4084
        
        containerView.flex
            .direction(.column)
            .paddingHorizontal(20)
            .backgroundColor(.white)
            .paddingTop(statusBarHeight + topMargin)
            .define { flex in
                flex.addItem()
                    .direction(.column)
                    .gap(18)
                    .define { flex in
                        flex.addItem(titleLabel)
                        
                        flex.addItem(image)
                            .width(UIScreen.main.bounds.width - 40)
                            .alignSelf(.center)
                            .aspectRatio(of: image)
                        
                        flex.addItem(subLabel)
                    }
                // Spacer
                flex.addItem().grow(1)
                
                flex.addItem(updateButton)
                    .marginBottom(36)
            }
    }
    
    private func setupActions() {
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
    }
    
    @objc private func updateButtonTapped() {
        // UpdateCheckService를 통해 앱스토어로 이동
        UpdateCheckService.shared.openAppStore()
    }
}
