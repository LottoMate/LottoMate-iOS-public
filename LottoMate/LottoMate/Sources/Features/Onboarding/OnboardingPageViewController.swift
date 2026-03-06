//
//  OnboardingPageViewController.swift
//  LottoMate
//
//  Created by Cursor on 6/14/24.
//

import UIKit
import FlexLayout
import PinLayout

class OnboardingPageViewController: UIViewController {
    // MARK: - Properties
    let step: Int
    let titleLabel: String
    let imageName: String
    
    // MARK: - UI Components
    private let pageView: OnboardingPageView
    
    // MARK: - Initializer
    init(step: Int, title: String, imageName: String) {
        self.step = step
        self.titleLabel = title
        self.imageName = imageName
        self.pageView = OnboardingPageView(step: step, title: title, imageName: imageName)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.addSubview(pageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageView.pin.all()
    }
} 
