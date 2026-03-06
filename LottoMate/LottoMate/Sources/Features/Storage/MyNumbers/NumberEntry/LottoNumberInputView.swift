//
//  LottoNumberInputView.swift
//  LottoMate
//
//  Created by Mirae on 1/15/25.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift
import RxCocoa

class BackspaceTextField: UITextField {
    var onDeleteBackward: (() -> Void)?

    override func deleteBackward() {
        let wasEmpty = text?.isEmpty ?? true
        super.deleteBackward()
        if wasEmpty {
            onDeleteBackward?()
        }
    }
}

class LottoNumberInputView: UIView {
    var disposeBag = DisposeBag()
    var onLayoutUpdate: (() -> Void)?
    var onRemove: (() -> Void)?
    private var isErrorDisplayed = false
    
    var anyTextFieldHasText: Observable<Bool> {
        return _anyTextFieldHasText.asObservable()
    }
    private let _anyTextFieldHasText = PublishSubject<Bool>()

    // MARK: - UI Components
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "숫자 6자리를 입력하세요"
        styleLabel(for: label, fontStyle: .body1, textColor: .gray60, alignment: .left)
        return label
    }()

    private let textFieldsContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        view.isUserInteractionEnabled = true
        return view
    }()

    private let textFields: [BackspaceTextField]
    private let separators: [UILabel]

    private let clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_xbox_inactive"), for: .normal)
        button.isEnabled = false
        return button
    }()

    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray60
        return view
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "숫자를 다시 확인해주세요"
        styleLabel(for: label, fontStyle: .label2, textColor: .red40, alignment: .left)
        return label
    }()

    // MARK: - Initializer
    init() {
        self.textFields = (0..<6).map { index in
            let textField = BackspaceTextField()
            textField.borderStyle = .none
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.isHidden = index != 0
            return textField
        }

        self.separators = (0..<5).map { _ in
            let label = UILabel()
            label.text = "-"
            styleLabel(for: label, fontStyle: .body1, textColor: .black)
            label.isHidden = true
            return label
        }

        super.init(frame: .zero)
        
        textFields.forEach { $0.delegate = self }

        setupLayout()
        setupBindings()
        
        errorLabel.flex.display(.none)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func getNumbers() -> [String] {
        return textFields.map { $0.text ?? "" }
    }
    
    // MARK: - Layout
    private func setupLayout() {
        flex.define { flex in
            flex.addItem()
                .direction(.row)
                .justifyContent(.spaceBetween)
                .alignItems(.center)
                .define { flex in
                    flex.addItem()
                        .grow(1)
                        .define { flex in
                            flex.addItem()
                                .direction(.column)
                                .gap(8)
                                .define { flex in
                                    flex.addItem(textFieldsContainer)
                                        .direction(.row)
                                        .alignItems(.center)
                                        .gap(12)
                                        .define { flex in
                                            for i in 0..<6 {
                                                flex.addItem(textFields[i]).height(24).grow(1)
                                                if i < 5 {
                                                    flex.addItem(separators[i]).height(24)
                                                }
                                            }
                                        }
                                    flex.addItem(underlineView).height(1)
                                }
                            flex.addItem(placeholderLabel)
                                .height(24)
//                                .marginBottom(8)
                                .position(.absolute)
                        }
                    flex.addItem(clearButton).size(20).marginLeft(27)
                }
            flex.addItem(errorLabel)
                .marginTop(12)
        }
    }

    // MARK: - Bindings & Actions
    private func setupBindings() {
        self.rx.tapGesture()
            .when(.recognized)
            .filter { [weak self] _ in self?.textFieldsContainer.isHidden ?? false }
            .subscribe(onNext: { [weak self] _ in
                self?.activateEditing()
            })
            .disposed(by: disposeBag)
            
        clearButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.onRemove?()
            })
            .disposed(by: disposeBag)

        for (index, textField) in textFields.enumerated() {
            textField.rx.text.orEmpty
                .subscribe(onNext: { [weak self] text in
                    guard let self = self else { return }

                    if text.count == 2 {
                        let isLastField = index == 5
                        let hasError = isLastField && !self.validateAllInputs()
                        
                        self.updateErrorState(hasError: hasError)

                        if !isLastField && !hasError && (index + 1 < self.textFields.count && self.textFields[index + 1].isHidden) {
                            self.showNextTextField(from: index)
                        }
                    }
                })
                .disposed(by: disposeBag)

            textField.onDeleteBackward = { [weak self] in
                guard let self = self else { return }
                if index > 0 {
                    self.textFields[index - 1].becomeFirstResponder()
                }
            }
        }
        
        let allTextFieldsObservable = Observable
            .combineLatest(textFields.map { $0.rx.text.orEmpty })
            .map { texts in texts.contains { !$0.isEmpty } }
        
        allTextFieldsObservable
            .bind(to: _anyTextFieldHasText)
            .disposed(by: disposeBag)
        
        allTextFieldsObservable
            .subscribe(onNext: { [weak self] hasText in
                let imageName = hasText ? "btn_xbox_active" : "btn_xbox_inactive"
                self?.clearButton.setImage(UIImage(named: imageName), for: .normal)
                self?.clearButton.isEnabled = hasText
            })
            .disposed(by: disposeBag)
    }

    private func activateEditing() {
        placeholderLabel.isHidden = true
        textFieldsContainer.isHidden = false
        textFieldsContainer.isUserInteractionEnabled = true
        
        flex.layout()
        
        textFields.first?.becomeFirstResponder()
    }
    
    func resetInput() {
        textFieldsContainer.isHidden = true
        textFieldsContainer.isUserInteractionEnabled = !textFieldsContainer.isHidden
        placeholderLabel.isHidden = false
        updateErrorState(hasError: false)
        underlineView.backgroundColor = .gray60
        
        textFields.enumerated().forEach { index, field in
            field.text = ""
            field.isHidden = index != 0
            if index < 5 {
                separators[index].isHidden = true
            }
        }
        
        self.flex.layout()
        onLayoutUpdate?()
    }
    
    private func showNextTextField(from currentIndex: Int) {
        guard currentIndex < 5 else { return }
        
        textFields[currentIndex + 1].isHidden = false
        separators[currentIndex].isHidden = false
        
        textFieldsContainer.flex.layout()
        
        DispatchQueue.main.async {
            self.textFields[currentIndex + 1].becomeFirstResponder()
        }
    }

    private func validateAllInputs() -> Bool {
        let allNumbers = textFields.compactMap { $0.text }.filter { !$0.isEmpty }
        guard allNumbers.count == 6,
              allNumbers.allSatisfy({ $0.count == 2 }) else { return false }
        
        let validRange = allNumbers.allSatisfy {
            guard let number = Int($0) else { return false }
            return number >= 1 && number <= 45
        }
        
        let uniqueNumbers = Set(allNumbers)
        return validRange && uniqueNumbers.count == 6
    }
    
    private func updateErrorState(hasError: Bool) {
        guard isErrorDisplayed != hasError else { return }
        isErrorDisplayed = hasError
        
        let displayMode: Flex.Display = hasError ? .flex : .none
        errorLabel.flex.display(displayMode)
        underlineView.backgroundColor = hasError ? .red40 : .gray60
        self.flex.layout()
        onLayoutUpdate?()
    }
}

// MARK: - UITextFieldDelegate
extension LottoNumberInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.isEmpty || string.allSatisfy({ $0.isNumber }) else {
            return false
        }
        
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return newText.count <= 2
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.selectAll(nil)
        }
    }
} 
