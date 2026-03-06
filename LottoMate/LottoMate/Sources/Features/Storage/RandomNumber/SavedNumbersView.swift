//
//  SavedNumbersView.swift
//  LottoMate
//
//  Created by Mirae on 10/31/24.
//

import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import RxSwift
import RxGesture

class SavedNumbersView: UIView, View {
    
    var disposeBag = DisposeBag()
    
    fileprivate let rootFlexContainer = UIView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "저장한 번호"
        styleLabel(for: label, fontStyle: .title3, textColor: .black)
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "저장한 행운의 번호를 확인해주세요."
        styleLabel(for: label, fontStyle: .body1, textColor: .gray80)
        return label
    }()
    
    private var savedNumbersView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
//        view.flex.paddingTop(34)
        return view
    }()
    
    private let emptySavedNumbersView: UIView = {
        let view = UIView()
        let imageView = UIImageView()
        let image = UIImage(named: "ch_emptyRandomNumbers")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        let label = UILabel()
        label.text = "저장한 번호가 없어요"
        styleLabel(for: label, fontStyle: .body2, textColor: .gray100)
        
        view.flex.direction(.column)
            .justifyContent(.center)
            .alignItems(.center)
            .define { flex in
            let screenWidth = UIScreen.main.bounds.width
                let aspectRatio: CGFloat = 2.6785
            let size = screenWidth / aspectRatio
            
            flex.addItem(imageView)
                .size(size)
                .marginBottom(8)
            flex.addItem(label)
        }
        .width(100%)
        
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
        
        let totalNavHeight = DeviceMetrics.statusWithNavigationBarHeight
        let marginTop = totalNavHeight + 16
        
        rootFlexContainer.flex
            .direction(.column)
            .marginTop(marginTop)
            .marginHorizontal(20)
            .define { flex in
                flex.addItem(titleLabel).alignSelf(.start)
                flex.addItem(subTitleLabel).alignSelf(.start)
                flex.addItem(savedNumbersView)
                    .grow(1)
            }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.all()
        rootFlexContainer.pin.top().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        let totalNavHeight = DeviceMetrics.statusWithNavigationBarHeight + 16 + 194
        scrollView.contentSize = CGSize(
            width: rootFlexContainer.frame.width,
            height: rootFlexContainer.frame.height + totalNavHeight
        )
    }
}

extension SavedNumbersView {
    func bind(reactor: StorageViewReactor) {
        reactor.state
            .map { $0.permanentRandomNumbers }
            .subscribe(onNext: { [weak self] numbers in
                if numbers.isEmpty {
                    self?.showEmptySavedNumbersView()
                } else {
                    self?.savedNumbersView(numbers)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func showEmptySavedNumbersView() {
        savedNumbersView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        let topPartHeight = 76.0 // titleLabel + subTitleLabel + 2 (gap) + 16 (top margin)
        let availableHeight = UIScreen.main.bounds.height - DeviceMetrics.statusWithNavigationBarHeight - 16 - titleLabel.frame.height - 2 - subTitleLabel.frame.height - 49
        
        savedNumbersView.flex
            .height(availableHeight)
            .direction(.column)
            .justifyContent(.center)
            .marginTop(-topPartHeight)
            .define { flex in
                flex.addItem(emptySavedNumbersView)
            }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func savedNumbersView(_ savedNumbers: [SavedLottoNumber]) {
        savedNumbersView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        let groupedNumbers = Dictionary(grouping: savedNumbers) { $0.formattedDate }
        let sortedDates = groupedNumbers.keys.sorted(by: >)
        
        savedNumbersView.flex.direction(.column).gap(16).define { flex in
            sortedDates.forEach { date in

                let dateHeaderLabel: UILabel = {
                    let label = UILabel()
                    label.text = date
                    styleLabel(for: label, fontStyle: .label2, textColor: .gray80)
                    return label
                }()
                
                flex.addItem().direction(.column).gap(12).define { flex in
                    flex.addItem(dateHeaderLabel).alignSelf(.start)
                    
                    if let savedLottoNumberData = groupedNumbers[date] {
                        savedLottoNumberData.forEach { data in
                            let numbersArray = data.numbers
                            flex.addItem().direction(.row).justifyContent(.spaceBetween).define { flex in
                                flex.addItem().direction(.row).gap(8).paddingVertical(4).define { flex in
                                    numbersArray.forEach { number in
                                        let numberBall = WinningNumberCircleView()
                                        let color = colorForNumber(number)
                                        numberBall.number = number
                                        numberBall.circleColor = color
                                        
                                        flex.addItem(numberBall).size(28)
                                    }
                                }

                                let copyIcon: UIImageView = {
                                    let imageView = UIImageView()
                                    let image = UIImage(named: "icon_copy_big")
                                    imageView.image = image
                                    imageView.contentMode = .scaleAspectFit
                                    return imageView
                                }()
                                
                                let deleteIcon: UIImageView = {
                                    let imageView = UIImageView()
                                    let image = UIImage(named: "icon_trash")
                                    imageView.image = image
                                    imageView.contentMode = .scaleAspectFit
                                    return imageView
                                }()
                                
                                if let reactor = reactor {
                                    deleteIcon.rx.tapGesture()
                                        .when(.recognized)
                                        .map { _ in StorageViewReactor.Action.deleteSavedNumbers(id: data.id) }
                                        .bind(to: reactor.action)
                                        .disposed(by: disposeBag)
                                }
                                
                                flex.addItem().direction(.row).gap(8).define { flex in
                                    flex.addItem(copyIcon).size(24)
                                    flex.addItem(deleteIcon).size(24)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}

#Preview {
    let view = SavedNumbersView()
    return view
}
