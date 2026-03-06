//
//  TextButtonToastVIew.swift
//  LottoMate
//
//  Created by Mirae on 3/6/25.
//

import UIKit
import FlexLayout

class TextButtonToastView: UIView {
    
    // MARK: - Properties
    private let textButton = StyledButton(title: "오픈 요청하기", buttonStyle: .text(.small, .active))
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // MARK: - Initialization
    init(message: String) {
        super.init(frame: .zero)
        setupLabels(message: message)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupLabels(message: String) {
        // Message label setup
        messageLabel.text = message
        styleLabel(for: messageLabel, fontStyle: .label2, textColor: .white, alignment: .left)
    }
    
    private func setupLayout() {
        self.flex.direction(.row)
            .gap(42)
            .justifyContent(.center)
            .alignItems(.center)
            .paddingVertical(12)
            .paddingHorizontal(32)
            .define { flex in
                flex.addItem(messageLabel)
                flex.addItem(textButton)
            }
            .backgroundColor(UIColor.black.withAlphaComponent(0.74))
            .cornerRadius(8)
    }
    
    // MARK: - Show Toast
    static func show(
        message: String,
        horizontalPadding: CGFloat = 40,
        topOffset: CGFloat = 68
    ) {

        // Find key window
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let toastView = TextButtonToastView(message: message)
        
        // Set initial frame
        let toastWidth: CGFloat = window.frame.width - horizontalPadding
        let estimatedHeight: CGFloat = 44
        toastView.frame = CGRect(x: 16, y: 0,
                               width: toastWidth, height: estimatedHeight)
        
        window.addSubview(toastView)
        
        // Apply layout
        toastView.flex.layout()
        
        // Get status bar height
        let statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            statusBarHeight = windowScene.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        // Apply status bar height + topOffset
        let totalTopPadding = statusBarHeight + topOffset
        toastView.center.x = window.center.x
        toastView.frame.origin.y = totalTopPadding
        
        // Animation
        toastView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1
        })
    }
    
    // MARK: - Button Action
    static func showWithAction(
        buttonText: String,
        buttonColor: UIColor = .systemBlue,
        message: String,
        duration: TimeInterval = 3.0,
        horizontalPadding: CGFloat = 40,
        topOffset: CGFloat = 68,
        buttonAction: @escaping () -> Void
    ) {
        // Find key window
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let toastView = TextButtonToastView(message: message)
        
        // Set initial frame
        let toastWidth: CGFloat = window.frame.width - horizontalPadding
        let estimatedHeight: CGFloat = 44
        toastView.frame = CGRect(x: 16, y: 0,
                               width: toastWidth, height: estimatedHeight)
        
        window.addSubview(toastView)
        
        // Apply layout
        toastView.flex.layout()
        
        // Get status bar height
        let statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            statusBarHeight = windowScene.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        // Apply status bar height + topOffset
        let totalTopPadding = statusBarHeight + topOffset
        toastView.center.x = window.center.x
        toastView.frame.origin.y = totalTopPadding
        
        // Animation
        toastView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                toastView.alpha = 0
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
    
    // Static hide method to dismiss all visible toasts
    static func hide(animated: Bool = true) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        // Find all toast views in the window
        let toastViews = window.subviews.filter { $0 is TextButtonToastView }
        
        for view in toastViews {
            if let toastView = view as? TextButtonToastView {
                if animated {
                    UIView.animate(withDuration: 0.3, animations: {
                        toastView.alpha = 0
                    }) { _ in
                        toastView.removeFromSuperview()
                    }
                } else {
                    toastView.removeFromSuperview()
                }
            }
        }
    }
}
