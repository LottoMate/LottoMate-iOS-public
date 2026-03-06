import UIKit
import FlexLayout
import PinLayout

class WithdrawalViewController: BaseViewController {
    private let withdrawalView = WithdrawalView()
    
    private let bottomButtonContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        return container
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.white.withAlphaComponent(0.7).cgColor,
            UIColor.white.withAlphaComponent(0.9).cgColor,
            UIColor.white.cgColor
        ]
        layer.locations = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return layer
    }()
    
    private let cancelButton: UIButton = {
        let button = StyledButton(
            title: "취소",
            buttonStyle: .assistive(.large, .active),
            cornerRadius: 8,
            verticalPadding: 12,
            horizontalPadding: 0
        )
        return button
    }()
    
    private let confirmButton = StyledButton(
        title: "확인",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    private let inactiveConfirmButton = StyledButton(
        title: "확인",
        buttonStyle: .solid(.large, .inactive),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    private lazy var confirmButtonContainer: UIView = {
        let view = UIView()
        view.flex.define { flex in
            flex.addItem(confirmButton).width(100%).position(.absolute)
            flex.addItem(inactiveConfirmButton).width(100%).position(.absolute)
        }
        confirmButton.isHidden = true
        inactiveConfirmButton.isHidden = false
        return view
    }()
    
    override func loadView() {
        view = withdrawalView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupBottomButtons()
        withdrawalView.delegate = self
    }
    
    private func setupNavBar() {
        let config = NavBarConfiguration(
            style: .backButtonWithTitle,
            title: "회원탈퇴",
            buttonTintColor: .gray100
        )
        configureNavBar(config)
    }
    
    private func setupBottomButtons() {
        view.addSubview(bottomButtonContainer)
        
        bottomButtonContainer.layer.insertSublayer(gradientLayer, at: 0)
        
        bottomButtonContainer.flex
            .direction(.row)
            .gap(15)
            .justifyContent(.spaceEvenly)
            .paddingHorizontal(20)
            .paddingVertical(36)
            .define { flex in
                flex.addItem(cancelButton)
                    .grow(1)
                    .basis(0)
                    .backgroundColor(.white)

                flex.addItem(confirmButtonContainer)
                    .grow(1)
                    .basis(0)
            }
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func confirmButtonTapped() {
        withdrawalView.delegate?.didTapWithdrawalButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bottomButtonContainer.pin
            .bottom()
            .horizontally()
            .height(120)
        
        bottomButtonContainer.flex.layout(mode: .adjustHeight)
        
        // Calculate gradient height (only for the top portion)
        let gradientHeight = bottomButtonContainer.bounds.height - 84
        
        // Set gradient frame to only cover the top portion
        gradientLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: bottomButtonContainer.bounds.width,
            height: gradientHeight
        )
        
        // Add a solid white background view for the bottom portion
        if bottomButtonContainer.viewWithTag(999) == nil {
            let solidWhiteView = UIView()
            solidWhiteView.tag = 999
            solidWhiteView.backgroundColor = .white
            bottomButtonContainer.insertSubview(solidWhiteView, at: 0)
            solidWhiteView.frame = CGRect(
                x: 0,
                y: gradientHeight,
                width: bottomButtonContainer.bounds.width,
                height: 84
            )
        } else if let solidWhiteView = bottomButtonContainer.viewWithTag(999) {
            solidWhiteView.frame = CGRect(
                x: 0,
                y: gradientHeight,
                width: bottomButtonContainer.bounds.width,
                height: 84
            )
        }
    }
    
    private func showWithdrawalCompletionPopup() {
        let completionView = WithdrawalCompletionView.show()
        completionView.onConfirm = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension WithdrawalViewController: WithdrawalViewDelegate {
    func didTapWithdrawalButton() {
        showWithdrawalCompletionPopup()
    }
    
    func updateButtonState(isEnabled: Bool) {
        confirmButton.isHidden = !isEnabled
        inactiveConfirmButton.isHidden = isEnabled
    }
} 
