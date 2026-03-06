//
//  WinningReviewHorizontalScrollView.swift
//  LottoMate
//
//  Created by Mirae on 9/13/24.
//

import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import SkeletonView
import RxGesture

protocol WinningReviewListViewDelegate: AnyObject {
    func didTapReviewCard(with reviewNo: Int)
}

class WinningReviewListView: UIView, View {
    private let cardSize: WinningReviewCardView.CardSize
    private let showDotIndicator: Bool
    private let useSharedReactor: Bool
    weak var delegate: WinningReviewListViewDelegate?
    
    var disposeBag = DisposeBag()
    var reactor = WinningReviewReactor.shared
    
    fileprivate let rootFlexContainer = UIView()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        // scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private lazy var dotIndicator: DotIndicatorView = {
        let indicator = DotIndicatorView(count: cards.count)
        return indicator
    }()
    
    private(set) lazy var cards: [WinningReviewCardView] = {
        return (0..<5).map { _ in
            WinningReviewCardView(size: cardSize)
        }
    }()
    
    private lazy var viewHeight: CGFloat = {
        let cardHeight = cardSize == .large ? 278.0 : 202.0
        let verticalPadding: CGFloat = 40  // 상하 여백 (그림자 포함)
        let dotIndicatorHeight: CGFloat = showDotIndicator ? 6 : 0  // dot indicator 높이
        return cardHeight + verticalPadding + dotIndicatorHeight
    }()
    
    private var lastReviewNos: [Int] = []
    
    init(cardSize: WinningReviewCardView.CardSize = .small, showDotIndicator: Bool = true, useSharedReactor: Bool = true) {
        self.cardSize = cardSize
        self.showDotIndicator = showDotIndicator
        self.useSharedReactor = useSharedReactor
        super.init(frame: .zero)
        
        scrollView.delegate = self
        setupCardTapHandlers()
        
        // 공유 리액터 사용 시에만 자동으로 데이터 fetch
        if useSharedReactor {
            reactor.action.onNext(.fetchInitialData)
        }
        
        bind(reactor: reactor)
        
        clipsToBounds = false
        scrollView.clipsToBounds = false
        
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
        
        if showDotIndicator {
            addSubview(dotIndicator)
        }
        
        rootFlexContainer.flex
            .direction(.row)
            .height(viewHeight)
            .alignItems(.center)
            .gap(16)
            .define { flex in
                flex.addItem(cards[0])
                    .marginLeft(20)
                
                for i in 1..<cards.count-1 {
                    flex.addItem(cards[i])
                }
                
                flex.addItem(cards[cards.count-1])
                    .marginRight(20)
            }
    }
    
    private func setupCardTapHandlers() {
        cards.forEach { cardView in
            cardView.onTap = { [weak self] reviewNo in
                guard let self = self else { return }
                
                // 공유 리액터 사용 시에만 리액터 업데이트
                if self.useSharedReactor {
                    self.reactor.action.onNext(.updateWinningReviewList(tappedNo: reviewNo))
                }
                
                let defaults = UserDefaults.standard
                let savedReviewNos = defaults.array(forKey: "tappedReviewNos") as? [Int] ?? []
                var updatedReviewNos = savedReviewNos
                
                if !updatedReviewNos.contains(reviewNo) {
                    updatedReviewNos.append(reviewNo)
                    defaults.set(updatedReviewNos, forKey: "tappedReviewNos")
                }
                
                defaults.synchronize()
                
                self.delegate?.didTapReviewCard(with: reviewNo)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.all()
        rootFlexContainer.pin.top().left().bottom()
        rootFlexContainer.flex.layout(mode: .adjustWidth)
        scrollView.contentSize = rootFlexContainer.frame.size
        
        // Dot indicator를 하단에 배치
        if showDotIndicator {
            dotIndicator.pin
                .bottom(0)
                .left()
                .right()
                .height(6)
        }
    }
}

extension WinningReviewListView {
    func bind(reactor: WinningReviewReactor) {
        reactor.state
            .map { $0.isLoading(.reviewList) }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showSkeletonView()
                } else {
                    self?.hideSkeletonView()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.winningReviewList.sorted { $0.reviewNo > $1.reviewNo } }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] winningReviewList in
                if !winningReviewList.isEmpty {
                    self?.updateWinningReviews(with: winningReviewList)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.currentReviewNos }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] currentReviewNos in
                if !currentReviewNos.isEmpty {
                    print("currentReviewNos: \(currentReviewNos)")
                    self?.lastReviewNos = currentReviewNos
                    // currentReviewNos가 변경될 때마다 즉시 UserDefaults에 저장
                    UserDefaults.standard.set(currentReviewNos, forKey: "LastReviewNos")
                }
            })
            .disposed(by: disposeBag)
        
