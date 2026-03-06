//
//  LotteryTypeInfoView.swift
//  LottoMate
//
//  Created by Mirae on 11/14/24.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxRelay

class LotteryTypeInfoView: UIView {
    fileprivate let rootFlexContainer = UIView()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    let confirmButtonTapped = PublishRelay<Void>()
    
    private let lotteryTypeTitleLabel = CommonHeadline1Label(text: "복권 종류")
    private let lotteryTypeSubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "동행복권에서 판매하는 복권 중 가장 인기있는 복권을 소개해요."
        styleLabel(for: label, fontStyle: .label1, textColor: .black, alignment: .left)
        return label
    }()
    private let lottoInfoView: UIView = {
        let view = UIView()
        let image = CommonImageView(imageName: "lotto_info")
        let lottoTitie: UILabel = {
            let label = UILabel()
            label.text = "로또 6/45"
            styleLabel(for: label, fontStyle: .headline2, textColor: .black, alignment: .left)
            return label
        }()
        let infoTextArray = [
            " •  1개 당 1,000원",
            " •  1~45개 숫자 중 6개 선택",
            " •  추첨 번호와 내 번호가 일치 시 당첨",
            " •  매주 토요일 오후 8시 45분에 추첨"
        ]
        view.flex.direction(.row)
            .alignItems(.center)
            .gap(4)
            .define { flex in
                flex.addItem(image)
                    .size(80)
                flex.addItem()
                    .direction(.column)
                    .alignItems(.start)
                    .define { flex in
                        flex.addItem(lottoTitie)
                            .marginBottom(12)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .alignItems(.start)
                            .define { flex in
                                infoTextArray.forEach { text in
                                    let InfoText: UILabel = {
                                       let label = UILabel()
                                        label.text = text
                                        styleLabel(for: label, fontStyle: .body1, textColor: .black, alignment: .left)
                                        return label
                                    }()
                                    flex.addItem(InfoText)
                                }
                            }
                    }
            }
        return view
    }()
    private let pensionLotteryInfoView: UIView = {
        let view = UIView()
        let image = CommonImageView(imageName: "pension_info")
        let pensionLotteryTitie: UILabel = {
            let label = UILabel()
            label.text = "연금복권 720+"
            styleLabel(for: label, fontStyle: .headline2, textColor: .black, alignment: .left)
            return label
        }()
        let infoTextArray = [
            " •  1개 당 1,000원",
            " •  1~5조 선택 / 숫자 6개 선택",
            " •  추첨 번호와 내 번호가 일치 시 당첨",
            " •  매주 목요일 오후 7시 5분 쯤 추천"
        ]
        view.flex.direction(.row)
            .alignItems(.center)
            .gap(4)
            .define { flex in
                flex.addItem(image)
                    .size(80)
                flex.addItem()
                    .direction(.column)
                    .alignItems(.start)
                    .define { flex in
                        flex.addItem(pensionLotteryTitie)
                            .marginBottom(12)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .alignItems(.start)
                            .define { flex in
                                infoTextArray.forEach { text in
                                    let InfoText: UILabel = {
                                       let label = UILabel()
                                        label.text = text
                                        styleLabel(for: label, fontStyle: .body1, textColor: .black, alignment: .left)
                                        return label
                                    }()
                                    flex.addItem(InfoText)
                                }
                            }
                    }
            }
        
        return view
    }()
    private let speetoInfoView: UIView = {
        let view = UIView()
        let image = CommonImageView(imageName: "speeto_info")
        let speetoTitie: UILabel = {
            let label = UILabel()
            label.text = "스피또 2000 / 1000 / 500"
            styleLabel(for: label, fontStyle: .headline2, textColor: .black, alignment: .left)
            return label
        }()
        let infoTextArray = [
            " •  각 2000원, 1000원, 500원",
            " •  구매 후 긁어서 나온 모양 일치 시 당첨",
            " •  즉석에서 결과 확인 가능"
        ]
        view.flex.direction(.row)
            .alignItems(.center)
            .gap(4)
            .define { flex in
                flex.addItem(image)
                    .size(80)
                flex.addItem()
                    .direction(.column)
                    .alignItems(.start)
                    .define { flex in
                        flex.addItem(speetoTitie)
                            .marginBottom(12)
                        flex.addItem()
                            .direction(.column)
                            .gap(4)
                            .alignItems(.start)
                            .define { flex in
                                infoTextArray.forEach { text in
                                    let InfoText: UILabel = {
                                       let label = UILabel()
                                        label.text = text
                                        styleLabel(for: label, fontStyle: .body1, textColor: .black, alignment: .left)
                                        return label
                                    }()
                                    flex.addItem(InfoText)
                                }
                            }
                    }
            }
        
        
        return view
    }()
    
    let confirmButton = StyledButton(
        title: "확인",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    init() {
        super.init(frame: .zero)
        
        addSubview(scrollView)
        scrollView.addSubview(rootFlexContainer)
        
        rootFlexContainer.flex.direction(.column)
            .gap(32)
            .define { flex in
                flex.addItem().direction(.column)
                    .gap(4)
                    .alignItems(.start)
                    .define { flex in
                        flex.addItem(lotteryTypeTitleLabel)
                        flex.addItem(lotteryTypeSubTitleLabel)
                    }
                
                flex.addItem().direction(.column)
                    .gap(16)
                    .define { flex in
                        flex.addItem(lottoInfoView)
                        
                        flex.addItem()
                            .width(100%)
                            .height(1)
                            .backgroundColor(.gray20)
                        
                        flex.addItem(pensionLotteryInfoView)
                        
                        flex.addItem()
                            .width(100%)
                            .height(1)
                            .backgroundColor(.gray20)
                        
                        flex.addItem(speetoInfoView)
                    }
                flex.addItem(confirmButton)
            }
            .paddingTop(32)
            .paddingBottom(36)
            .paddingHorizontal(20)
        
        setupBindings()
    }
    
    private func setupBindings() {
        confirmButton.rx.tap
            .bind(to: confirmButtonTapped)
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.pin.all()
        
        rootFlexContainer.pin
            .top()
            .horizontally()
        
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        scrollView.contentSize = CGSize(width: frame.width, height: rootFlexContainer.frame.height)
    }
}

#Preview {
    let view = LotteryTypeInfoView()
    return view
}
