//
//  DrawRoundBottomSheet.swift
//  LottoMate
//
//  Created by Mirae on 9/6/24.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxGesture

class DrawRoundBottomSheet: UIView {
    let viewModel = LottoMateViewModel.shared
    fileprivate let rootFlexContainer = UIView()
    private let disposeBag = DisposeBag()
    private var scrollView = UIScrollView()
    
    private let pickerTitleLabel = UILabel()
    public let cancelButton = StyledButton(title: "취소", buttonStyle: .assistive(.large, .active), cornerRadius: 8, verticalPadding: 12, horizontalPadding: 0)
    public let confirmButton = StyledButton(title: "확인", buttonStyle: .solid(.large, .active), cornerRadius: 8, verticalPadding: 12, horizontalPadding: 0)
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        styleLabels()
        drawRoundInfo()
        addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.column).paddingTop(32).paddingBottom(28).define { flex in
            flex.addItem(pickerTitleLabel).alignSelf(.start).paddingHorizontal(20).marginBottom(14)
            flex.addItem(scrollView).direction(.column).height(120).minWidth(0).maxWidth(.infinity).define { flex in
                for i in (1..<30).reversed() {
                    let roundLabel = UILabel()
                    let dateLabel = UILabel()
                    
                    roundLabel.text = "\(i)회"
                    dateLabel.text = "2024.06.24"
                    
                    styleLabel(for: roundLabel, fontStyle: .headline1, textColor: .black)
                    styleLabel(for: dateLabel, fontStyle: .body1, textColor: .black)
                    
                    roundLabel.rx.tapGesture()
                        .when(.recognized)
                        .subscribe(onNext: { [weak self] _ in
                            guard let self = self else { return }
                            print("\(roundLabel.text ?? "레이블")")
                        })
                        .disposed(by: disposeBag)
                    
                    flex.addItem().direction(.row).height(40).width(100%).justifyContent(.center).gap(20).define { flex in
                        flex.addItem(roundLabel)
                        flex.addItem(dateLabel)
                    }.backgroundColor(i == 28 ? .red5 : .white)
                }
            }
            
            flex.addItem().direction(.row).justifyContent(.spaceBetween).gap(15).paddingHorizontal(20).marginTop(14).define { flex in
                flex.addItem(cancelButton).grow(1)
                flex.addItem(confirmButton).grow(1)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        scrollView.contentSize = CGSize(width: rootFlexContainer.bounds.width, height: 600) // 예시로 높이를 설정
    }
    
    private func styleLabels() {
        pickerTitleLabel.text = "회차 선택"
        styleLabel(for: pickerTitleLabel, fontStyle: .headline1, textColor: .black)
    }
    
    private func drawRoundInfo() {
        viewModel.latestLotteryResult
            .subscribe(onNext: { result in
                guard let latestLottoRound = result?.the645.drwNum,
                      let drawRoundDate = result?.the645.drwDate else { return }
                
                // 30개 만들어보기
                for round in (latestLottoRound-30...latestLottoRound).reversed() {
                    let roundLabel = UILabel()
                    let dateLabel = UILabel()
                    
                    roundLabel.text = "\(round)회"
                    dateLabel.text = "\(drawRoundDate.reformatDate)"
                    
                    styleLabel(for: roundLabel, fontStyle: .headline1, textColor: .black)
                    styleLabel(for: dateLabel, fontStyle: .body1, textColor: .black)
                    
                }
            })
            .disposed(by: disposeBag)
        
    }
}

#Preview {
    let view = DrawRoundBottomSheet()
    return view
}
