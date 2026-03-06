//
//  SpeetoWinningInfoDetailView.swift
//  LottoMate
//
//  Created by Mirae on 8/21/24.
//

import UIKit
import ReactorKit
import PinLayout
import FlexLayout
import RxSwift
import RxRelay
import RxGesture
import BottomSheet

protocol SpeetoWinningInfoViewDelegate: AnyObject {
    func speetoWinningInfoViewHeightDidChange()
}

class SpeetoWinningInfoView: UIView, View {
    fileprivate let rootFlexContainer = UIView()
    weak var delegate: SpeetoWinningInfoViewDelegate?
    
    var disposeBag = DisposeBag()
    
    private let viewModel = LottoMateViewModel.shared
    
    let containerView = UIView()
    let pageLabelContainerView = UIView()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    let previousRoundButton = UIButton()
    let nextRoundButton = UIButton()
    
    let currentPageLabel = UILabel()
    let totalPagesLabel = UILabel()
    
    var firstPrizeInfoView = UIView()
    var secondPrizeInfoView = UIView()
    
    let prizeDetailsByRank = UILabel()
    /// 당첨 정보 안내 기준 레이블
    let conditionNoticeLabel = UILabel()
    /// 배너 뷰
    //    let banner = BannerView(bannerBackgroundColor: .yellow5, bannerImageName: "banner_coins", titleText: "행운의 1등 로또\r어디서 샀을까?", bodyText: "당첨 판매점 보러가기")
    
    lazy var typeButtons: CustomSquareButtonForSpeeto = {
        let buttonView = CustomSquareButtonForSpeeto()
        return buttonView
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        
        setupDrawRoundContainer()
        setupPrizeDetailByRankLabel()
        setupConditionNoticeLabel()
        setupLoadingIndicator()
        
        addSubview(rootFlexContainer)
        
        rootFlexContainer.flex.direction(.column)
            .paddingTop(12)
            .define { flex in
                flex.addItem(typeButtons)
                
                flex.addItem(containerView).direction(.column).marginTop(24).paddingHorizontal(20).define { flex in
                    flex.addItem().direction(.row).justifyContent(.spaceBetween).marginBottom(12).define { flex in
                        flex.addItem(prizeDetailsByRank).alignSelf(.start)
                        flex.addItem().direction(.row).alignItems(.center).justifyContent(.center).define { flex in
                            flex.addItem(previousRoundButton).size(12).marginRight(12)
                            flex.addItem(pageLabelContainerView)
                                .direction(.row)
                                .alignItems(.center)
                                .justifyContent(.center)
                                .define { flex in
                                    flex.addItem(currentPageLabel).minWidth(10)
                                    flex.addItem(totalPagesLabel).minWidth(20)
                                }
                            flex.addItem(nextRoundButton).size(12).marginLeft(12)
                        }
                    }
                    // 1등 카드
                    flex.addItem(firstPrizeInfoView).marginBottom(20)
                    // 2등 카드
                    flex.addItem(secondPrizeInfoView)
                }
                flex.addItem(conditionNoticeLabel).marginTop(16).paddingHorizontal(20).alignSelf(.start)
                // flex.addItem(banner).marginHorizontal(20).marginTop(32)
            }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        loadingIndicator.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    private func setupDrawRoundContainer() {
        // 현재 페이지와 총 페이지 레이블 설정
        currentPageLabel.attributedText = NSAttributedString(string: "1", attributes: Typography.label2.attributes())
        currentPageLabel.textColor = .gray100
        currentPageLabel.isHidden = false
        currentPageLabel.sizeToFit()
        
        totalPagesLabel.attributedText = NSAttributedString(string: "/ 99", attributes: Typography.label2.attributes())
        totalPagesLabel.textColor = .gray100
        totalPagesLabel.isHidden = false
        totalPagesLabel.sizeToFit()
        
        let previousRoundBtnImage = UIImage(named: "icon_arrow_left_small")
        previousRoundButton.setImage(previousRoundBtnImage, for: .normal)
        previousRoundButton.tintColor = .gray100
        previousRoundButton.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
        previousRoundButton.alpha = 0.4
        
        let nextRoundBtnImage = UIImage(named: "icon_arrow_right_small")
        nextRoundButton.setImage(nextRoundBtnImage, for: .normal)
        nextRoundButton.tintColor = .gray100
        nextRoundButton.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
        nextRoundButton.alpha = 0.4
    }
    
    private func setupPrizeDetailByRankLabel() {
        prizeDetailsByRank.text = "등수별 당첨 정보"
        styleLabel(for: prizeDetailsByRank, fontStyle: .headline1, textColor: .black)
    }
    
    private func setupConditionNoticeLabel() {
        conditionNoticeLabel.text = "*1억원 이상의 당첨금 수령 후, 실물 확인된 복권만 안내해요"
        styleLabel(for: conditionNoticeLabel, fontStyle: .caption1, textColor: .gray80)
    }
    
    private func setupLoadingIndicator() {
        addSubview(loadingIndicator)
        loadingIndicator.center = center
    }
}

extension SpeetoWinningInfoView {
    func bind(reactor: SpeetoWinningInfoReactor) {
        typeButtons.bind(reactor: reactor)
        reactor.action.onNext(.loadSpeetoWinningInfo(type: .s2000, page: 1))
        
        reactor.state
            .map { $0.currentPage }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] currentPage in
                guard let self = self else { return }
                self.currentPageLabel.attributedText = NSAttributedString(
                    string: "\(currentPage)",
                    attributes: Typography.label2.attributes()
                )
                self.currentPageLabel.isHidden = false
                
