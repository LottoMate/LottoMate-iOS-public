//
//  MapStoreListBottomSheetView.swift
//  LottoMate
//
//  Created by Mirae on 2/20/25.
//

import Foundation
import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import CoreLocation

class MultiStoreListBottomSheetView: UIView, MapStoreListRowDelegate, View {
    var disposeBag = DisposeBag()
    
    func rowHeightDidChanged(_ row: MultiStoreListRow) {
        // Row 높이가 변경되면 전체 레이아웃 다시 계산
        UIView.animate(withDuration: 0.2) {
            self.rootFlexContainer.flex.layout(mode: .adjustHeight)
            self.scrollView.contentSize = self.rootFlexContainer.frame.size
            self.layoutIfNeeded()
        }
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true // 바운스를 true로 변경하여 스크롤 경험 개선
        scrollView.alwaysBounceVertical = true // 항상 수직 바운스 활성화
        return scrollView
    }()
    
    fileprivate let rootFlexContainer = UIView()
//    private let sortButtonsContainer = UIView()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "여기는 로또 판매점이 없어요\r위치를 이동해서 다른 지점을 찾아봐요"
        label.numberOfLines = 2
        styleLabel(for: label, fontStyle: .body2, textColor: .gray100, alignment: .center)
        let image = CommonImageView(imageName: "pochi_empty")
        
