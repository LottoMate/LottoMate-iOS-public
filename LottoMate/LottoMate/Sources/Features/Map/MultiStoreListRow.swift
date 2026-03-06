//
//  StoreListBottomSheetView.swift
//  LottoMate
//
//  Created by Mirae on 2/20/25.
//  지도의 판매점 리스트 바텀시트의 Row 뷰

import Foundation
import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxGesture
import ReactorKit

protocol MapStoreListRowDelegate: AnyObject {
    func rowHeightDidChanged(_ row: MultiStoreListRow)
}

class MultiStoreListRow: UIView, View {
    weak var delegate: MapStoreListRowDelegate?
    
    var disposeBag = DisposeBag()
    private var store: StoreDetailInfo?
    
    fileprivate let rootFlexContainer = UIView()
    
    let tagsContainer = UIView()
    
    let lottoTypeTag = UILabel()
    let pensionLotteryTypeTag = UILabel()
    let speetoTypeTag = UILabel()
    
    let storeName = UILabel()
    let storeDistance = UILabel()
    
    private var isLiked = false
    let likeIcon = UIImageView()
    let likeCount = UILabel()
    
    let placeIcon = UIImageView()
    let copyIcon = UIImageView()
    let callIcon = UIImageView()
    
    let lottoIcon = UIImageView()
    let pensionLotteryIcon = UIImageView()
    let speetoIcon = UIImageView()
    
    let lottoLabel = UILabel()
    let lottoWinningCount = UILabel()
    
    let pensionLotteryLabel = UILabel()
    let pensionLotteryWinningCount = UILabel()
    
    let speetoLabel = UILabel()
    let speetoWinningCount = UILabel()
    
    let arrowToggleButton = ToggleArrowButton()
    private var isExpanded = false
    
    let winningTags = StoreInfoWinningTagHorizontalScrollView()
    
    let addressLabel = UILabel()
    let phoneNumberLabel = UILabel()
    
    private let winningTagsSeparator = UIView()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        lottoTypeTag.text = "로또"
        styleLabel(for: lottoTypeTag, fontStyle: .caption1, textColor: .green70)
        lottoTypeTag.clipsToBounds = true
        
        pensionLotteryTypeTag.text = "연금복권"
        styleLabel(for: pensionLotteryTypeTag, fontStyle: .caption1, textColor: .blue50Default)
        pensionLotteryTypeTag.clipsToBounds = true
        
        speetoTypeTag.text = "스피또"
        styleLabel(for: speetoTypeTag, fontStyle: .caption1, textColor: .peach50Default)
        speetoTypeTag.clipsToBounds = true
        
        storeName.text = "로또복권판매점 복권명당박정희로점"
        styleLabel(for: storeName, fontStyle: .headline1, textColor: .black, alignment: .left)
        storeName.numberOfLines = 2
        
        storeDistance.text = "-"
        styleLabel(for: storeDistance, fontStyle: .caption1, textColor: .gray80)
        
        if let likeIconImage = UIImage(named: "icon_like") {
            likeIcon.image = likeIconImage
            likeIcon.contentMode = .scaleAspectFit
        }
        // 임의의 좋아요 수 설정 (서버 연동 전 테스트용)
        let randomLikes = Int.random(in: 1...15000)
        likeCount.text = randomLikes > 9999 ? "9,999+" : randomLikes.formattedWithSeparator()
        styleLabel(for: likeCount, fontStyle: .caption2, textColor: .gray80)
        
        if let placeIconImage = UIImage(named: "icon_place") {
            placeIcon.image = placeIconImage
            placeIcon.contentMode = .scaleAspectFit
        }
        if let copyIconImage = UIImage(named: "icon_copy") {
            copyIcon.image = copyIconImage
            copyIcon.contentMode = .scaleAspectFit
        }
        if let callIconImage = UIImage(named: "icon_call") {
            callIcon.image = callIconImage
            callIcon.contentMode = .scaleAspectFit
        }
        
