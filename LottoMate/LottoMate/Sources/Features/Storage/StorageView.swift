//
//  StorageView.swift
//  LottoMate
//
//  Created by Mirae on 10/24/24.
//

import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import RxSwift
import RxCocoa

class StorageView: UIView, View {
    var disposeBag = DisposeBag()
    fileprivate let rootFlexContainer = UIView()
    
    internal var loadingView: RandomNumbersLoadingView?
    
    private let topMargin: CGFloat = {
        let topMargin = 78.0 // nav bar height 50 + top padding 28
//        let topMargin = DeviceMetrics.statusBarHeight
//        let topMargin = DeviceMetrics.statusWithNavigationBarHeight
        return topMargin
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let storageViewTabButtons: StorageTabButtonsView = {
        let view = StorageTabButtonsView()
        return view
    }()
    
    private let myNumbersView: MyNumbersView = {
        let view = MyNumbersView()
        return view
    }()
    
    private let randomNumbersView: RandomNumbersView = {
        let view = RandomNumbersView()
        return view
    }()
    
    private var tabBarHeight: CGFloat = 0
    
    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
        
        randomNumbersView.delegate = self
        
        rootFlexContainer.flex
            .direction(.column)
            .marginTop(topMargin)
            .define { flex in
//                flex.addItem(storageViewTabButtons)
//                    .marginHorizontal(20)
                
                flex.addItem(contentContainer)
                    .grow(1)
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.top().bottom().left().right()
        rootFlexContainer.pin.top().left().right()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
    }
    
    func bind(reactor: StorageViewReactor) {
        
        storageViewTabButtons.reactor = reactor
        myNumbersView.reactor = reactor
        randomNumbersView.reactor = reactor
        
        reactor.state
            .map { $0.selectedMode }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] viewMode in
                self?.updateContentView(for: viewMode)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.temporaryRandomNumbers }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                // 다음 런루프에서 레이아웃 업데이트 실행
                DispatchQueue.main.async {
                    self?.updateLayoutAndScroll()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateLayoutAndScroll() {
        setNeedsLayout()
        layoutIfNeeded()
        
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        rootFlexContainer.pin.top(topMargin).left().right()
        scrollView.contentSize = rootFlexContainer.frame.size
    }
    
    // MARK: - Private Methods
    private func updateContentView(for mode: StorageViewMode) {
        contentContainer.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        let newView: UIView = {
            // '내 번호' 페이지 임시 제외되어 주석처리
//            switch mode {
//            case .myNumber:
//                return myNumbersView
//            case .randomNumber:
                return randomNumbersView
//            }
        }()
        
        contentContainer.flex.define { flex in
            flex.addItem(newView).grow(1)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func scrollToBottom() {
        // 다음 런루프에서 레이아웃 업데이트 및 스크롤 실행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 레이아웃 강제 업데이트
            self.setNeedsLayout()
            self.layoutIfNeeded()
            
            // rootFlexContainer 크기 재계산
            self.rootFlexContainer.flex.layout(mode: .adjustHeight)
            self.scrollView.contentSize = self.rootFlexContainer.frame.size
            
            // 스크롤을 맨 아래로 이동
            let bottomOffset = CGPoint(
                x: 0,
                y: max(0, self.scrollView.contentSize.height - self.scrollView.bounds.height)
            )
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    func updateTabBarHeight(_ height: CGFloat) {
        self.tabBarHeight = height
        
        rootFlexContainer.flex
            .paddingBottom(tabBarHeight - 3) // 실제 tab bar height 보다 높아서 -3
        
        setNeedsLayout()
        layoutIfNeeded()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
    }
    
    /// MyNumbersView 강제 업데이트
    func forceUpdateMyNumbersView() {
        myNumbersView.forceUpdateView()
    }
}

extension StorageView: LoadingDisplayable {}

extension StorageView: RandomNumbersViewDelegate {
    func randomNumbersViewDidUpdateContent() {
//        scrollToBottom()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        rootFlexContainer.pin.top(topMargin).left().right()
        scrollView.contentSize = rootFlexContainer.frame.size
    }
}

#Preview {
    let view = StorageView()
    return view
}
