//
//  NumberEntryView.swift
//  LottoMate
//
//  Created by Mirae on 1/15/25.
//  로또 번호 등록

import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import RxSwift
import RxGesture


class NumberEntryView: UIView, View {
    fileprivate let rootFlexContainer = UIView()
    var disposeBag = DisposeBag()
    private var lottoInputsDisposeBag = DisposeBag()
    private var pensionInputsDisposeBag = DisposeBag()
    
    // Tag tracking for debugging
    private var usedTags: Set<Int> = []
    
    private let topMargin: CGFloat = {
        let topMargin = DeviceMetrics.navigationBarHeight
        return topMargin
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "내 복권 번호를 저장해 주세요"
        styleLabel(
            for: label,
            fontStyle: .title3,
            textColor: .black,
            alignment: .left
        )
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.text = "로또는 0까지 같이 입력해주세요 ex) 01, 05..."
        styleLabel(for: label, fontStyle: .body1, textColor: .gray80, alignment: .left)
        return label
    }()

    // MARK: - Lotto UI Components
    private let lottoNumberEntryContainer = UIView()
    
    private let lottoIconTitle: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "로또"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black)
        let icon = CommonImageView(imageName: "icon_lotto")
        
        view.flex
            .direction(.row)
            .gap(8)
            .alignSelf(.start)
            .alignItems(.center)
            .define { flex in
                flex.addItem(icon).size(24)
                flex.addItem(label)
            }
        return view
    }()
    
    private let lottoDrawingInfo = UIView()
    
    private let previousLottoRoundButton: UIButton = {
        let button = UIButton()
        let previousRoundBtnImage = UIImage(named: "icon_arrow_small_left")
        button.setImage(previousRoundBtnImage, for: .normal)
        button.tintColor = .gray100
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        return button
    }()
    
    private let nextRoundLottoButton: UIButton = {
        let button = UIButton()
        let nextRoundBtnImage = UIImage(named: "icon_arrow_small_right")
        button.setImage(nextRoundBtnImage, for: .normal)
        button.tintColor = .gray40
        button.frame = CGRect(x: 0, y: 0, width: 4, height: 10)
        return button
    }()
    
    var lottoDrawRound: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        styleLabel(for: label, fontStyle: .headline1, textColor: .black, alignment: .right)
        return label
    }()
    
    var lottoDrawDate: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        styleLabel(for: label, fontStyle: .label2, textColor: .gray_ACACAC, alignment: .left)
        return label
    }()
    
    private let paymentDeadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "로또 당첨금은 지급 기한이 최대 1년이에요"
        styleLabel(for: label, fontStyle: .caption2, textColor: .gray_ACACAC, alignment: .center)
        label.numberOfLines = 0
        label.isHidden = false
        return label
    }()
    
    // MARK: - Lotto Number Input Components
    private var lottoNumberInputs: [LottoNumberInputView] = []
    private let lottoNumberInputContainer = UIView()
    
    private let addMoreLottoNumbersButton = UIView()
    private let addMoreLottoNumbersButtonIcon = CommonImageView(imageName: "icon_plus")
    private let addMoreLottoNumbersButtonTitle: UILabel = {
        let label = UILabel()
        label.text = "번호 추가하기"
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray100)
        return label
    }()

    // MARK: - Pension Lottery UI Components
    private let pensionNumberEntryView = UIView()
    
    private let pensionLotteryIconTitle: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "연금복권"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black)
        let icon = CommonImageView(imageName: "icon_pensionLottery")
        
        view.flex
            .direction(.row)
            .gap(8)
            .alignSelf(.start)
            .alignItems(.center)
            .define { flex in
                flex.addItem(icon).size(24)
                flex.addItem(label)
            }
        return view
    }()
    
    
    private let pensionLotteryDrawingInfo = UIView()
    
    private let previousPensionLotteryRoundButton: UIButton = {
        let button = UIButton()
        let previousRoundBtnImage = UIImage(named: "icon_arrow_small_left")
        button.setImage(previousRoundBtnImage, for: .normal)
        button.tintColor = .gray100
        button.frame = CGRect(x: 0, y: 0, width: 4, height: 10)
        return button
    }()
    
    private let nextRoundPensionLotteryButton: UIButton = {
        let button = UIButton()
        let nextRoundBtnImage = UIImage(named: "icon_arrow_small_right")
        button.setImage(nextRoundBtnImage, for: .normal)
        button.tintColor = .gray40
        button.frame = CGRect(x: 0, y: 0, width: 4, height: 10)
        return button
    }()
    
    var pensionLotteryDrawRound: UILabel = {
        let label = UILabel()
        styleLabel(for: label, fontStyle: .headline1, textColor: .black, alignment: .right)
        return label
    }()
    
    var pensionLotteryDrawDate: UILabel = {
        let label = UILabel()
        styleLabel(for: label, fontStyle: .label2, textColor: .gray_ACACAC, alignment: .left)
        return label
    }()
    
    private var pensionNumberInputs: [PensionNumberInputView] = []
    private let pensionNumberInputContainer = UIView()

    // MARK: - Save Button
    private let saveButton = StyledButton(
        title: "번호 저장하기",
        buttonStyle: .solid(.large, .inactive),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    // MARK: - Temporary spacer for keyboard handling
    private let bottomSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    var addMorePensionNumbersButton: UIView = {
        let view = UIView()
        let icon = CommonImageView(imageName: "icon_plus")
        let buttonTitle = UILabel()
        buttonTitle.text = "번호 추가하기"
        
        styleLabel(for: buttonTitle, fontStyle: .caption1, textColor: .gray100)
        
        view.flex.direction(.row)
            .gap(4)
            .alignItems(.center)
            .define { flex in
                flex.addItem(icon)
                    .size(14)
                flex.addItem(buttonTitle)
                
            }
        return view
    }()

    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        setupAddMoreLottoNumbersButton()
        setupLottoNumberEntryContainer()
        setupPensionNumberEntryContainer()
        setupInitialLottoNumberInputView()
        setupInitialPensionNumberInputView()
        setupLayout()
        setupKeyboardDismissal()
        setupKeyboardHandling()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lotto Number Input Methods
    private func setupInitialLottoNumberInputView() {
        let initialInput = LottoNumberInputView()
        initialInput.onLayoutUpdate = { [weak self] in
            self?.relayout()
        }
        initialInput.onRemove = { [weak self] in
            self?.removeLottoNumberInputView(inputView: initialInput)
        }
        lottoNumberInputs.append(initialInput)
        updateLottoNumberInputContainer()
        updateAddMoreButtonVisibility()
        bindLottoInputObservables()
    }

    private func updateLottoNumberInputContainer() {
        // 기존 subview들을 모두 제거
        lottoNumberInputContainer.subviews.forEach { $0.removeFromSuperview() }
        
        lottoNumberInputContainer.flex
            .direction(.column)
            .gap(24)
            .define { flex in
                for input in lottoNumberInputs {
                    flex.addItem(input)
                }
            }
        
        rootFlexContainer.flex.layout()
    }
    
    private func updateAddMoreButtonVisibility() {
        let shouldHide = lottoNumberInputs.count >= 5
        addMoreLottoNumbersButton.isHidden = shouldHide

        if !shouldHide {
            addMoreLottoNumbersButton.isUserInteractionEnabled = false
            let color: UIColor = .gray40
            addMoreLottoNumbersButtonTitle.textColor = color
            addMoreLottoNumbersButtonIcon.tintColor = color
        }
    }
    
    private func removeLottoNumberInputView(inputView: LottoNumberInputView) {
        if lottoNumberInputs.count > 1 {
            lottoNumberInputs.removeAll { $0 === inputView }
            updateLottoNumberInputContainer()
            updateAddMoreButtonVisibility()
            relayout()
            bindLottoInputObservables()
        } else {
            lottoNumberInputs.first?.resetInput()
        }
    }
    
    private func addNewLottoNumberInputView() {
        guard lottoNumberInputs.count < 5 else {
            return
        }
        
        let newInput = LottoNumberInputView()
        newInput.onLayoutUpdate = { [weak self] in
            self?.relayout()
        }
        newInput.onRemove = { [weak self] in
            self?.removeLottoNumberInputView(inputView: newInput)
        }
        lottoNumberInputs.append(newInput)
        
        updateLottoNumberInputContainer()
        updateAddMoreButtonVisibility()
        bindLottoInputObservables()

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // Public method to get all lottery numbers
    func getAllLotteryNumbers() -> [[String]] {
        return lottoNumberInputs.map { $0.getNumbers() }
    }
    
    // Public method to get all lottery numbers as Int arrays
    func getAllLotteryNumbersAsInt() -> [[Int]] {
        return lottoNumberInputs.map { input in
            input.getNumbers().compactMap { Int($0) }
        }.filter { !$0.isEmpty }
    }
    
    private func bindLottoInputObservables() {
        lottoInputsDisposeBag = DisposeBag()

        guard let lastLottoInput = lottoNumberInputs.last else { return }

        lastLottoInput.anyTextFieldHasText
            .startWith(false)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                
                let canAddMore = self.lottoNumberInputs.count < 5
                // 2개 이상이면 항상 활성화, 2개 미만이면 텍스트 입력 여부에 따라 결정
                let shouldEnable = self.lottoNumberInputs.count >= 2 ? canAddMore : (isEnabled && canAddMore)

                self.addMoreLottoNumbersButton.isUserInteractionEnabled = shouldEnable
                let color: UIColor = shouldEnable ? .gray100 : .gray40
                self.addMoreLottoNumbersButtonTitle.textColor = color
                self.addMoreLottoNumbersButtonIcon.tintColor = color
                
                // 저장 버튼 활성화 상태 업데이트
                self.updateSaveButtonState()
            })
            .disposed(by: lottoInputsDisposeBag)
    }
    
    private func updateSaveButtonState() {
        let hasValidLottoNumbers = lottoNumberInputs.contains { input in
            let numbers = input.getNumbers().compactMap { Int($0) }
            return numbers.count == 6 && numbers.allSatisfy { $0 >= 1 && $0 <= 45 }
        }
        
        let hasValidPensionNumbers = pensionNumberInputs.contains { input in
            let numbers = input.getNumbers()
            return !numbers.isEmpty && numbers.allSatisfy { !$0.isEmpty }
        }
        
        let shouldEnable = hasValidLottoNumbers || hasValidPensionNumbers
        saveButton.style = shouldEnable ? .solid(.large, .active) : .solid(.large, .inactive)
    }
    
    // MARK: - Pension Number Input Methods
    private func setupInitialPensionNumberInputView() {
        let initialInput = PensionNumberInputView()
        initialInput.onLayoutUpdate = { [weak self] in
            self?.relayout()
        }
        initialInput.onRemove = { [weak self] in
            self?.removePensionNumberInputView(inputView: initialInput)
        }
        pensionNumberInputs.append(initialInput)
        updatePensionNumberInputContainer()
        updateAddMorePensionButtonVisibility()
        bindPensionInputObservables()
    }

    private func updatePensionNumberInputContainer() {
        pensionNumberInputContainer.subviews.forEach { $0.removeFromSuperview() }
        
        pensionNumberInputContainer.flex
            .direction(.column)
            .gap(24)
            .define { flex in
                for input in pensionNumberInputs {
                    flex.addItem(input)
                }
            }
        
        rootFlexContainer.flex.layout()
    }
    
    private func updateAddMorePensionButtonVisibility() {
        let shouldHide = pensionNumberInputs.count >= 5
        addMorePensionNumbersButton.isHidden = shouldHide

        if !shouldHide {
            addMorePensionNumbersButton.isUserInteractionEnabled = false
            let color: UIColor = .gray40
            addMorePensionNumbersButton.subviews.compactMap { $0 as? UILabel }.first?.textColor = color
            addMorePensionNumbersButton.subviews.compactMap { $0 as? CommonImageView }.first?.tintColor = color
        }
    }
    
    private func removePensionNumberInputView(inputView: PensionNumberInputView) {
        if pensionNumberInputs.count > 1 {
            pensionNumberInputs.removeAll { $0 === inputView }
            updatePensionNumberInputContainer()
            updateAddMorePensionButtonVisibility()
            relayout()
            bindPensionInputObservables()
        } else {
            pensionNumberInputs.first?.resetInput()
        }
    }
    
    private func addNewPensionNumberInputView() {
        guard pensionNumberInputs.count < 5 else {
            return
        }
        
        let newInput = PensionNumberInputView()
        newInput.onLayoutUpdate = { [weak self] in
            self?.relayout()
        }
        newInput.onRemove = { [weak self] in
            self?.removePensionNumberInputView(inputView: newInput)
        }
        pensionNumberInputs.append(newInput)
        
        updatePensionNumberInputContainer()
        updateAddMorePensionButtonVisibility()
        bindPensionInputObservables()

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func getAllPensionLotteryNumbers() -> [[String]] {
        return pensionNumberInputs.map { $0.getNumbers() }
    }
    
    private func bindPensionInputObservables() {
        pensionInputsDisposeBag = DisposeBag()

        guard let lastPensionInput = pensionNumberInputs.last else { return }

        lastPensionInput.anyTextFieldHasText
            .startWith(false)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                
                let canAddMore = self.pensionNumberInputs.count < 5
                let shouldEnable = isEnabled && canAddMore

                self.addMorePensionNumbersButton.isUserInteractionEnabled = shouldEnable
                let color: UIColor = shouldEnable ? .gray100 : .gray40
                self.addMorePensionNumbersButton.subviews.compactMap { $0 as? UILabel }.first?.textColor = color
                self.addMorePensionNumbersButton.subviews.compactMap { $0 as? CommonImageView }.first?.tintColor = color
                
                // 저장 버튼 활성화 상태 업데이트
                self.updateSaveButtonState()
            })
            .disposed(by: pensionInputsDisposeBag)
    }
    
    private func setupKeyboardDismissal() {
        // Add tap gesture to dismiss keyboard when tapping outside input fields
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let self = self, let userInfo = notification.userInfo,
                      let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                      let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                      let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
                      let curve = UIView.AnimationCurve(rawValue: curveRaw) else { return }

                let keyboardFrameInView = self.convert(keyboardFrame, from: nil)
                let obscuredHeight = self.bounds.intersection(keyboardFrameInView).height
                
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: obscuredHeight, right: 0)
                
                let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
                    self.scrollView.contentInset = contentInsets
                    self.scrollView.scrollIndicatorInsets = contentInsets
                }
                
                animator.addAnimations {
                    if let activeField = self.findActiveResponder(in: self) {
                        let activeFieldFrame = activeField.convert(activeField.bounds, to: self.scrollView)
                        self.scrollView.scrollRectToVisible(activeFieldFrame, animated: false)
                    }
                }
                
                animator.startAnimation()
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let self = self, let userInfo = notification.userInfo,
                      let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                      let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
                      let curve = UIView.AnimationCurve(rawValue: curveRaw) else {
                    self?.scrollView.contentInset = .zero
                    self?.scrollView.scrollIndicatorInsets = .zero
                    return
                }

                let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
                    self.scrollView.contentInset = .zero
                    self.scrollView.scrollIndicatorInsets = .zero
                }
                animator.startAnimation()
            })
            .disposed(by: disposeBag)
    }

    private func findActiveResponder(in view: UIView) -> UIView? {
        for subview in view.subviews {
            if subview.isFirstResponder {
                return subview
            }
            if let responder = findActiveResponder(in: subview) {
                return responder
            }
        }
        return nil
    }
    
    private func setupLayout() {
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
        
        rootFlexContainer.flex
            .direction(.column)
            .gap(40)
            .define { flex in
                flex.addItem()
                    .direction(.column)
                    .marginHorizontal(20)
                    .define { titleContainer in
                        titleContainer.addItem(titleLabel)
                            .marginTop(16)
                            .marginBottom(2)
                        titleContainer.addItem(secondaryLabel)
                    }
                    
                flex.addItem(lottoNumberEntryContainer)
                
                flex.addItem().height(10).backgroundColor(.gray20)
                
                flex.addItem(pensionNumberEntryView)
                
                flex.addItem(saveButton)
                    .marginHorizontal(20)
                    .marginTop(40)
                
                flex.addItem(bottomSpacer).height(100)
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.top().bottom().left().right()
        rootFlexContainer.pin.top(topMargin).left().right()
        
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
    }
    
    func setupLottoNumberEntryContainer() {
        lottoNumberEntryContainer.flex
            .direction(.column)
            .backgroundColor(.white)
            .define { flex in
                flex.addItem(lottoIconTitle)
                    .marginBottom(20)
                    .marginHorizontal(20)
                
                flex.addItem()
                    .direction(.row)
                    .justifyContent(.spaceBetween)
                    .paddingBottom(32)
                    .define { flex in
                        flex.addItem(previousLottoRoundButton)
                            .marginLeft(10)
                        
                        flex.addItem(lottoDrawingInfo)
                            .direction(.row)
                            .gap(8)
                            .grow(1)
                            .justifyContent(.center)
                            .define { flex in
                                flex.addItem(lottoDrawRound)
                                    .width(63)
                                flex.addItem(lottoDrawDate)
                                    .width(81)
                            }
                        
                        flex.addItem(nextRoundLottoButton)
                            .marginRight(10)
                    }
                
                flex.addItem(lottoNumberInputContainer)
                    .marginHorizontal(20)
                
                flex.addItem(addMoreLottoNumbersButton)
                    .alignSelf(.center)
                    .marginTop(24)
            }
    }
    
    func setupPensionNumberEntryContainer() {
        pensionNumberEntryView.flex
            .direction(.column)
            .backgroundColor(.white)
            .define { flex in
                flex.addItem(pensionLotteryIconTitle)
                    .marginBottom(20)
                    .marginHorizontal(20)
                
                flex.addItem()
                    .direction(.row)
                    .justifyContent(.spaceBetween)
                    .paddingBottom(32)
                    .define { flex in
                        flex.addItem(previousPensionLotteryRoundButton)
                            .marginLeft(10)
                        
                        flex.addItem(pensionLotteryDrawingInfo)
                            .direction(.row)
                            .gap(8)
                            .grow(1)
                            .justifyContent(.center)
                            .define { flex in
                                flex.addItem(pensionLotteryDrawRound)
                                    .width(63)
                                flex.addItem(pensionLotteryDrawDate)
                                    .width(81)
                            }
                        
                        flex.addItem(nextRoundPensionLotteryButton)
                            .marginRight(10)
                    }
                
                flex.addItem(pensionNumberInputContainer)
                    .marginHorizontal(20)
                
                flex.addItem(addMorePensionNumbersButton)
                    .alignSelf(.center)
                    .marginTop(24)
            }
    }
    
    private func setupAddMoreLottoNumbersButton() {
        addMoreLottoNumbersButton.flex.direction(.row)
            .gap(4)
            .alignItems(.center)
            .define { flex in
                flex.addItem(addMoreLottoNumbersButtonIcon)
                    .size(14)
                flex.addItem(addMoreLottoNumbersButtonTitle)
            }
    }
    
    private func relayout() {
        UIView.animate(withDuration: 0.2) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Reactor Binding
extension NumberEntryView {
    func bind(reactor: HomeViewReactor) {
        // MARK: - Add More Lotto Numbers Button Tap Action
        addMoreLottoNumbersButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.addNewLottoNumberInputView()
            })
            .disposed(by: disposeBag)
        
        addMorePensionNumbersButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.addNewPensionNumberInputView()
            })
            .disposed(by: disposeBag)
        
        // MARK: - Lotto binding logic (merged from LottoNumberEntryView)
        reactor.state
            .map { $0.latestLottoRound }
            .withLatestFrom(reactor.state.map { $0.currentLottoRound }) { (latest, current) in
                (latest: latest, current: current)
            }
            .subscribe(onNext: { [weak self] result in
                guard let self = self,
                      let latestRound = result.latest,
                      let currentRound = result.current else { return }
                
                if latestRound == currentRound {
                    self.nextRoundLottoButton.isEnabled = false
                    self.nextRoundLottoButton.tintColor = .gray40
                } else {
                    self.nextRoundLottoButton.isEnabled = true
                    self.nextRoundLottoButton.tintColor = .gray100
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.latestLottoRound }
            .map { round -> NSAttributedString in
                let text = "\(round ?? 0)회"
                print("DEBUG - round: \(round ?? 0)회")
                return NSAttributedString(
                    string: text,
                    attributes: Typography.headline1.attributes(alignment: .right)
                )
            }
            .bind(to: lottoDrawRound.rx.attributedText)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.latestLotteryResult }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] result in
                let lottoDrwDate = result.the645.drwDate.reformatDate
                
                let lottoAttributedString = NSAttributedString(string: lottoDrwDate, attributes: Typography.label2.attributes(alignment: .left))
                
                self?.lottoDrawDate.attributedText = lottoAttributedString
            })
            .disposed(by: disposeBag)
        
        // MARK: - Pension lottery binding logic
        reactor.state
            .map { $0.latestPensionRound }
            .withLatestFrom(reactor.state.map { $0.currentPensionLotteryRound }) { (latest, current) in
                (latest: latest, current: current)
            }
            .subscribe(onNext: { result in
                guard let latestRound = result.latest,
                      let currentRound = result.current else { return }
                
                if latestRound == currentRound {
                    self.nextRoundPensionLotteryButton.isEnabled = false
                    self.nextRoundPensionLotteryButton.tintColor = .gray40
                } else {
                    self.nextRoundPensionLotteryButton.isEnabled = true
                    self.nextRoundPensionLotteryButton.tintColor = .gray100
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.latestPensionRound }
            .map { round -> NSAttributedString in
                let text = "\(round ?? 0)회"
                return NSAttributedString(
                    string: text,
                    attributes: Typography.headline1.attributes(alignment: .right)
                )
            }
            .bind(to: pensionLotteryDrawRound.rx.attributedText)
            .disposed(by: disposeBag)
        
        // MARK: - Save Button Binding
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleSaveButtonTap(reactor: reactor)
            })
            .disposed(by: disposeBag)
        

    }
    
    private func handleSaveButtonTap(reactor: HomeViewReactor) {
        var entriesToSave: [LotteryEntry] = []
        
        // 로또 번호 저장
        let lottoNumbers = getAllLotteryNumbersAsInt()
        if !lottoNumbers.isEmpty {
            let currentRound = reactor.currentState.currentLottoRound ?? 1
            let drawDate = reactor.currentState.lottoRoundResult?.lottoResult.drwDate ?? 
                          reactor.currentState.latestLotteryResult?.the645.drwDate ?? ""
            
            for numbers in lottoNumbers {
                let entry = LotteryEntry(
                    type: .lotto,
                    round: currentRound,
                    drawDate: drawDate,
                    numbers: numbers
                )
                entriesToSave.append(entry)
            }
        }
        
        // 연금복권 번호 저장
        let pensionNumbers = getAllPensionLotteryNumbers()
        if !pensionNumbers.isEmpty {
            let currentRound = reactor.currentState.currentPensionLotteryRound ?? 1
            let drawDate = reactor.currentState.pensionRoundResult?.pensionLotteryResult.drwDate ?? 
                          reactor.currentState.latestLotteryResult?.the720.drwDate ?? ""
            
            for numbers in pensionNumbers {
                // 연금복권은 문자열 배열을 정수 배열로 변환
                let validNumbers = numbers.compactMap { Int($0) }.filter { $0 > 0 }
                if validNumbers.count == 6 {  // 유효한 6자리 번호만 저장
                    let entry = LotteryEntry(
                        type: .pension,
                        round: currentRound,
                        drawDate: drawDate,
                        numbers: validNumbers
                    )
                    entriesToSave.append(entry)
                }
            }
        }
        
        // 로컬 저장 실행
        if !entriesToSave.isEmpty {
            do {
                try LotteryStorageManager.shared.addEntries(entriesToSave)
                ToastView.show(message: "내 로또 번호를 저장했어요", horizontalPadding: 164)
                
                // 저장 성공 후 약간의 딜레이를 준 후 화면 dismiss
                // MyNumbersView의 업데이트가 완료될 시간을 확보
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.dismissViewController()
                }
            } catch {
                ToastView.show(message: "문제가 생겼어요\r다시 한 번 더 시도해주세요", horizontalPadding: 172, height: 68)
            }
        }
    }
    
    /// parent view controller인 NumberEntryViewController를 dismiss 하는 함수
    private func dismissViewController() {
        guard let parentViewController = self.findViewController() else { return }
        parentViewController.navigationController?.popViewController(animated: true)
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

#Preview {
    let view = NumberEntryView()
    return view
}