        addressLabel.text = "서울 강남구 봉은사로74길 13 101호"
        styleLabel(for: addressLabel, fontStyle: .label2, textColor: .gray100, alignment: .left)
        addressLabel.numberOfLines = 2
        
        phoneNumberLabel.text = "-"
        styleLabel(for: phoneNumberLabel, fontStyle: .label2, textColor: .gray100)
        
        if let lottoIconImage = UIImage(named: "icon_lotto") {
            lottoIcon.image = lottoIconImage
            lottoIcon.contentMode = .scaleAspectFit
        }
        if let pensionLotteryIconImage = UIImage(named: "icon_pensionLottery") {
            pensionLotteryIcon.image = pensionLotteryIconImage
            pensionLotteryIcon.contentMode = .scaleAspectFit
        }
        if let speetoIconImage = UIImage(named: "icon_speeto") {
            speetoIcon.image = speetoIconImage
            speetoIcon.contentMode = .scaleAspectFit
        }
        
        lottoLabel.text = "로또"
        styleLabel(for: lottoLabel, fontStyle: .caption1, textColor: .black)
        
        pensionLotteryLabel.text = "연금복권"
        styleLabel(for: pensionLotteryLabel, fontStyle: .caption1, textColor: .black)
        
        speetoLabel.text = "스피또"
        styleLabel(for: speetoLabel, fontStyle: .caption1, textColor: .black)
        
        lottoWinningCount.text = "12회"
        styleLabel(for: lottoWinningCount, fontStyle: .caption1, textColor: .red50Default)
        
        pensionLotteryWinningCount.text = "9회"
        styleLabel(for: pensionLotteryWinningCount, fontStyle: .caption1, textColor: .red50Default)
        
        speetoWinningCount.text = "4회"
        styleLabel(for: speetoWinningCount, fontStyle: .caption1, textColor: .red50Default)
        
        winningTagsSeparator.backgroundColor = .gray20
        
        addSubview(rootFlexContainer)
        
