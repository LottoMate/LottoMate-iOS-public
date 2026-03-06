//
//  LocationPermissionView.swift
//  LottoMate
//
//  Created by Mirae on 3/10/25.
//

import UIKit
import FlexLayout
import PinLayout

class LocationPermissionView: UIView {
    
    private let dimView = UIView()
    private let contentView = UIView()
    
    private let denyButton = StyledButton(
        title: "사용 안 함",
        buttonStyle: .assistive(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    private let settingsButton = StyledButton(
        title: "설정으로 이동",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    // 콜백
    var onDeny: (() -> Void)?
    var onOpenSettings: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // dim 뷰 설정
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        addSubview(dimView)
        
        // 콘텐츠 뷰 설정
        addSubview(contentView)
        
        // 레이블 생성
        let label = UILabel()
        label.text = "내 위치를 보려면\r앱 설정 > 위치 정보 사용을 허용해야\r확인할 수 있어요"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black, alignment: .center)
        label.numberOfLines = 3
        
        // 콘텐츠 뷰 레이아웃 설정
        contentView.flex.direction(.column)
            .alignItems(.center)
            .gap(24)
            .paddingTop(28)
            .paddingHorizontal(20)
            .paddingBottom(20)
            .backgroundColor(.white)
            .cornerRadius(12)
            .define { flex in
                flex.addItem(label)
                
                flex.addItem()
                    .direction(.row)
                    .gap(10)
                    .width(100%)
                    .define { flex in
                        flex.addItem(denyButton)
                            .grow(1)
                            .basis(0)
                        flex.addItem(settingsButton)
                            .grow(1)
                            .basis(0)
                    }
            }
            
        // 진입 애니메이션을 위한 초기 상태 설정
//        contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        contentView.alpha = 0
        dimView.alpha = 0
    }
    
    private func setupActions() {
        denyButton.addTarget(self, action: #selector(denyButtonTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
    }
    
    @objc private func denyButtonTapped() {
        dismiss {
            self.onDeny?()
        }
    }
    
    @objc private func settingsButtonTapped() {
        dismiss {
            self.onOpenSettings?()
        }
    }
    
    func show() {
        layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.dimView.alpha = 1
            self.contentView.alpha = 1
            self.contentView.transform = .identity
        })
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.dimView.alpha = 0
            self.contentView.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            completion?()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // dim 뷰가 전체 화면을 덮도록 설정
        dimView.pin.all()
        
        // 콘텐츠 뷰 레이아웃 구성
        contentView.pin.width(310).height(208).center()
        contentView.flex.layout(mode: .adjustHeight)
    }
    
    // 윈도우에 표시하는 편리한 메서드
    static func show(in windowScene: UIWindowScene? = nil) -> LocationPermissionView {
        let permissionView = LocationPermissionView()
        
        if let window = WindowManager.findKeyWindow() {
            window.addSubview(permissionView)
            permissionView.frame = window.bounds
            permissionView.show()
        }
        
        return permissionView
    }
}
