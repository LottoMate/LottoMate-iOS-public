//
//  DotIndicatorView.swift
//  LottoMate
//
//  Created by Mirae on 10/02/25.
//

import UIKit
import PinLayout

class DotIndicatorView: UIView {
    private var dots: [UIView] = []
    private let dotSize: CGFloat = 6
    private let dotSpacing: CGFloat = 6
    private let activeColor: UIColor
    private let inactiveColor: UIColor
    
    var currentIndex: Int = 0 {
        didSet {
            updateDotsAppearance()
        }
    }
    
    init(count: Int, activeColor: UIColor = .red50Default, inactiveColor: UIColor = .black.withAlphaComponent(0.2)) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        super.init(frame: .zero)
        setupDots(count: count)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDots(count: Int) {
        // 기존 dot view들을 subview에서 제거
        dots.forEach { $0.removeFromSuperview() }
        dots.removeAll()

        for i in 0..<count {
            let dot = UIView()
            dot.backgroundColor = inactiveColor
            dot.layer.cornerRadius = dotSize / 2
            addSubview(dot)
            dots.append(dot)
        }

        updateDotsAppearance()
    }
    
    private func updateDotsAppearance() {
        for (index, dot) in dots.enumerated() {
            UIView.animate(withDuration: 0.3) {
                dot.backgroundColor = index == self.currentIndex ? self.activeColor : self.inactiveColor
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let totalWidth = CGFloat(dots.count) * dotSize + CGFloat(dots.count - 1) * dotSpacing
        let startX = (bounds.width - totalWidth) / 2
        
        for (index, dot) in dots.enumerated() {
            dot.pin
                .size(dotSize)
                .left(startX + CGFloat(index) * (dotSize + dotSpacing))
                .vCenter()
        }
    }
    
    func updateCount(_ newCount: Int) {
        setupDots(count: newCount)
        setNeedsLayout()
    }
}