        rootFlexContainer
            .flex
            .direction(.column)
            .backgroundColor(.white)
            .define { flex in
                // 판매 복권 종류 태그
                flex.addItem(tagsContainer)
                
                flex.addItem()
                    .direction(.row)
                    .marginTop(8)
                    .paddingHorizontal(20)
                    .justifyContent(.spaceBetween)
                    .alignItems(.start)
                    .define { flex in
                        flex.addItem()
                            .direction(.column)
                            .grow(1)
                            .marginRight(8)
                            .define { flex in
                                flex.addItem()
                                    .direction(.row)
                                    .gap(8)
                                    .alignItems(.baseline)
                                    .define { flex in
                                        flex.addItem(storeName)
                                            .maxWidth(UIScreen.main.bounds.width / 1.4940)
                                            .alignSelf(.start)
                                        flex.addItem(storeDistance)
                                            .marginTop(7)
                                    }
                                
                                flex.addItem()
                                    .direction(.column)
                                    .marginTop(4)
                                    .define { flex in
                                        flex.addItem().direction(.row)
                                            .gap(4)
                                            .alignItems(.baseline)
                                            .define { flex in
                                                flex.addItem(placeIcon)
                                                    .size(12)
                                                    .marginTop(5)
                                                flex.addItem(addressLabel)
                                                    .maxWidth(UIScreen.main.bounds.width / 1.3392)
                                                    .alignSelf(.start)
                                                flex.addItem(copyIcon)
                                                    .size(12)
                                                    .marginTop(5)
                                            }
                                        flex.addItem().direction(.row)
                                            .gap(4)
                                            .alignItems(.center)
                                            .marginTop(2)
                                            .define { flex in
                                                flex.addItem(callIcon).size(12)
                                                flex.addItem(phoneNumberLabel)
                                        }
                                    }
                            }
                        
//                        flex.addItem().direction(.column).define { flex in
//                            flex.addItem(likeIcon).size(24)
//                            flex.addItem(likeCount)
//                        }
                    }
                
                // Lotto/Pension/Speeto icons, counts, and arrow button
//                flex.addItem().direction(.row).justifyContent(.spaceBetween).alignItems(.center).paddingLeft(20).marginTop(12).define { flex in
//                    flex.addItem().direction(.row).gap(8).define { flex in
//                        flex.addItem().direction(.row).gap(2).alignItems(.center).paddingVertical(4).paddingHorizontal(8).define { flex in
//                            flex.addItem(lottoIcon).size(12)
//                            flex.addItem(lottoLabel)
//                            flex.addItem(lottoWinningCount)
//                        }
//                        .backgroundColor(.gray20)
//                        .cornerRadius(8)
//                        
//                        flex.addItem().direction(.row).gap(2).alignItems(.center).paddingVertical(4).paddingHorizontal(8).define { flex in
//                            flex.addItem(pensionLotteryIcon).size(12)
//                            flex.addItem(pensionLotteryLabel)
//                            flex.addItem(pensionLotteryWinningCount)
//                        }
//                        .backgroundColor(.gray20)
//                        .cornerRadius(8)
//                        
//                        flex.addItem().direction(.row).gap(2).alignItems(.center).paddingVertical(4).paddingHorizontal(8).define { flex in
//                            flex.addItem(speetoIcon).size(12)
//                            flex.addItem(speetoLabel)
//                            flex.addItem(speetoWinningCount)
//                        }
//                        .backgroundColor(.gray20)
//                        .cornerRadius(8)
//                    }
//                    flex.addItem(arrowToggleButton)
//                        .size(20)
//                        .marginRight(20)
//                }
                flex.addItem().height(1).backgroundColor(.gray20).marginTop(20).marginHorizontal(20)
                
//                flex.addItem(winningTags)
//                    .width(100%)
            }
    }
     
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    private func setupBindings() {
        arrowToggleButton.onToggle = { [weak self] expanded in
            self?.toggleWinningTags(expanded)
        }
        
        likeIcon.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.isLiked.toggle()
                
                if self.isLiked {
                    if let filledLikeImage = UIImage(named: "icon_like_fill") {
                        self.likeIcon.image = filledLikeImage
                        self.likeCount.textColor = .red50Default
                    }
                } else {
                    if let defaultLikeImage = UIImage(named: "icon_like") {
                        self.likeIcon.image = defaultLikeImage
                        self.likeCount.textColor = .gray80
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func toggleWinningTags(_ expanded: Bool) {
        isExpanded = expanded
        
        if isExpanded {
            // 확장 시: 뷰를 추가하고 애니메이션
            addWinningTagsView()
            winningTagsSeparator.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                self.winningTags.alpha = 1
                self.winningTagsSeparator.alpha = 1
                self.layoutIfNeeded()
            }, completion: { _ in
                self.delegate?.rowHeightDidChanged(self)
            })
        } else {
            // 축소 시: 애니메이션 후 뷰 제거
            UIView.animate(withDuration: 0.3, animations: {
                self.winningTags.alpha = 0
                self.winningTagsSeparator.alpha = 0
            }, completion: { _ in
                self.removeWinningTagsView()
                self.winningTagsSeparator.isHidden = true
                self.delegate?.rowHeightDidChanged(self)
            })
        }
    }
    
    private func addWinningTagsView() {
        addSubview(winningTags) // rootFlexContainer 대신 self에 추가
        addSubview(winningTagsSeparator)
        
        // 레이아웃 설정
        winningTags.translatesAutoresizingMaskIntoConstraints = false
        winningTagsSeparator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            winningTags.topAnchor.constraint(equalTo: rootFlexContainer.bottomAnchor),
            winningTags.leadingAnchor.constraint(equalTo: leadingAnchor),
            winningTags.trailingAnchor.constraint(equalTo: trailingAnchor),
            winningTags.heightAnchor.constraint(equalToConstant: 184),// 중요: 뷰의 하단을 업데이트
            
            winningTagsSeparator.topAnchor.constraint(equalTo: winningTags.bottomAnchor),
            winningTagsSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            winningTagsSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            winningTagsSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func removeWinningTagsView() {
        winningTags.removeFromSuperview()
        winningTagsSeparator.removeFromSuperview()
    }
    
    func configure(with store: StoreDetailInfo) {
        self.store = store
        
        storeName.text = store.storeNm
        storeDistance.text = store.distance
        addressLabel.text = store.storeAddr
        phoneNumberLabel.text = store.storeTel.isEmpty ? "-" : store.storeTel

        // arrowToggleButton 숨김/표시 로직 추가 (당첨 정보 없는 경우 화살표 미표시)
        if store.lottoInfos.isEmpty {
            arrowToggleButton.isHidden = true
        } else {
            arrowToggleButton.isHidden = false
        }
        
        store.lottoInfos

        // 당첨 정보 설정
//                let sampleLottoInfo = [
//                    LottoInfo(lottoType: "L720", place: 2, lottoJackpot: 1680000000, drwNum: 333),
//                    LottoInfo(lottoType: "L645", place: 1, lottoJackpot: 1122211122, drwNum: 12),
//                ]
//                winningTags.configure(with: sampleLottoInfo) // 리스트 당첨 정보 없는 경우 테스트
        
        winningTags.configure(with: store.lottoInfos)
        
        
        // 판매 복권 종류 태그 설정
        setupLottoTypeTags(store.lottoTypeList)
    }
    
    func bind(reactor: MapViewReactor) {
        storeName.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                if let store = self?.store {
                    reactor.action.onNext(.selectStore(store))
                }
            })
            .disposed(by: disposeBag)
        
        copyIcon.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                if let store = self?.store {
                    let storeName = store.storeNm
                    let storeAddr = store.storeAddr
                    
                    let textToCopy = "지점명: \(storeName)\n주소: \(storeAddr)"
                    UIPasteboard.general.string = textToCopy
                    ToastView.show(message: "로또 판매점 주소를 복사했어요", horizontalPadding: 160)
                }
            })
            .disposed(by: disposeBag)
        
        likeIcon.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.isLiked.toggle()
                
                if self.isLiked {
                    if let filledLikeImage = UIImage(named: "icon_like_fill") {
                        self.likeIcon.image = filledLikeImage
                        self.likeCount.textColor = .red50Default
                    }
                } else {
                    if let defaultLikeImage = UIImage(named: "icon_like") {
                        self.likeIcon.image = defaultLikeImage
                        self.likeCount.textColor = .gray80
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupLottoTypeTags(_ lottoTypes: [String]) {
        // 기존 태그들 숨기기
        lottoTypeTag.isHidden = true
        pensionLotteryTypeTag.isHidden = true
        speetoTypeTag.isHidden = true
        
        // 태그 컨테이너 초기화
        tagsContainer.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        tagsContainer.flex
            .direction(.row)
            .gap(4)
            .paddingLeft(20)
            .define { flex in
                for type in lottoTypes {
                    switch type {
                    case "L645":
                        lottoTypeTag.isHidden = false
                        flex.addItem(lottoTypeTag)
                            .paddingVertical(2)
                            .paddingHorizontal(8)
                            .backgroundColor(.green10)
                            .cornerRadius(4)
                    case "L720":
                        pensionLotteryTypeTag.isHidden = false
                        flex.addItem(pensionLotteryTypeTag)
                            .paddingVertical(2)
                            .paddingHorizontal(8)
                            .backgroundColor(.blue10)
                            .cornerRadius(4)
                    case "S500", "S1000", "S2000":
                        if speetoTypeTag.isHidden {  // 스피또는 한 번만 추가
                            speetoTypeTag.isHidden = false
                            flex.addItem(speetoTypeTag)
                                .paddingVertical(2)
                                .paddingHorizontal(8)
                                .backgroundColor(.peach10)
                                .cornerRadius(4)
                        }
                    default:
                        break
                    }
                }
            }
        
        tagsContainer.flex.layout()
    }
}
