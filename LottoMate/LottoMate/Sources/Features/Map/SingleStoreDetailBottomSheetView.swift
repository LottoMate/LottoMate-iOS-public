//
//  StoreInfoBottomSheetView.swift
//  LottoMate
//
//  Created by Mirae on 10/7/24.
//

import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import CoreLocation
import RxGesture

class SingleStoreDetailBottomSheetView: UIView, View {
    var disposeBag = DisposeBag()
    
    fileprivate let rootFlexContainer = UIView()
    
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
    
    let addressLabel = UILabel()
    let phoneNumberLabel = UILabel()
    
    let lottoIcon = UIImageView()
    let pensionLotteryIcon = UIImageView()
    let speetoIcon = UIImageView()
    
    let lottoLabel = UILabel()
    let lottoWinningCount = UILabel()
    
    let pensionLotteryLabel = UILabel()
    let pensionLotteryWinningCount = UILabel()
    
    let speetoLabel = UILabel()
    let speetoWinningCount = UILabel()
    
    let arrowDownIcon = UIImageView()
    
    let winningTags = StoreInfoWinningTagHorizontalScrollView()
    let noWinningHistoryCharacter = UIImageView()
    let noWinningHistoryLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        lottoTypeTag.text = "로또"
        styleLabel(for: lottoTypeTag, fontStyle: .caption1, textColor: .green70)
        lottoTypeTag.clipsToBounds = true
        
        pensionLotteryTypeTag.text = "연금복권"
        styleLabel(for: pensionLotteryTypeTag, fontStyle: .caption1, textColor: .blue50Default)
        pensionLotteryTypeTag.clipsToBounds = true
        
        speetoTypeTag.text = "스피또"
        styleLabel(for: speetoTypeTag, fontStyle: .caption1, textColor: .peach50Default)
        speetoTypeTag.clipsToBounds = true
        
        storeName.text = "판매점명"
        styleLabel(for: storeName, fontStyle: .headline1, textColor: .black, alignment: .left)
        storeName.numberOfLines = 2
        
        storeDistance.text = "-"
        styleLabel(for: storeDistance, fontStyle: .caption1, textColor: .gray80)
        