        view.flex.direction(.column)
            .gap(8)
            .alignItems(.center)
            .define { flex in
                flex.addItem(image)
                    .size(100)
                flex.addItem(label)
            }
        view.isHidden = true
        return view
    }()
    
    let moveToSeoulButton = StyledButton(title: "로또 지도 둘러보기", buttonStyle: .solid(.round, .active), cornerRadius: 19, verticalPadding: 8, horizontalPadding: 16)
    
    lazy var notInSeoulView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "여기는 로또 판매점이 없어요\r위치를 이동해서 다른 지점을 찾아봐요"
        label.numberOfLines = 2
        styleLabel(for: label, fontStyle: .body2, textColor: .gray100, alignment: .center)
        let image = CommonImageView(imageName: "pochi_empty")
        
        view.flex.direction(.column)
            .gap(20)
            .alignItems(.center)
            .define { flex in
                flex.addItem()
                    .direction(.column)
                    .gap(8)
                    .alignItems(.center)
                    .define { flex in
                        flex.addItem(image)
                            .size(100)
                        flex.addItem(label)
                    }
                flex.addItem(moveToSeoulButton)
            }
        view.isHidden = true
        return view
    }()
    
    private var emptyStateViewTopMargin: CGFloat = 116
    private var notInSeoulViewTopMargin: CGFloat = 88
    
    private var storeListView = UIView()
    private var storeRows: [MultiStoreListRow] = []
    
    let sortByDistance = StyledButton(
        title: "가까운 순",
        buttonStyle: .text(.small, .active)
    )
    
    let sortByRank = StyledButton(
        title: "랭킹순",
        buttonStyle: .text(.small, .inactive)
    )
    
    private func setupSortButtonActions() {
        sortByDistance.addTarget(self, action: #selector(sortByDistanceTapped), for: .touchUpInside)
        sortByRank.addTarget(self, action: #selector(sortByRankTapped), for: .touchUpInside)
    }
    
    @objc private func sortByDistanceTapped() {
        setActiveButton(.distance)
        reactor?.action.onNext(.sortStoresByDistance)
    }
    
    @objc private func sortByRankTapped() {
        setActiveButton(.rank)
        reactor?.action.onNext(.sortStoresByRank)
    }
    
    private enum SortType {
        case distance
        case rank
    }
    
    private func setActiveButton(_ sortType: SortType) {
        switch sortType {
        case .distance:
            sortByDistance.style = .text(.small, .active)
            sortByRank.style = .text(.small, .inactive)
        case .rank:
            sortByDistance.style = .text(.small, .inactive)
            sortByRank.style = .text(.small, .active)
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupLayout()
        setupSortButtonActions()
        emptyStateView.flex.alignSelf(.center)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

//        sortButtonsContainer.pin.top().horizontally()
//        sortButtonsContainer.flex.layout(mode: .adjustHeight)

//        scrollView.pin.horizontally().bottom().top(sortButtonsContainer.frame.maxY + 4)
        scrollView.pin.horizontally().bottom().top(4)

        // scrollView 내부의 rootFlexContainer 레이아웃 설정
        rootFlexContainer.pin.top().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
        
        emptyStateView.pin.left().right().top(emptyStateViewTopMargin).bottom()
        emptyStateView.flex.layout()
        
        // notInSeoulView 레이아웃
        notInSeoulView.pin.left().right().top(notInSeoulViewTopMargin).bottom()
        notInSeoulView.flex.layout()
    }
    
    private func setupLayout() {
//        addSubview(sortButtonsContainer)
        addSubview(scrollView)
        addSubview(emptyStateView)
        addSubview(notInSeoulView)
        scrollView.addSubview(rootFlexContainer)

//        sortButtonsContainer.flex
//            .direction(.row)
//            .alignItems(.center)
//            .paddingHorizontal(20)
//            .paddingBottom(24)
//            .gap(16)
//            .define { flex in
//                flex.addItem(sortByDistance).height(22)
//                flex.addItem().width(1).height(16).backgroundColor(.gray20)
//                flex.addItem(sortByRank).height(22)
//            }

        rootFlexContainer
            .flex
            .direction(.column)
            .define { flex in
                flex.addItem(storeListView).direction(.column).grow(1)
            }
    }
    
    func bind(reactor: MapViewReactor) {
        reactor.state
            .map { $0.storeListData }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] stores in
                guard let self = self else { return }
                
                let isEmpty = stores.isEmpty
                self.scrollView.isHidden = isEmpty
                self.emptyStateView.isHidden = !isEmpty
                
                if !isEmpty {
                    self.updateStoreRows(with: stores)
                } else {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.bottomSheetState }
            .distinctUntilChanged()
            .map { state -> (emptyMargin: CGFloat, notInSeoulMargin: CGFloat) in
                // emptyStateView와 notInSeoulView에 서로 다른 마진 설정
                let emptyMargin: CGFloat = state == .expanded ? 238 : 118
                let notInSeoulMargin: CGFloat = state == .expanded ? 210 : 88
                return (emptyMargin, notInSeoulMargin)
            }
            .subscribe(onNext: { [weak self] margins in
                guard let self = self else { return }
                
                self.emptyStateViewTopMargin = margins.emptyMargin
                self.notInSeoulViewTopMargin = margins.notInSeoulMargin
                
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.setNeedsLayout()
                    self?.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isInSeoulRegion }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isInSeoul in
                guard let self = self else { return }
                
                // 서울 지역이 아닐 때 notInSeoulView 표시
                self.scrollView.isHidden = !isInSeoul
                self.notInSeoulView.isHidden = isInSeoul
                
                // emptyStateView는 서울 지역일 때만 조건부로 표시
                if isInSeoul {
                    let isEmpty = reactor.currentState.storeListData.isEmpty
                    self.emptyStateView.isHidden = !isEmpty
                } else {
                    self.emptyStateView.isHidden = true
                }
                
                self.setNeedsLayout()
                self.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        
        
    }
    
    private func updateStoreRows(with stores: [StoreDetailInfo]) {
        storeRows.forEach { $0.removeFromSuperview() }
        storeRows.removeAll()
        
        stores.enumerated().forEach { (index, store) in
            let row = createStoreRow(from: store)
            storeRows.append(row)
            row.delegate = self
            let flexItem = storeListView.flex.addItem(row)
            if index > 0 {
                flexItem.marginTop(20)
            }
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func createStoreRow(from store: StoreDetailInfo) -> MultiStoreListRow {
        let row = MultiStoreListRow()
        row.reactor = reactor
        row.configure(with: store)
        
        row.storeName.text = store.storeNm
        row.addressLabel.text = store.storeAddr
        if store.storeTel.isEmpty {
            row.phoneNumberLabel.text = "-"
        } else {
            row.phoneNumberLabel.text = store.storeTel
        }
        row.tagsContainer.flex.direction(.row)
            .gap(4)
            .paddingLeft(20)
//            .marginTop(20)
            .define { flex in
                // 로또 645 태그
                if store.lottoTypeList.contains("L645") {
                    flex.addItem(row.lottoTypeTag)
                        .width(37)
                        .height(22)
                        .backgroundColor(.green5)
                        .cornerRadius(4)
                }
                
                // 연금복권 720 태그
                if store.lottoTypeList.contains("L720") {
                    flex.addItem(row.pensionLotteryTypeTag)
                        .width(56)
                        .height(22)
                        .backgroundColor(.blue5)
                        .cornerRadius(4)
                }
                
                // 스피또 태그
                if store.lottoTypeList.contains("S1000") || store.lottoTypeList.contains("S2000") {
                    flex.addItem(row.speetoTypeTag)
                        .width(46)
                        .height(22)
                        .cornerRadius(4)
                        .backgroundColor(.peach5)
                }
            }
        
        // 거리 데이터 서버 데이터로 변경
        row.storeDistance.text = String(store.distance)
        
        return row
    }
    
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance >= 1000 {
            return String(format: "%.1fkm", distance / 1000)
        } else {
            return String(format: "%.0fm", distance)
        }
    }
}
