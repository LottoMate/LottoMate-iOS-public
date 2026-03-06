//
//  ProgressBarView.swift
//  LottoMate
//
//  Created by Cursor on 6/14/24.
//

import UIKit
import FlexLayout
import PinLayout

class ProgressBarView: UIView {
    // MARK: - Properties
    private let totalSteps: Int
    private var currentStep: Int = 1
    
    // MARK: - UI Components
    private let containerView = UIView()
    private var progressIndicators: [UIView] = []
    
    // MARK: - Initializer
    init(totalSteps: Int = 5) {
        self.totalSteps = totalSteps
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        addSubview(containerView)
        
        // 프로그레스 인디케이터 생성
        for i in 0..<totalSteps {
            let indicator = UIView()
            indicator.layer.cornerRadius = 2
            indicator.backgroundColor = i == 0 ? .red50Default : .gray20
            progressIndicators.append(indicator)
        }
        
        setupLayout()
    }
    
    private func setupLayout() {
        containerView.flex.direction(.row)
            .justifyContent(.spaceBetween)
            .define { flex in
                for indicator in progressIndicators {
                    flex.addItem(indicator)
                        .height(4)
                        .width(UIScreen.main.bounds.width / CGFloat(totalSteps) - 11)
                }
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
    
    // MARK: - Public Methods
    func updateProgress(to step: Int) {
        guard step > 0 && step <= totalSteps else { return }
        
        currentStep = step
        
        // 모든 인디케이터 업데이트
        for (index, indicator) in progressIndicators.enumerated() {
            if index < step {
                indicator.backgroundColor = .red50Default
            } else {
                indicator.backgroundColor = .gray20
            }
        }
    }
} 
