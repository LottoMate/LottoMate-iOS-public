//
//  SpeetoPageSelectorVC.swift
//  LottoMate
//
//  Created by Mirae on 3/13/25.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift

class SpeetoPageSelectorVC: UIViewController {
    // MARK: - Properties
    fileprivate let rootFlexContainer = UIView()
    private var disposeBag = DisposeBag()
    
    var pages: [String] = []
    private var selectedPageIndex: Int?
    private var pageLabels: [UILabel] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "페이지 선택"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black, alignment: .left)
        return label
    }()
    
    private let scrollViewForPageNumbers: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
    }()
    
    private let scrollContentView = UIView()
    
    private let cancelButton = StyledButton(
        title: "취소",
        buttonStyle: .assistive(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    private let confirmButton = StyledButton(
        title: "확인",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(rootFlexContainer)
        rootFlexContainer.layer.cornerRadius = 32
        rootFlexContainer.clipsToBounds = true
        rootFlexContainer.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMinXMinYCorner
        ]
        
        setupUI()
    }
    
    private func setupUI() {
        // Clear existing views and labels
        scrollContentView.subviews.forEach { $0.removeFromSuperview() }
        pageLabels.removeAll()
        
        rootFlexContainer.flex
            .direction(.column)
            .gap(24)
            .backgroundColor(.white)
            .paddingTop(8) // gap이 맨 위에도 추가되어서 8로 적용
            .paddingBottom(24)
            .define { flex in
                flex.addItem(titleLabel)
                    .alignSelf(.start)
                    .marginLeft(20)
                
                flex.addItem(scrollViewForPageNumbers)
                    .width(100%)
                    .height(120)
                
                scrollViewForPageNumbers.addSubview(scrollContentView)
                scrollContentView.flex
                    .direction(.column)
                    .define { flex in
                        for (index, pageNum) in pages.enumerated() {
                            let label = UILabel()
                            label.text = pageNum
                            label.isUserInteractionEnabled = true
                            label.tag = index
                            
                            // Set initial style based on current page
                            if index == selectedPageIndex {
                                label.backgroundColor = .red5
                                styleLabel(for: label, fontStyle: .headline1, textColor: .black)
                            } else {
                                label.backgroundColor = .white
                                styleLabel(for: label, fontStyle: .headline1, textColor: .gray90)
                            }
                            
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePageTap(_:)))
                            label.addGestureRecognizer(tapGesture)
                            
                            pageLabels.append(label)
                            
                            flex.addItem(label)
                                .width(100%)
                                .height(40)
                        }
                    }
                
                flex.addItem()
                    .direction(.row)
                    .gap(15)
                    .justifyContent(.spaceEvenly)
                    .marginHorizontal(20)
                    .define { flex in
                        flex.addItem(cancelButton)
                            .grow(1)
                            .basis(0)
                        flex.addItem(confirmButton)
                            .grow(1)
                            .basis(0)
                    }
            }
            
        // Add cancel button action
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    func bind(reactor: SpeetoWinningInfoReactor) {
        // 총 페이지 수 바인딩
        reactor.state
            .map { state -> (totalPages: Int, currentPage: Int) in
                return (state.totalPages, state.currentPage)
            }
            .distinctUntilChanged { prev, current in
                return prev.totalPages == current.totalPages
            }
            .skip(1)
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                
                self.pages.removeAll()
                // 테스트를 위해 totalPages가 1일 때는 20페이지를 생성
                let testTotalPages = state.totalPages == 1 ? 20 : state.totalPages
                self.pages = Array(1...testTotalPages).map { String($0) }
                // Set the initial selected page index based on currentPage
                self.selectedPageIndex = state.currentPage - 1
                self.setupUI()
            })
            .disposed(by: disposeBag)
        
        // 현재 페이지 바인딩 및 초기 선택
        reactor.state
            .map { $0.currentPage }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] currentPage in
                guard let self = self else { return }
                // 현재 페이지를 선택 상태로 설정
                if let label = self.pageLabels.first(where: { ($0.tag + 1) == currentPage }) {
                    self.handlePageTap(UITapGestureRecognizer(target: label, action: nil))
                    
                    // 현재 페이지가 보이도록 스크롤
                    let labelFrame = label.frame
                    self.scrollViewForPageNumbers.scrollRectToVisible(labelFrame, animated: false)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.bottom().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        scrollContentView.pin.top().horizontally()
        scrollContentView.flex.layout(mode: .adjustHeight)
        scrollViewForPageNumbers.contentSize = scrollContentView.frame.size
    }
    
    // MARK: - Actions
    @objc private func handlePageTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        
        // Deselect previous selection
        if let previousIndex = selectedPageIndex {
            let previousLabel = pageLabels[previousIndex]
            previousLabel.backgroundColor = .white
            styleLabel(for: previousLabel, fontStyle: .headline1, textColor: .gray90)
        }
        
        // Select new label
        selectedPageIndex = label.tag
        label.backgroundColor = .red5
        styleLabel(for: label, fontStyle: .headline1, textColor: .black)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}
