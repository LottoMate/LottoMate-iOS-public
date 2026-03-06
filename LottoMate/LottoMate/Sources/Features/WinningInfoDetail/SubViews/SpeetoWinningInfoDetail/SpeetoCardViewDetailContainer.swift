//
//  SpeetoCardViewDetailContainer.swift
//  LottoMate
//
//  Created by Mirae on 8/21/24.
//

import UIKit
import ReactorKit
import PinLayout
import FlexLayout

class SpeetoCardViewDetailContainer: UIView, View {
    typealias Reactor = SpeetoWinningInfoReactor
    var disposeBag = DisposeBag()
    
    /// 당첨 상세 정보 컨테이너 (회색 배경)
    let prizeInfoDetailContainer = UIView()
    /// 판매점 타이틀 아이콘
    let homeIcon = CommonImageView(imageName: "icon_home")
    /// 판매점 이름 레이블
    var storeNameValueLabel = UILabel()
    /// 당첨 회차 레이블
    let winningRoundLabel = UILabel()
    /// 당첨자 인터뷰 버튼 레이블
    var winnerInterViewTextLabel = UILabel()
    /// 당첨자 인터뷰 버튼 right arrow
    var winnerInterViewArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_arrow_right_in_button")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    /// 지급일 레이블
    var prizePaymentDateLabel = UILabel()
    
    fileprivate let rootFlexContainer = UIView()
    
    init(winningStore: SpeetoWinningStore) {
        super.init(frame: .zero)
        
        setupDetailInfoContainer(for: winningStore)
        
        rootFlexContainer.flex.direction(.column).paddingVertical(16).paddingHorizontal(20).define { flex in
            // row 1
            flex.addItem().direction(.row).justifyContent(.spaceBetween).shrink(1).define { flex in
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .shrink(1)
                    .define { flex in
                        flex.addItem(homeIcon).size(18).marginRight(4)
                        flex.addItem(storeNameValueLabel).marginRight(20).shrink(1)
                    }
                // 1등일때만 당첨자 인터뷰 이동 버튼 나타남
                if winningStore.place == 1 {
                    flex.addItem().direction(.row).define { flex in
                        flex.addItem(winnerInterViewTextLabel).marginRight(4) // 당첨자 인터뷰
                        flex.addItem(winnerInterViewArrow) // 당첨자 인터뷰 arrow icon
                    }
                }
            }
            
            flex.addItem().direction(.row).marginTop(8).define { flex in
                flex.addItem(winningRoundLabel).marginRight(10)
                flex.addItem(prizePaymentDateLabel) // 지급 날짜
            }
        }
        
        addSubview(rootFlexContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    func setupDetailInfoContainer(for winningStore: SpeetoWinningStore) {
        rootFlexContainer.backgroundColor = .gray_F9F9F9
        rootFlexContainer.layer.cornerRadius = 8
        
        winnerInterViewTextLabel.text = "당첨자 인터뷰"
        styleLabel(for: winnerInterViewTextLabel, fontStyle: .caption1, textColor: .gray100)
        winnerInterViewArrow.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
        
        winningRoundLabel.text = "\(winningStore.drwNum)회차"
        
        styleLabel(for: winningRoundLabel, fontStyle: .label2, textColor: .gray100)
        
        storeNameValueLabel.text = "\(winningStore.storeNm)"
        styleLabel(for: storeNameValueLabel, fontStyle: .headline2, textColor: .black)
        
        prizePaymentDateLabel.text = "\(winningStore.payDate.reformatDate) 지급"
        styleLabel(for: prizePaymentDateLabel, fontStyle: .label2, textColor: .gray100)
    }
    
    func bind(reactor: SpeetoWinningInfoReactor) {
        //
    }
}