                // 이전 버튼 상태 업데이트 - 첫 페이지(1)일 때 비활성화
                self.previousRoundButton.isEnabled = currentPage > 1
                self.previousRoundButton.alpha = currentPage > 1 ? 1.0 : 0.4
            })
            .disposed(by: disposeBag)
         
        reactor.state
            .map { $0.totalPages }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] totalPages in
                guard let self = self else { return }
                self.totalPagesLabel.attributedText = NSAttributedString(
                    string: "/ \(totalPages)",
                    attributes: Typography.label2.attributes()
                )
                self.totalPagesLabel.isHidden = false
                
                // 다음 버튼 상태 업데이트를 위해 현재 페이지도 필요
                let currentPage = reactor.currentState.currentPage
                self.nextRoundButton.isEnabled = currentPage < totalPages - 1
                self.nextRoundButton.alpha = currentPage < totalPages - 1 ? 1.0 : 0.4
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.speetoType }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                self.clearAllPrizeViews()
                reactor.action.onNext(.loadSpeetoWinningInfo(type: type, page: 1))
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태 표시 (임시 로딩 뷰 사용)
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        // 오류 표시 (선택적)
        reactor.state.map { $0.error }
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] error in
                guard let self = self, let error = error else { return }
            })
            .disposed(by: disposeBag)
        
        // State
        // 당첨 정보 목록 바인딩 및 가공
        reactor.state.map { $0.winningStores }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] stores in
                guard let self = self else { return }
                
                let firstPrizeStores = stores.filter { $0.place == 1 }
                let secondPrizeStores = stores.filter { $0.place == 2 }
                
                if !firstPrizeStores.isEmpty {
                    self.updateFirstPrizeCardView(with: stores)
                }
                
                if !secondPrizeStores.isEmpty {
                    self.updateSecondPrizeCardView(with: stores)
                }
                
                print("firstPrizeStores-\(firstPrizeStores)") // 현재 데이터 없음
                print("secondPrizeStores-\(secondPrizeStores)") // 데이터 10개
            })
            .disposed(by: disposeBag)
        
        pageLabelContainerView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.speetoPageTapEvent.accept(true)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateFirstPrizeCardView(with stores: [SpeetoWinningStore]) {
        firstPrizeInfoView.flex.markDirty()
        firstPrizeInfoView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        let cardView = SpeetoPrizeInfoCardView(prizeTier: .firstPrize, winningStores: stores)
        firstPrizeInfoView.flex.addItem(cardView).grow(1)
        
        setNeedsLayout()
        layoutIfNeeded()
        delegate?.speetoWinningInfoViewHeightDidChange()
    }
    
    private func updateSecondPrizeCardView(with stores: [SpeetoWinningStore]) {
        secondPrizeInfoView.flex.markDirty()
        secondPrizeInfoView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        let cardView = SpeetoPrizeInfoCardView(prizeTier: .secondPrize, winningStores: stores)
        secondPrizeInfoView.flex.addItem(cardView).grow(1)
        
        setNeedsLayout()
        layoutIfNeeded()
        delegate?.speetoWinningInfoViewHeightDidChange()
    }
    
    private func createDetailContainer(from store: SpeetoWinningStore) -> SpeetoCardViewDetailContainer {
        let detailContainer = SpeetoCardViewDetailContainer(winningStore: store)
        detailContainer.bind(reactor: reactor ?? SpeetoWinningInfoReactor())
        
        return detailContainer
    }
    
    private func clearAllPrizeViews() {
        // 1등 카드뷰 초기화
        firstPrizeInfoView.flex.markDirty()
        firstPrizeInfoView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        // 2등 카드뷰 초기화
        secondPrizeInfoView.flex.markDirty()
        secondPrizeInfoView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}

#Preview {
    let view = SpeetoWinningInfoView()
    return view
}
