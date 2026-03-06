//
//  SplashView.swift
//  LottoMate
//
//  Created by Mirae on 3/24/25.
//

import UIKit
import FlexLayout
import PinLayout

class SplashViewController: UIViewController {
    // MARK: - Properties
    fileprivate let rootFlexContainer = UIView()
    private let logoImageNames = ["logo_splash_first", "logo_splash_second", "logo_splash_third", "logo_splash_fourth"]
    private var currentImageIndex = 0
    private var animationRepeatCount = 0
    private let animationDuration = 0.35
    private let totalRepeats = 2
    
    private let titleText: UILabel = {
       let label = UILabel()
        label.text = "행운을 불러오는"
        styleLabel(for: label, fontStyle: .headline1, textColor: .gray120)
        return label
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo_splash_first"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let pochiImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ch_splash"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let topMargin = UIScreen.main.bounds.height / 4.4444

        view.addSubview(rootFlexContainer)
        rootFlexContainer.flex
            .direction(.column)
            .alignItems(.center)
            .backgroundColor(.white)
            .marginTop(topMargin)
            .define { flex in
                flex.addItem(titleText)
                    .height(28)
                    .marginBottom(12.92)
                flex.addItem(logoImageView)
                    .width(203.66)
                    .height(28.4)
                    .marginBottom(34.68)
                flex.addItem(pochiImageView)
                    .size(234)
            }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.top(view.safeAreaInsets.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLogoAnimation()
    }

    private func startLogoAnimation() {
        guard animationRepeatCount < totalRepeats else {
            return
        }

        logoImageView.image = UIImage(named: logoImageNames[currentImageIndex])
        currentImageIndex += 1

        if currentImageIndex >= logoImageNames.count {
            currentImageIndex = 0
            animationRepeatCount += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            self?.startLogoAnimation()
        }
    }
}

