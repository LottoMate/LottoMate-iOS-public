//
//  NumberInputView.swift
//  LottoMate
//
//  Created by Mirae on 1/31/25.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import ReactorKit

final class PensionNumberInputView: UIView, View {
    var disposeBag = DisposeBag()
    private let rootFlexContainer = UIView()
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "숫자 6자리를 입력하세요"
        styleLabel(for: label, fontStyle: .body1, textColor: .gray60, alignment: .left)
        return label
    }()
    private var textFieldsContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        // hidden 상태에서는 입력되지 않도록 함
        view.isUserInteractionEnabled = !view.isHidden
        return view
    }()
    private var textFields: [UITextField] = []
    private let separators: [UILabel] = (0..<5).map { _ in
        let label = UILabel()
        label.text = "-"
        styleLabel(for: label, fontStyle: .body1, textColor: .black)
        return label
    }
    private let clearButton = UIButton()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray60
        return view
    }()
    
    private var enteredNumbers: Set<String> = []
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "숫자를 다시 확인해주세요"
        styleLabel(for: label, fontStyle: .label2, textColor: .red40, alignment: .left)
        label.isHidden = true
        return label
    }()
    
    var addMoreLottoNumbersButton: UIView = {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        configureTextFields()
        setupTapGesture()
        setupClearButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        configureTextFields()
        setupTapGesture()
        setupClearButton()
    }
    
    private func setupLayout() {
        addSubview(rootFlexContainer)
        
        rootFlexContainer.flex.define { flex in
            flex.addItem().direction(.row)
                .justifyContent(.spaceBetween)
                .alignItems(.center)
                .define { flex in
                    flex.addItem().grow(1).define { flex in
                        flex.addItem().direction(.column).gap(8).define { flex in
                            flex.addItem(textFieldsContainer)
                                .direction(.row)
                                .alignItems(.center)
                                .gap(12)
                                .define { flex in
                                    for i in 0..<6 {
                                        let textField = createTextField()
                                        textField.isHidden = i != 0  // 첫 번째 필드만 보이도록 설정
                                        textFields.append(textField)
                                        flex.addItem(textField).height(24).width(12) // Adjusted for single digit
                                        
                                        if i < 5 {
                                            let separator = separators[i]
                                            separator.isHidden = true  // 첫 번째 구분자만 보이도록 설정
                                            flex.addItem(separator).height(24)
                                        }
                                    }
                                }
                            flex.addItem(underlineView).height(1)
                        }
                        flex.addItem(placeholderLabel).height(24).marginBottom(8).position(.absolute).all(0)
                    }
                    flex.addItem(clearButton).size(20).marginLeft(27)
                }
            flex.addItem(errorLabel).position(.absolute)
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top(pin.safeArea.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        placeholderLabel.pin.left()
        // errorLabel 위치 조정
        if !errorLabel.isHidden {
            errorLabel.pin.below(of: underlineView, aligned: .left).marginTop(12)
            errorLabel.isHidden = false
        }
        rootFlexContainer.flex.addItem(addMoreLottoNumbersButton).alignSelf(.center)
        addMoreLottoNumbersButton.pin.below(of: visible([underlineView, errorLabel])).horizontally().marginTop(24)
    }
    
    private func validateAllInputs() -> Bool {
        let allNumbers = textFields.compactMap { $0.text }.filter { !$0.isEmpty }
        return allNumbers.count == 6 && allNumbers.allSatisfy { $0.count == 1 && Int($0) != nil }
    }
    
    private func createTextField() -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.delegate = self
        return textField
    }
    
    private func configureTextFields() {
        for (index, textField) in textFields.enumerated() {
            textField.rx.text.orEmpty
                .subscribe(onNext: { [weak self] text in
                    guard let self = self else { return }
                    
                    if text.count == 1 {
                        let hasError = index == 5 && !self.validateAllInputs()
                        self.updateErrorState(hasError: hasError)
                        
                        if index < 5 && !hasError {
                             self.textFields[index + 1].becomeFirstResponder()
                        }
                    }
                })
                .disposed(by: disposeBag)
        }
        
        let allTextFieldsObservable = Observable
            .combineLatest(textFields.map { $0.rx.text.orEmpty })
            .map { texts in texts.contains { !$0.isEmpty } }
        
        allTextFieldsObservable
            .subscribe(onNext: { [weak self] hasText in
                let imageName = hasText ? "btn_xbox_active" : "btn_xbox_inactive"
                self?.clearButton.setImage(UIImage(named: imageName), for: .normal)
                self?.clearButton.isEnabled = hasText
            })
            .disposed(by: disposeBag)
    }
    
    private func updateErrorState(hasError: Bool) {
        errorLabel.isHidden = !hasError
        underlineView.backgroundColor = hasError ? .red : .gray60
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func bind(reactor: NumberEntryReactor) {
        // Implement ReactorKit binding
    }
    
    // Public method to get current lottery numbers
    func getNumbers() -> [String] {
        return textFields.map { $0.text ?? "" }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        placeholderLabel.isHidden = true
        textFieldsContainer.isHidden = false
        textFieldsContainer.isUserInteractionEnabled = true
        textFields.first?.becomeFirstResponder()
        rootFlexContainer.flex.layout()
    }
    
    private func setupClearButton() {
        clearButton.setImage(UIImage(named: "btn_xbox_inactive"), for: .normal)
        clearButton.isEnabled = false
        clearButton.addTarget(self, action: #selector(clearFields), for: .touchUpInside)
    }
    
    @objc private func clearFields() {
        textFieldsContainer.isHidden = true
        textFieldsContainer.isUserInteractionEnabled = !textFieldsContainer.isHidden
        placeholderLabel.isHidden = false
        errorLabel.isHidden = true
        underlineView.backgroundColor = .gray60
        enteredNumbers.removeAll()
        
        textFields.forEach { $0.text = "" }
        
        setNeedsLayout()
        layoutIfNeeded()
        
        textFields.first?.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension PensionNumberInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.allSatisfy({ $0.isNumber }) else {
            return false
        }
        
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return newText.count <= 1
    }
}



