//
//  RegionAvailabilityBottomSheetVC.swift
//  LottoMate
//
//  Created by Mirae on 2/16/25.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxRelay

/**
 서비스 가능 지역 여부를 안내하는 바텀시트
 */
class RegionAvailabilityBottomSheetVC: UIViewController {
    // MARK: - Properties
    fileprivate let rootFlexContainer = UIView()
    var disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "오픈 안내"
        styleLabel(
            for: label,
            fontStyle: .headline1,
            textColor: .black,
            alignment: .left
        )
        return label
    }()
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "현재는 서울 지역의 로또 매장 정보만 확인할 수 있어요\r다른 지역은 준비 중이니 조금만 기다려주세요"
        styleLabel(
            for: label,
            fontStyle: .body2,
            textColor: .black,
            alignment: .left
        )
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = StyledButton(
            title: "확인",
            buttonStyle: .solid(.large, .active),
            cornerRadius: 8,
            verticalPadding: 12,
            horizontalPadding: 0
        )
        return button
    }()
    
    let confirmButtonTapped = PublishRelay<Void>()
    
    private let regionRequestButton: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "지도 오픈 요청하기"
        styleLabel(
            for: label,
            fontStyle: .caption1,
            textColor: .gray100
        )
        let rightArrowIcon = UIImageView()
        let image = UIImage(named: "icon_arrow_right_in_button")
        rightArrowIcon.image = image
        rightArrowIcon.contentMode = .scaleAspectFit
        
        view
            .flex
            .direction(.row)
            .gap(4)
            .alignItems(.center)
            .define { flex in
                flex.addItem(label)
                flex.addItem(rightArrowIcon)
                    .size(14)
            }
        return view
    }()
    
    private let image = CommonImageView(imageName: "pochi_bowing")
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupBindings()
        calculateContentSize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.top(view.safeAreaInsets.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    private func setupLayout() {
        view.addSubview(rootFlexContainer)
        
        rootFlexContainer
            .flex
            .direction(.column)
            .gap(24)
            .paddingVertical(28)
            .paddingHorizontal(20)
            .backgroundColor(.white)
            .define { flex in
                
                flex.addItem()
                    .direction(.column)
                    .gap(4)
                    .define { flex in
                        flex.addItem(titleLabel)
                        flex.addItem(bodyLabel)
                    }
                
                flex.addItem(image)
                    .size(100)
                    .alignSelf(.center)
                
                flex.addItem()
                    .direction(.column)
                    .alignItems(.center)
                    .gap(16)
                    .define { flex in
                        flex.addItem(confirmButton)
                            .width(100%)
                        flex.addItem(regionRequestButton)
                    }
            }
    }
    
    private func setupBindings() {
        confirmButton.rx.tap
            .bind(to: confirmButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func calculateContentSize() {
        view.layoutIfNeeded()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        // Bottom safe area 구하기
        let keyWindow = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
            
        let bottomInset = keyWindow?.safeAreaInsets.bottom ?? 0
        
        // 각 요소들의 크기 계산
        let titleHeight = titleLabel.sizeThatFits(
            CGSize(width: view.bounds.width - 40, height: .greatestFiniteMagnitude)
        ).height
        
        let bodyHeight = bodyLabel.sizeThatFits(
            CGSize(width: view.bounds.width - 40, height: .greatestFiniteMagnitude)
        ).height
        
        // 고정된 크기와 간격들
        let imageHeight: CGFloat = 100
        let buttonHeight: CGFloat = 46 // StyledButton의 large 크기
        let regionRequestHeight: CGFloat = 18 // 대략적인 크기
        
        // 간격들
        let verticalPadding: CGFloat = 28 * 2 // top + bottom
        let mainGap: CGFloat = 24 * 2 // 주요 요소 사이의 간격
        let labelGap: CGFloat = 4 // 타이틀과 바디 텍스트 사이 간격
        let buttonGap: CGFloat = 16 // 버튼들 사이의 간격
        
        // 전체 높이 계산
        let totalHeight = titleHeight +
        labelGap +
        bodyHeight +
        imageHeight +
        mainGap +
        buttonHeight +
        buttonGap +
        regionRequestHeight +
        verticalPadding -
        bottomInset
        
        print("bottom safeAreaInsets: \(bottomInset)")
        
        preferredContentSize = CGSize(
            width: view.bounds.width,
            height: totalHeight
        )
    }
}