//        reactor.state
//            .map { $0.errors }
//            .subscribe(onNext: { [weak self] errors in
//                print("errors...\(errors)")
//            })
//            .disposed(by: disposeBag)
    }
    
    func updateWinningReviews(with data: [WinningReviewListResponse]) {
        // 1. 모든 카드를 숨김 처리
        cards.forEach { $0.isHidden = true }
        
        // 2. 데이터 개수만큼만 카드를 표시하고 설정
        for (index, reviewData) in data.enumerated() {
            guard index < cards.count else { break }
            cards[index].isHidden = false
            cards[index].configure(with: reviewData)
        }
        
        // 3. 인디케이터 표시 조건: showDotIndicator가 true이고 데이터가 2개 이상일 때만 표시
        if showDotIndicator {
            dotIndicator.isHidden = data.count <= 1
            // Dot indicator의 개수를 실제 데이터 개수로 업데이트
            if data.count > 1 {
                dotIndicator.updateCount(data.count)
            }
        }
        
        // 4. FlexLayout 다시 계산
        rootFlexContainer.flex.layout(mode: .adjustWidth)
        scrollView.contentSize = rootFlexContainer.frame.size
    }
    
    private func showSkeletonView() {
        cards.forEach { $0.showAnimatedGradientSkeleton() }
    }

    private func hideSkeletonView() {
        cards.forEach { $0.hideSkeleton() }
    }
}

extension WinningReviewListView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
        
        // 현재 보이는 카드 인덱스 계산
        updateCurrentCardIndex()
    }
    
    private func updateCurrentCardIndex() {
        guard showDotIndicator else { return }
        
        let cardWidth = cardSize == .large ? 322.0 : 220.0  // 카드 너비
        let gap: CGFloat = 16.0  // 카드 사이 간격
        let leftMargin: CGFloat = 20.0  // 첫 번째 카드의 왼쪽 마진
        
        // 실제 보이는 카드만 필터링
        let visibleCards = cards.enumerated().filter { !$1.isHidden }
        guard !visibleCards.isEmpty else { return }
        
        // 스크롤뷰의 중심점
        let scrollViewCenter = scrollView.contentOffset.x + scrollView.bounds.width / 2
        
        // 각 카드의 중심점과 스크롤뷰 중심점의 거리를 계산하여 가장 가까운 카드 찾기
        var closestCardIndex = 0
        var minDistance = CGFloat.greatestFiniteMagnitude
        
        for (visibleIndex, (originalIndex, _)) in visibleCards.enumerated() {
            // 각 카드의 중심점 계산
            // 첫 번째 카드: leftMargin + cardWidth/2
            // 두 번째 카드: leftMargin + cardWidth + gap + cardWidth/2
            // n번째 카드: leftMargin + (cardWidth + gap) * visibleIndex + cardWidth/2
            let cardCenter = leftMargin + (cardWidth + gap) * CGFloat(visibleIndex) + cardWidth / 2
            let distance = abs(cardCenter - scrollViewCenter)
            
            if distance < minDistance {
                minDistance = distance
                closestCardIndex = visibleIndex
            }
        }
        
        if dotIndicator.currentIndex != closestCardIndex {
            dotIndicator.currentIndex = closestCardIndex
        }
    }
}

#Preview {
    WinningReviewListView()
}
