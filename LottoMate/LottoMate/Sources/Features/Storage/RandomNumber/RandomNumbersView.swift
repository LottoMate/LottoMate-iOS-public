//
//  MyNumberView.swift
//  LottoMate
//
//  Created by Mirae on 10/25/24.
//

import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import RxSwift
import RxCocoa
import RxGesture

protocol RandomNumbersViewDelegate: AnyObject {
    func randomNumbersViewDidUpdateContent()
}

class RandomNumbersView: UIView, View {
    
    weak var delegate: RandomNumbersViewDelegate?
    
    fileprivate let rootFlexContainer = UIView()
    var disposeBag = DisposeBag()
    
    internal var loadingView: RandomNumbersLoadingView?
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "행운의 랜덤 뽑기"
        styleLabel(for: label, fontStyle: .title3, textColor: .gray100)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let bodyLabel: UILabel = {
       let label = UILabel()
        label.text = "무제한으로 뽑을 수 있어요"
        styleLabel(for: label, fontStyle: .body1, textColor: .gray100)
        return label
    }()
    
    private let fileIcon: UIImageView = {
        let imageView = UIImageView()
        let iconImage = UIImage(named: "icon_file")
        imageView.image = iconImage
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray100
        return imageView
    }()
    
    private let characters: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ch_randomNumberView")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let getRandomNumbersButton: StyledButton = {
        let button = StyledButton(
            title: "랜덤 뽑기",
            buttonStyle: .solid(.large, .active),
            cornerRadius: 8,
            verticalPadding: 12,
            horizontalPadding: 0)
        return button
    }()
    
    private let todaysRandomNumbersTitle: UILabel = {
        let label = UILabel()
        label.text = "오늘 뽑은 번호"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black)
        return label
    }()
    
    private let todaysRandomNumbersBody: UILabel = {
        let label = UILabel()
        label.text = "오늘이 지나면 뽑은 번호는 사라져요"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
        return label
    }()
    
    private let contentContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private var randomNumbersView: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        view.flex.paddingBottom(20)
        
        return view
    }()
    
    private let emptyRandomNumbersView: UIView = {
        let view = UIView()
        
        let height = UIScreen.main.bounds.width / 1.704
        
        view.backgroundColor = .gray10
        
        let imageView = UIImageView()
        let image = UIImage(named: "ch_emptyRandomNumbers")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "아직 저장된 내 로또가 없어요."
        styleLabel(for: label, fontStyle: .body2, textColor: .gray100)
        
        view.flex.direction(.column)
            .justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                
                let screenWidth = UIScreen.main.bounds.width
                let aspectRatio: CGFloat = 3.57
                let size = screenWidth / aspectRatio
                
                flex.addItem(imageView)
                    .size(size)
                    .marginBottom(8)
                flex.addItem(label)
                
            }
            .width(100%)
            .height(height)
        
        return view
    }()
    
    private let moreNumbersLabel: UILabel = {
        let label = UILabel()
        label.text = "더 보기"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray100)
        return label
    }()
    
    private let downArrowIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "icon_arrow_down")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var currentDisplayCount = 5
    private var allRandomNumbers: [[Int]] = []
    
    private let moreNumbersView: UIView = {
        let view = UIView()
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(rootFlexContainer)
        
        rootFlexContainer.flex
            .direction(.column)
//            .paddingTop(32)
//            .paddingBottom(66)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .justifyContent(.spaceBetween)
                    .paddingHorizontal(20)
                    .define { flex in
                        flex.addItem().direction(.column).alignItems(.start).define { flex in
                            flex.addItem(subTitleLabel)
                            flex.addItem(titleLabel).width(100%)
                            flex.addItem(bodyLabel)
                        }
                        .grow(1)
                        
                        flex.addItem(fileIcon)
                            .size(24)
                    }
                
                let screenWidth = UIScreen.main.bounds.width
                let aspectRatio: CGFloat = 1.1272
                let height = screenWidth / aspectRatio
                
                flex.addItem().direction(.column).paddingBottom(4).define { flex in
                    flex.addItem(characters)
                        .width(screenWidth)
                        .height(height)
                        .marginTop(35.32)
                        .alignSelf(.center)
                    
                    flex.addItem(getRandomNumbersButton)
                        .height(48)
                        .marginHorizontal(20)
                        .marginTop(-52)
                }
                
                flex.addItem()
                    .direction(.column)
                    .alignItems(.start)
                    .paddingHorizontal(20)
                    .marginTop(36)
                    .marginBottom(16)
                    .define { flex in
                        flex.addItem(todaysRandomNumbersTitle)
                        flex.addItem(todaysRandomNumbersBody)
                    }
                
                flex.addItem(contentContainer)
                    .grow(1)
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    func bind(reactor: StorageViewReactor) {
        getRandomNumbersButton.rx.tap
            .map { StorageViewReactor.Action.generateRandomNumbers }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.temporaryRandomNumbers }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] allRandomNumbers in
                let reversedNumbers = Array(allRandomNumbers.reversed())
                self?.allRandomNumbers = reversedNumbers
                self?.updateTodaysRandomNumbersView(randomNumbers: reversedNumbers)
                self?.addTodaysRandomNumbersView(randomNumbers: reversedNumbers)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { count -> NSAttributedString in
                if count.generationCount == 0 {
                    let fullText = "오늘의 행운을 뽑아보세요"
                    return NSMutableAttributedString(
                        string: fullText,
                        attributes: Typography.title2.attributes(alignment: .left)
                    )
                } else if count.generationCount > 99 {
                    let fullText = "오늘 99+번째 돌렸어요"
                    return NSMutableAttributedString(
                        string: fullText,
                        attributes: Typography.title2.attributes(alignment: .left)
                    )
                } else {
                    let countText = "\(count.generationCount)"
                    let fullText = "오늘 \(countText)번째 돌렸어요"
                    return NSMutableAttributedString(
                        string: fullText,
                        attributes: Typography.title2.attributes(alignment: .left)
                    )
                }
            }
            .bind(to: titleLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        moreNumbersView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.moreButtonTapped()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.RandomNumberisLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading(with: reactor)
                } else {
                    self?.hideLoading()
                }
            })
            .disposed(by: disposeBag)
        
        fileIcon.rx.tapGesture()
            .when(.recognized)
            .map { _ in StorageViewReactor.Action.showSavedNumbersView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.showSavedNumbersView }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] showSavedNumbersView in
                if showSavedNumbersView {
                    self?.showSavedNumbersView()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.numbersCopied }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { _ in
                ToastView.show(message: "로또 번호를 복사했어요", horizontalPadding: 188)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.permanentRandomNumbers }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { _ in
                ToastView.show(message: "로또 번호를 저장했어요", horizontalPadding: 188)
            })
            .disposed(by: disposeBag)
            
        reactor.state
            .map { $0.error }
            .distinctUntilChanged { $0?.localizedDescription == $1?.localizedDescription }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                ToastView.show(message: "문제가 생겼어요\r다시 한 번 더 시도해주세요", horizontalPadding: 172, height: 68)
            })
            .disposed(by: disposeBag)
    }
    
    func updateTodaysRandomNumbersView(randomNumbers: [[Int]]) {
        contentContainer.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        let view: UIView = {
            if randomNumbers.count > 0 {
                // 오늘 뽑은 숫자 뷰
                return randomNumbersView
            } else {
                return emptyRandomNumbersView
            }
        }()
        
        // 최소 높이 설정
        let height = UIScreen.main.bounds.width / 1.704
        
        contentContainer.flex.define { flex in
            flex.addItem(view)
                .grow(1)
                .minHeight(height)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func addTodaysRandomNumbersView(randomNumbers: [[Int]]) {
        // 기존 뷰 제거
        randomNumbersView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        // 애니메이션 비활성화
        CATransaction.begin()
        CATransaction.setDisableActions(true)
                
        let displayNumbers = Array(randomNumbers.prefix(currentDisplayCount))
        
        // 5개마다 구분선을 그리기 위한 카운터
        var counter = 0
                
        displayNumbers.forEach { numbersArray in
            let numberBallsView: UIView = {
                let view = UIView()
                view.backgroundColor = .white
                return view
            }()
            
            numberBallsView.flex.direction(.row).justifyContent(.spaceBetween).paddingVertical(4).define { flex in
                flex.addItem().direction(.row).gap(8).define { flex in
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
                    let image = UIImage(named: "icon_copy_big")?.withRenderingMode(.alwaysTemplate)
                    imageView.image = image
                    imageView.contentMode = .scaleAspectFit
                    imageView.tintColor = .gray100
                    return imageView
                }()
                
                let saveIcon: UIImageView = {
                    let imageView = UIImageView()
                    let image = UIImage(named: "icon_save")?.withRenderingMode(.alwaysTemplate)
                    imageView.image = image
                    imageView.contentMode = .scaleAspectFit
                    imageView.tintColor = .gray100
                    return imageView
                }()
                
                if let reactor = reactor {
                    copyIcon.rx.tapGesture()
                        .when(.recognized)
                        .subscribe(onNext: { _ in reactor.action.onNext(.copyToClipboard(numbersArray)) })
                        .disposed(by: disposeBag)
                    
                    saveIcon.rx.tapGesture()
                        .when(.recognized)
                        .map { _ in StorageViewReactor.Action.savePermanently(numbersArray) }
                        .bind(to: reactor.action)
                        .disposed(by: disposeBag)
                }
                
                flex.addItem().direction(.row).gap(8).define { flex in
                    flex.addItem(copyIcon).size(24)
                    flex.addItem(saveIcon).size(24)
                }
            }
            
            // 레이아웃 즉시 적용
            numberBallsView.flex.layout()
            
            randomNumbersView.flex.direction(.column).gap(8).paddingHorizontal(20).define { flex in
                flex.addItem(numberBallsView)
                
                // 5개마다 구분선 추가 (마지막 항목이 아닐 경우에만)
                counter += 1
                if counter % 5 == 0 && counter < displayNumbers.count {
                    let divider = UIView()
                    divider.backgroundColor = .gray20
                    flex.addItem(divider).height(1).marginVertical(16)
                }
            }
        }
        
        if currentDisplayCount < randomNumbers.count {
            randomNumbersView.flex.direction(.column).define { flex in
                flex.addItem(moreNumbersView).direction(.row).gap(4).alignSelf(.center).alignItems(.center).paddingTop(16).define { flex in
                    flex.addItem(moreNumbersLabel)
                    flex.addItem(downArrowIcon).size(14)
                }
            }
        }
        
        // 전체 레이아웃 즉시 적용
        randomNumbersView.flex.layout()
        
        CATransaction.commit()
        
        // 레이아웃 업데이트
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func moreButtonTapped() {
        currentDisplayCount += 10
        
        addTodaysRandomNumbersView(randomNumbers: allRandomNumbers)
        
        setNeedsLayout()
        layoutIfNeeded()
        
        rootFlexContainer.pin.top().left().right()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        delegate?.randomNumbersViewDidUpdateContent()
    }
    
    func showSavedNumbersView() {
        let savedNumbersViewController = SavedNumbersViewController()
        savedNumbersViewController.reactor = reactor
        
        if let window = WindowManager.findKeyWindow() {
            savedNumbersViewController.view.frame = window.bounds
            
            if let rootViewController = window.rootViewController {
                rootViewController.addChild(savedNumbersViewController)
                rootViewController.view.addSubview(savedNumbersViewController.view)
                
                savedNumbersViewController.view.transform = CGAffineTransform(translationX: 0, y: window.bounds.height)
                
                UIView.animate(withDuration: 0.3,
                             delay: 0,
                             usingSpringWithDamping: 0.8,
                             initialSpringVelocity: 0.5,
                             options: .curveEaseOut) {
                    savedNumbersViewController.view.transform = .identity
                } completion: { _ in
                    savedNumbersViewController.didMove(toParent: rootViewController)
                }
                
                savedNumbersViewController.changeStatusBarBgColor(bgColor: .commonNavBar)
            }
        }
    }
}

extension RandomNumbersView: LoadingDisplayable { }

#Preview {
    let view = RandomNumbersView()
    return view
}