        if let likeIconImage = UIImage(named: "icon_like") {
            likeIcon.image = likeIconImage
            likeIcon.contentMode = .scaleAspectFit
            likeIcon.isUserInteractionEnabled = true
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
        
        phoneNumberLabel.text = "02-123-4567"
        styleLabel(for: phoneNumberLabel, fontStyle: .label2, textColor: .gray100, alignment: .left)
        
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
        
        if let arrowDownIconImage = UIImage(named: "icon_arrow_down") {
            arrowDownIcon.image = arrowDownIconImage
            arrowDownIcon.contentMode = .scaleAspectFit
        }
        
        if let characterImage = UIImage(named: "pochi_empty") {
            noWinningHistoryCharacter.image = characterImage
            noWinningHistoryCharacter.contentMode = .scaleAspectFit
        }
        
        noWinningHistoryLabel.text = "아직 당첨 이력이 없어요"
        styleLabel(for: noWinningHistoryLabel, fontStyle: .body2, textColor: .gray100)
        
        addSubview(rootFlexContainer)
        
        // In initial layout, assume no winning history
//        let hasWinningHistory = false
        
        rootFlexContainer.flex.direction(.column)
            .define { flex in
                flex.addItem().direction(.row)
                    .gap(4)
                    .paddingLeft(20)
                    .define { flex in
                        flex.addItem(lottoTypeTag)
                            .width(37)
                            .height(22)
                            .backgroundColor(.green5)
                            .cornerRadius(4)
                        flex.addItem(pensionLotteryTypeTag)
                            .width(56)
                            .height(22)
                            .backgroundColor(.blue5)
                            .cornerRadius(4)
                        flex.addItem(speetoTypeTag)
                            .width(46)
                            .height(22)
                            .cornerRadius(4)
                            .backgroundColor(.peach5)
                    }
                
                flex.addItem().direction(.row)
                    .marginTop(8)
                    .paddingHorizontal(20)
                    .justifyContent(.spaceBetween)
                    .alignItems(.start)
                    .define { flex in
                        flex.addItem()
                            .gap(8)
                            .direction(.row)
                            .alignItems(.baseline)
                            .define { flex in
                                flex.addItem(storeName)
                                    .maxWidth(UIScreen.main.bounds.width / 1.4940)
                                    .alignSelf(.start)
                                flex.addItem(storeDistance)
                                    .marginTop(7)
                            }
//                        flex.addItem().direction(.column)
//                            .define { flex in
//                                flex.addItem(likeIcon)
//                                    .size(24)
//                                flex.addItem(likeCount)
//                            }
                    }
                flex.addItem().direction(.row)
                    .gap(4)
                    .paddingHorizontal(20)
                    .alignItems(.baseline)
                    .define { flex in
                        flex.addItem(placeIcon)
                            .size(12)
                            .marginTop(5)
                        flex.addItem(addressLabel)
                            .alignSelf(.start)
                            .maxWidth(UIScreen.main.bounds.width / 1.3392)
                        flex.addItem(copyIcon)
                            .size(12)
                            .marginTop(5)
                    }
                flex.addItem().direction(.row).gap(4).paddingLeft(20).alignItems(.center).marginTop(2).define { flex in
                    flex.addItem(callIcon).size(12)
                    flex.addItem(phoneNumberLabel)
                }

                
                // 당첨 이력 섹션
//                if !hasWinningHistory {
//                    flex.addItem().height(1).backgroundColor(.clear).marginTop(24).marginHorizontal(20)
//                    
//                    flex.addItem()
//                        .direction(.column)
//                        .gap(8)
//                        .alignItems(.center)
//                        .paddingVertical(44)
//                        .define { flex in
//                        flex.addItem(noWinningHistoryCharacter).size(100)
//                        flex.addItem(noWinningHistoryLabel)
//                    }
//                    .backgroundColor(.gray10)
//                } else {
//                    
//                    flex.addItem().direction(.row).justifyContent(.spaceBetween).alignItems(.center).paddingLeft(20).marginTop(12).define { flex in
//                        flex.addItem().direction(.row).gap(8).define { flex in
//                            flex.addItem().direction(.row).gap(2).alignItems(.center).paddingVertical(4).paddingHorizontal(8).define { flex in
//                                flex.addItem(lottoIcon).size(12)
//                                flex.addItem(lottoLabel)
//                                flex.addItem(lottoWinningCount)
//                            }
//                            .backgroundColor(.gray20)
//                            .cornerRadius(8)
//                            
//                            flex.addItem().direction(.row).gap(2).alignItems(.center).paddingVertical(4).paddingHorizontal(8).define { flex in
//                                flex.addItem(pensionLotteryIcon).size(12)
//                                flex.addItem(pensionLotteryLabel)
//                                flex.addItem(pensionLotteryWinningCount)
//                            }
//                            .backgroundColor(.gray20)
//                            .cornerRadius(8)
//                            
//                            flex.addItem().direction(.row).gap(2).alignItems(.center).paddingVertical(4).paddingHorizontal(8).define { flex in
//                                flex.addItem(speetoIcon).size(12)
//                                flex.addItem(speetoLabel)
//                                flex.addItem(speetoWinningCount)
//                            }
//                            .backgroundColor(.gray20)
//                            .cornerRadius(8)
//                        }
//                    }
                    
//                    flex.addItem().height(1).backgroundColor(.gray20).marginTop(20).marginHorizontal(20)
                    
//                    flex.addItem(winningTags)
//                        .width(100%)
//                        .height(184)
                    
//                    winningTags.configure(with: store.lottoInfos)
//                }
            }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    func bind(reactor: MapViewReactor) {
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
    
    // store 타입 변경 필요
    func updateStoreInfo(with store: StoreDetailInfo, currentLocation: CLLocation?) {
        rootFlexContainer.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        // 태그 표시 설정 - 로또 타입에 따라 표시/숨김 처리
        let showLottoTag = store.lottoTypeList.contains("L645")
        let showPensionTag = store.lottoTypeList.contains("L720")
        let showSpeetoTag = store.lottoTypeList.contains("S1000") || store.lottoTypeList.contains("S2000")
        
        // 스토어 기본 정보 업데이트
        storeName.text = store.storeNm
        addressLabel.text = store.storeAddr
        phoneNumberLabel.text = store.storeTel.isEmpty ? "-" : store.storeTel
        
        // 당첨 횟수 업데이트
        let lottoWins = store.lottoInfos.filter { $0.lottoType == "L645" }.count
        let pensionWins = store.lottoInfos.filter { $0.lottoType == "L720" }.count
        let speetoWins = store.lottoInfos.filter { $0.lottoType.hasPrefix("S") }.count
        
        lottoWinningCount.text = lottoWins > 0 ? "\(lottoWins)회" : "0회"
        pensionLotteryWinningCount.text = pensionWins > 0 ? "\(pensionWins)회" : "0회"
        speetoWinningCount.text = speetoWins > 0 ? "\(speetoWins)회" : "0회"
        
        storeDistance.text = store.distance
        
        // 당첨 이력 유무 확인
        let hasWinningHistory = store.lottoInfos.count > 0
        
        // 레이아웃 재구성
        rootFlexContainer.flex.direction(.column)
            .define { flex in
                // 로또 타입 태그 섹션
                flex.addItem().direction(.row)
                    .gap(4)
                    .paddingLeft(20)
                    .define { flex in
                        if showLottoTag {
                            flex.addItem(lottoTypeTag)
                                .width(37)
                                .height(22)
                                .backgroundColor(.green5)
                                .cornerRadius(4)
                        }
                        if showPensionTag {
                            flex.addItem(pensionLotteryTypeTag)
                                .width(56)
                                .height(22)
                                .backgroundColor(.blue5)
                                .cornerRadius(4)
                        }
                        if showSpeetoTag {
                            flex.addItem(speetoTypeTag)
                                .width(46)
                                .height(22)
                                .cornerRadius(4)
                                .backgroundColor(.peach5)
                        }
                    }
                
                // 판매점 이름 및 거리 섹션
                flex.addItem().direction(.row)
                    .marginTop(8)
                    .paddingHorizontal(20)
                    .justifyContent(.spaceBetween)
                    .alignItems(.start)
                    .define { flex in
                        flex.addItem()
                            .gap(8)
                            .direction(.row)
                            .alignItems(.baseline)
                            .define { flex in
                                flex.addItem(storeName)
                                    .maxWidth(UIScreen.main.bounds.width / 1.4940)
                                flex.addItem(storeDistance)
                                    .marginTop(7)
                            }
                        
//                        flex.addItem().direction(.column)
//                            .define { flex in
//                                flex.addItem(likeIcon)
//                                    .size(24)
//                                flex.addItem(likeCount)
//                            }
                    }
                
                // 주소 섹션
                flex.addItem().direction(.row)
                    .gap(4)
                    .paddingHorizontal(20)
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
                
                // 전화번호 섹션
                flex.addItem().direction(.row).gap(4).paddingLeft(20).alignItems(.center).marginTop(2).define { flex in
                    flex.addItem(callIcon).size(12)
                    flex.addItem(phoneNumberLabel)
                }
                
                // 당첨 이력 섹션
//                if !hasWinningHistory {
//                    flex.addItem().height(1).backgroundColor(.clear).marginTop(24).marginHorizontal(20)
//                    flex.addItem()
//                        .direction(.column)
//                        .gap(8)
//                        .alignItems(.center)
//                        .paddingVertical(44)
//                        .define { flex in
//                        flex.addItem(noWinningHistoryCharacter).size(100)
//                        flex.addItem(noWinningHistoryLabel)
//                    }
//                    .backgroundColor(.gray10)
//                } else {
//                    // 로또 종류 당첨 정보 섹션
//                    flex.addItem().direction(.row).justifyContent(.spaceBetween).alignItems(.center).paddingLeft(20).marginTop(12).define { flex in
//                        flex.addItem().direction(.row).gap(8).define { flex in
//                            if showLottoTag {
//                                flex.addItem().direction(.row).gap(2).alignItems(.center).paddingVertical(4).paddingHorizontal(8).define { flex in
//                                    flex.addItem(lottoIcon).size(12)
//                                    flex.addItem(lottoLabel)
//                                    flex.addItem(lottoWinningCount)
//                                }
//                                .backgroundColor(.gray20)
//                                .cornerRadius(8)
//                            }
//                            
//                            if showPensionTag {
//                                flex.addItem().direction(.row).gap(2).alignItems(.center).paddingVertical(4).paddingHorizontal(8).define { flex in
//                                    flex.addItem(pensionLotteryIcon).size(12)
//                                    flex.addItem(pensionLotteryLabel)
//                                    flex.addItem(pensionLotteryWinningCount)
//                                }
//                                .backgroundColor(.gray20)
//                                .cornerRadius(8)
//                            }
//                            
//                            if showSpeetoTag {
//                                flex.addItem().direction(.row).gap(2).alignItems(.center).paddingVertical(4).paddingHorizontal(8).define { flex in
//                                    flex.addItem(speetoIcon).size(12)
//                                    flex.addItem(speetoLabel)
//                                    flex.addItem(speetoWinningCount)
//                                }
//                                .backgroundColor(.gray20)
//                                .cornerRadius(8)
//                            }
//                        }
//                    }
//                    
//                    flex.addItem().height(1).backgroundColor(.gray20).marginTop(20).marginHorizontal(20)
//                    flex.addItem(winningTags)
//                        .width(100%)
//                        .height(184)
//                    winningTags.configure(with: store.lottoInfos)
//                }
            }
        
        // 레이아웃 즉시 업데이트
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // 거리 포맷팅 헬퍼 메서드
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance >= 1000 {
            return String(format: "%.1fkm", distance / 1000)
        } else {
            return String(format: "%.0fm", distance)
        }
    }
}

#Preview {
    let view = SingleStoreDetailBottomSheetView()
    return view
}
