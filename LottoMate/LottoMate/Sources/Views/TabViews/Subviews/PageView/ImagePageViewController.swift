//
//  ImagePageViewController.swift
//  LottoMate
//
//  Created by Mirae on 9/12/24.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxGesture

class ImagePageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    fileprivate let rootFlexContainer = UIView()
    
    var pageViewController: UIPageViewController!
    var pageControl = UIPageControl()
    
    // 보여줄 이미지 배열 (로컬 이미지명 또는 URL)
    var images: [String] = []
    
    // 서버 이미지 URL을 사용하는지 여부
    private var usingServerImages = false
    
    // 이미지 뷰의 비율
    let imageAspectRatio: CGFloat = 1.33
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImagePageView()
    }
    
    private func setupImagePageView() {
        // 페이지 뷰 컨트롤러 설정
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // 이미지가 있는 경우에만 페이지 뷰 설정
        if !images.isEmpty {
            // 첫 번째 뷰 컨트롤러로 시작
            let startingViewController = getViewControllerAtIndex(0)!
            
            pageViewController.setViewControllers([startingViewController], direction: .forward, animated: false, completion: nil)
        }
        
        // 페이지 뷰 컨트롤러 추가
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        // 페이지 뷰 컨트롤러의 크기 설정
        setupPageViewControllerSize()
        
        // 페이지 컨트롤 추가
        setupPageControl()
        
        view.backgroundColor = .white
        
        view.addSubview(rootFlexContainer)
        rootFlexContainer.flex.define { flex in
            flex.addItem(pageViewController.view)
                .border(1, .gray20)
            flex.addItem(pageControl).height(32)
        }
    }
    
    // 서버 이미지 URL로 설정하는 메서드
    func configureWithImageURLs(_ imageURLs: [String]) {
        guard !imageURLs.isEmpty else { return }
        
        self.images = imageURLs
        self.usingServerImages = true
        
        // 페이지 컨트롤 업데이트
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        
        // 첫 번째 이미지로 시작
        if let startingViewController = getViewControllerAtIndex(0) {
            pageViewController.setViewControllers([startingViewController], direction: .forward, animated: false, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.top(view.safeAreaInsets.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    // 페이지 뷰 컨트롤러의 크기를 화면 너비에 맞추고 비율에 따라 높이를 설정
    func setupPageViewControllerSize() {
        let screenWidth = UIScreen.main.bounds.width
        let pageViewHeight = screenWidth / imageAspectRatio
        
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: pageViewHeight)
        pageViewController.view.layer.cornerRadius = 16
        pageViewController.view.layer.masksToBounds = true
        if let parentView = pageViewController.view.superview {
            parentView.clipsToBounds = false // 부모 뷰가 잘리지 않도록 설정
        }
    }
    
    // 페이지 컨트롤 설정 (이미지 위에 오버레이)
    func setupPageControl() {
        let screenWidth = UIScreen.main.bounds.width
//        let pageViewHeight = screenWidth / imageAspectRatio
        let scale: CGFloat = 0.8
        
        pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 32))
        pageControl.transform = CGAffineTransform.init(scaleX: scale, y: scale)
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        pageControl.currentPageIndicatorTintColor = .red50Default
        
        pageControl.isUserInteractionEnabled = false
    }
    
    // 현재 페이지 인덱스에 맞는 뷰 컨트롤러를 반환
    func getViewControllerAtIndex(_ index: Int) -> ImageContentViewController? {
        if index >= images.count || index < 0 {
            return nil
        }
        
        let contentVC = ImageContentViewController()
        if usingServerImages {
            contentVC.imageURL = images[index]
        } else {
            contentVC.imageName = images[index]
        }
        contentVC.pageIndex = index
        return contentVC
    }
    
    // 다음 뷰 컨트롤러 제공 (스와이프)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let contentVC = viewController as! ImageContentViewController
        var index = contentVC.pageIndex
        index += 1
        
        return getViewControllerAtIndex(index)
    }
    
    // 이전 뷰 컨트롤러 제공 (스와이프)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let contentVC = viewController as! ImageContentViewController
        var index = contentVC.pageIndex
        index -= 1
        
        return getViewControllerAtIndex(index)
    }
    
    // 페이지 변경 시 호출
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let currentVC = pageViewController.viewControllers![0] as! ImageContentViewController
            pageControl.currentPage = currentVC.pageIndex
        }
    }
}

#Preview {
    ImagePageViewController()
}
