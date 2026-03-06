//
//  QrScannerOverlayView.swift
//  LottoMate
//
//  Created by Mirae on 12/6/24.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxGesture

class QrScannerOverlayView: UIView {
    var disposeBag = DisposeBag()
    
    fileprivate let rootFlexContainer = UIView()
    
    private let frameImage = CommonImageView(imageName: "frame")
    private let transparentSize: CGFloat = 160
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "로또의 QR코드를 스캔해요"
        styleLabel(for: label, fontStyle: .body1, textColor: .white)
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .black.withAlphaComponent(0.8)
        
        addSubview(rootFlexContainer)
        setupTransparentHole()
        
        rootFlexContainer.flex
            .justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                flex.addItem(frameImage)
                    .size(180)
                
                flex.addItem(messageLabel)
                    .position(.absolute)
            }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout()
        updateMaskLayer()
        
        messageLabel.pin.below(of: frameImage, aligned: .center)
            .marginTop(16)
    }
    
    private func setupTransparentHole() {
        layer.mask = CAShapeLayer()
        updateMaskLayer()
    }
    
    private func updateMaskLayer() {
        guard let maskLayer = layer.mask as? CAShapeLayer else { return }
        
        let path = UIBezierPath(rect: bounds)
        
        let centerX = bounds.midX
        let centerY = bounds.midY
        let origin = CGPoint(x: centerX - transparentSize/2, y: centerY - transparentSize/2)
        
        let transparentPath = UIBezierPath(rect: CGRect(origin: origin, size: CGSize(width: transparentSize, height: transparentSize)))
        path.append(transparentPath)
        path.usesEvenOddFillRule = true
        
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
    }
}

#Preview {
    let view = QrScannerOverlayView()
    return view
}

