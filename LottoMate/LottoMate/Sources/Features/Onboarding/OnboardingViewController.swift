//
//  OnboardingViewController.swift
//  LottoMate
//
//  Created by Cursor on 6/14/24.
//

import UIKit
import FlexLayout
import PinLayout

class OnboardingViewController: UIViewController {
    // MARK: - Properties
    private let totalSteps = 5
    private var currentStep = 1
    
    private let onboardingData: [(title: String, image: String)] = [
        ("내 주위에 있는\r로또 명당을 알려줘요", "onboarding_1"),
        ("빠르게 내 로또 당첨을\r확인해요", "onboarding_2"),
        ("생생한 로또 당첨 후기를\r들어보세요", "onboarding_3"),
        ("나만의 행운 번호를\r뽑아봐요", "onboarding_4"),
        ("설레는 로또 당첨,\r로또메이트와 함께 해요", "onboarding_5")
    ]
    
    // MARK: - UI Components
    private let containerView = UIView()
    
    private let progressBarView: ProgressBarView = {
        let progressBar = ProgressBarView(totalSteps: 5)
        return progressBar
    }()
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    
    private lazy var pageViewControllers: [OnboardingPageViewController] = {
        return onboardingData.enumerated().map { index, data in
            OnboardingPageViewController(
                step: index + 1,
                title: data.title,
                imageName: data.image
            )
        }
    }()
    
    private let nextButton = StyledButton(
        title: "다음",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPageViewController()
        setupView()
        addActions()
    }
    
    // MARK: - Setup
    private func setupPageViewController() {
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let firstVC = pageViewControllers.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: false)
        }
    }
    
    private func setupView() {
        view.addSubview(containerView)
        
        containerView.flex
            .direction(.column)
            .define { flex in
                // 프로그레스 바
                flex.addItem(progressBarView)
                    .marginTop(20)
                    .marginHorizontal(19.5)
                    .height(4)
                
                // 페이지 뷰 컨트롤러
                flex.addItem(pageViewController.view)
                    .grow(1)
                    .shrink(1)
                
                // 하단 버튼
                flex.addItem(nextButton)
                    .marginHorizontal(20)
                    .marginBottom(36)
            }
    }
    
    private func addActions() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.top(view.pin.safeArea.top).horizontally().bottom()
        containerView.flex.layout()
    }
    
    // MARK: - Actions
    @objc private func nextButtonTapped() {
        if currentStep < totalSteps {
            currentStep += 1
            updateUI()
            
            // 페이지 전환
            if let currentVC = pageViewController.viewControllers?.first as? OnboardingPageViewController,
               let nextIndex = pageViewControllers.firstIndex(where: { $0.step == currentVC.step + 1 }) {
                pageViewController.setViewControllers([pageViewControllers[nextIndex]], direction: .forward, animated: true)
            }
        } else {
            // 온보딩 완료
            finishOnboarding()
        }
    }
    
    private func updateUI() {
        // 프로그레스 바 업데이트
        progressBarView.updateProgress(to: currentStep)
        
        // 버튼 타이틀 업데이트
        if currentStep == totalSteps {
            nextButton.setTitle("시작하기", for: .normal)
        } else {
            nextButton.setTitle("다음", for: .normal)
        }
    }
    
    private func finishOnboarding() {
        // 온보딩 완료 상태 저장
        OnboardingManager.shared.setOnboardingCompleted(true)
        
        // 루트 뷰 컨트롤러를 PermissionGuideVC로 변경
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
             print("Error: Could not find SceneDelegate.")
            return
        }

        let permissionVC = PermissionGuideVC()
        sceneDelegate.window?.rootViewController = permissionVC
        sceneDelegate.window?.makeKeyAndVisible()
        
        // 선택적 애니메이션
        UIView.transition(with: sceneDelegate.window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingPageViewController else { return nil }
        
        let currentIndex = currentVC.step - 1
        if currentIndex <= 0 {
            return nil
        }
        
        return pageViewControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingPageViewController else { return nil }
        
        let currentIndex = currentVC.step - 1
        if currentIndex >= totalSteps - 1 {
            return nil
        }
        
        return pageViewControllers[currentIndex + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = pageViewController.viewControllers?.first as? OnboardingPageViewController {
            currentStep = currentVC.step
            updateUI()
        }
    }
}
