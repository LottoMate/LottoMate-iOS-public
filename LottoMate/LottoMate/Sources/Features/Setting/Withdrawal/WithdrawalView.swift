import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxGesture

protocol WithdrawalViewDelegate: AnyObject {
    func didTapWithdrawalButton()
    func updateButtonState(isEnabled: Bool)
}

class WithdrawalView: UIView {
    weak var delegate: WithdrawalViewDelegate?
    private let disposeBag = DisposeBag()
    
    private var selectedReasons: Set<Int> = []
    private var isTextOverLimit: Bool = false
    private let placeholderText = "텍스트를 입력하세요."
    
    private let scrollView = UIScrollView()
    private let rootFlexContainer = UIView()
    
    private var keyboardHeight: CGFloat = 0
    
    private let topMargin: CGFloat = {
        let topMargin = DeviceMetrics.navigationBarHeight
        return topMargin
    }()
    
    private let image = CommonImageView(imageName: "pochi_deleteAccount")
    
    private let askReasonsLabel: UILabel = {
        let label = UILabel()
        label.text = "탈퇴 이유를 알려주세요"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black, alignment: .left)
        return label
    }()
    
    private let asteriskLabel: UILabel = {
        let label = UILabel()
        label.text = "*"
        styleLabel(for: label, fontStyle: .headline1, textColor: .red50Default)
        return label
    }()
    
    private let reasonOptions = [
        "자주 사용하지 않아요",
        "로또 명당을 찾기가 어려워요",
        "오류가 많아서 사용하기 불편해요",
        "로또 당첨이 돼서 더 이상 필요하지 않아요"
    ]
    
    // Containers for each reason option
    private var reasonContainers: [UIView] = []
    private var reasonLabels: [UILabel] = []
    private var checkIcons: [UIImageView] = []
    
    private let goodByeLabel: UILabel = {
        let label = UILabel()
        label.text = "마지막 인사"
        styleLabel(for: label, fontStyle: .headline1, textColor: .black, alignment: .left)
        return label
    }()
    
    // Text input box for goodbye message
    private let goodByeTextView: UITextView = {
        let textView = UITextView()
        textView.font = Typography.body1.font()
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 12)
        return textView
    }()
    
    // Placeholder label for the text view
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = placeholderText
        styleLabel(for: label, fontStyle: .body1, textColor: .gray60, alignment: .left)
        return label
    }()
    
    // Character count label
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/200"
        styleLabel(for: label, fontStyle: .label1, textColor: .gray100)
        label.textAlignment = .right
        return label
    }()
    
    // Container for text view and character count
    private let textInputContainer: UIView = {
        let container = UIView()
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.gray60.cgColor
        container.layer.cornerRadius = 8
        return container
    }()
    
    init() {
        super.init(frame: .zero)
        setupReasonOptions()
        setupLayout()
        setupBindings()
        setupTextViewBindings()
        setupKeyboardObservers()
        
        // Add tap gesture to dismiss keyboard when tapping outside the text view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = keyboardFrame.height
            
            // Calculate the text input container's position relative to the window
            if let textInputFrame = textInputContainer.superview?.convert(textInputContainer.frame, to: nil) {
                let textInputBottom = textInputFrame.origin.y + textInputFrame.size.height
                let visibleAreaBottom = UIScreen.main.bounds.height - keyboardHeight
                
                // If the text input container is covered by the keyboard, scroll to make it visible
                if textInputBottom > visibleAreaBottom {
                    let offset = textInputBottom - visibleAreaBottom + 20 // Add some padding
                    scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
        scrollView.setContentOffset(CGPoint(x: 0, y: -topMargin), animated: true)
    }
    
    private func setupReasonOptions() {
        // Create UI components for each reason option
        for (_, reasonText) in reasonOptions.enumerated() {
            let container = UIView()
            
            let label = UILabel()
            label.text = reasonText
            styleLabel(for: label, fontStyle: .body1, textColor: .black, alignment: .left)
            
            let checkIcon = UIImageView()
            if let checkIconImage = UIImage(named: "icon_checkbox_inactive") {
                checkIcon.image = checkIconImage
                checkIcon.contentMode = .scaleAspectFit
            }
            
            reasonContainers.append(container)
            reasonLabels.append(label)
            checkIcons.append(checkIcon)
        }
    }
    
    private func setupBindings() {
        // Add tap gesture to each reason container
        for (index, container) in reasonContainers.enumerated() {
            container.rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    
                    // Toggle selection
                    if self.selectedReasons.contains(index) {
                        self.selectedReasons.remove(index)
                        self.checkIcons[index].image = UIImage(named: "icon_checkbox_inactive")
                    } else {
                        self.selectedReasons.insert(index)
                        self.checkIcons[index].image = UIImage(named: "icon_checkbox_active")
                    }
                    
                    // Update confirm button state
                    // Only enable if reasons are selected AND text is not over limit
                    let shouldEnableButton = !self.selectedReasons.isEmpty && !self.isTextOverLimit
                    self.delegate?.updateButtonState(isEnabled: shouldEnableButton)
                })
                .disposed(by: disposeBag)
        }
        
        // Add tap action for confirm button
//        confirmButton.rx.tap
//            .subscribe(onNext: { [weak self] in
//                guard let self = self else { return }
//                self.delegate?.didTapWithdrawalButton()
//            })
//            .disposed(by: disposeBag)
        
        // Add tap action for cancel button
//        cancelButton.rx.tap
//            .subscribe(onNext: { [weak self] in
//                guard let self = self else { return }
//                // Notify delegate or handle cancel action
//                // For now, we'll just print a message
//                print("Cancel button tapped")
//            })
//            .disposed(by: disposeBag)
    }
    
    private func setupTextViewBindings() {
        goodByeTextView.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                // Check if text is at limit (exactly 200 characters)
                let isAtLimit = text.count == 200
                
                // Check if text exceeds limit (more than 200 characters)
                let isOverLimit = text.count > 200
                
                // Update UI based on text limit status
                if isOverLimit {
                    // If trying to exceed 200 characters, truncate to 200
                    self.goodByeTextView.text = String(text.prefix(200))
                    // Set count to 200/200
                    self.characterCountLabel.text = "200/200"
                    // Change color to indicate max limit reached
                    self.textInputContainer.layer.borderColor = UIColor.red40.cgColor
                    self.characterCountLabel.textColor = .red40
                } else if isAtLimit {
                    // Exactly at 200 characters - change colors to indicate max limit
                    self.textInputContainer.layer.borderColor = UIColor.red40.cgColor
                    self.characterCountLabel.textColor = .red40
                    self.characterCountLabel.text = "200/200"
                } else {
                    // Text is within limit and not at max
                    self.textInputContainer.layer.borderColor = UIColor.gray60.cgColor
                    self.characterCountLabel.textColor = .gray100
                    self.characterCountLabel.text = "\(text.count)/200"
                }
                
                // Update button state based on text count and selected reasons
                let shouldEnableButton = !isOverLimit && !self.selectedReasons.isEmpty
                self.delegate?.updateButtonState(isEnabled: shouldEnableButton)
                
                // Show/hide placeholder based on text
                self.placeholderLabel.isHidden = !text.isEmpty
            })
            .disposed(by: disposeBag)
        
        // Set up delegate for text view to handle begin/end editing
        goodByeTextView.delegate = self
    }
    
    private func setupLayout() {
        backgroundColor = .white
        
        // Add scrollView to the main view
        addSubview(scrollView)
        scrollView.addSubview(rootFlexContainer)
        
        rootFlexContainer.flex
            .direction(.column)
            .paddingHorizontal(20)
            .marginTop(topMargin)
            .paddingBottom(124) // 버튼 height만큼 컨텐츠 높이 추가
            .define { flex in
                flex.addItem(image)
                    .alignSelf(.center)
                    .width(UIScreen.main.bounds.width - 40)
                    .height((UIScreen.main.bounds.width - 40) / 2.09)
                
                flex.addItem().direction(.row)
                    .marginTop(20)
                    .gap(4)
                    .define { flex in
                        flex.addItem(askReasonsLabel)
                        flex.addItem(asteriskLabel)
                    }
                
                flex.addItem()
                    .direction(.column)
                    .gap(16)
                    .marginTop(20)
                    .marginBottom(32)
                    .define { flex in
                        for (index, container) in reasonContainers.enumerated() {
                            flex.addItem(container)
                                .direction(.row)
                                .alignItems(.center)
                                .gap(12)
                                .define { flex in
                                    flex.addItem(checkIcons[index])
                                        .size(20)
                                    flex.addItem(reasonLabels[index])
                                        .grow(1)
                                }
                        }
                    }
                
                flex.addItem(goodByeLabel)
                    .marginBottom(12)
                
                flex.addItem(textInputContainer)
                    .width(UIScreen.main.bounds.width - 40)
                    .marginBottom(20)
                    .define { flex in
                        flex.addItem()
                            .width(100%)
                            .height(94)
                            .define { flex in
                                flex.addItem(goodByeTextView)
                                    .width(100%)
                                    .height(100%)
                                
                                // Add placeholder label as absolute position inside text view
                                flex.addItem(placeholderLabel)
                                    .position(.absolute)
                                    .left(16)
                                    .top(12)
                            }
                        
                        flex.addItem(characterCountLabel)
                            .marginBottom(12)
                            .marginRight(16)
                    }
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.pin.all()
        
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        scrollView.contentSize = CGSize(
            width: rootFlexContainer.frame.width,
            height: rootFlexContainer.frame.height + keyboardHeight
        )
    }
}

// MARK: - UITextViewDelegate
extension WithdrawalView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Hide placeholder when editing begins
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Show placeholder if text is empty when editing ends
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

#Preview {
    let view = WithdrawalView()
    return view
}
