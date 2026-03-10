//
//  TextOnlyToast.swift
//  LottoMate
//
//  Created by Mirae on 11/7/24.
//

import UIKit
import FlexLayout

class ToastView: UIView {
    
    // MARK: - Properties
    private let label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // MARK: - Initialization
    init(message: String) {
        super.init(frame: .zero)
        setupLabel(with: message)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupLabel(with message: String) {
        label.text = message
        label.numberOfLines = 2
        styleLabel(for: label, fontStyle: .label2, textColor: .white, alignment: .center)
    }
    
    private func setupLayout() {
        self.flex
            .justifyContent(.center)
            .alignItems(.center)
            .paddingVertical(12)
            .paddingHorizontal(32)
            .define { flex in
                flex.addItem(label)
            }
            .backgroundColor(UIColor.black.withAlphaComponent(0.74))
            .cornerRadius(8)
    }
    
    // MARK: - Show Toast
    static func show(
        message: String,
        duration: TimeInterval = 3.0,
        horizontalPadding: CGFloat = 40,
        topOffset: CGFloat = 68,  // 추가적인 상단 오프셋
        height: CGFloat? = nil
    ) {
        // 키 윈도우 찾기
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let toastView = ToastView(message: message)
        
        // 초기 프레임 설정
        let toastWidth: CGFloat = window.frame.width - horizontalPadding
        
        let estimatedHeight: CGFloat = height ?? 44
        
        toastView.frame = CGRect(x: 16, y: 0,
                               width: toastWidth, height: estimatedHeight)
        
        window.addSubview(toastView)
        
        // 레이아웃 적용
        toastView.flex.layout()
        
        // 상태 바 높이 가져오기
        let statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            statusBarHeight = windowScene.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        // status bar height + topOffset을 적용
        let totalTopPadding = statusBarHeight + topOffset
        toastView.center.x = window.center.x
        toastView.frame.origin.y = totalTopPadding
        
        // 애니메이션
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
}
