import UIKit
import PinLayout
import FlexLayout

protocol MyAccountViewDelegate: AnyObject {
    func didTapWithdrawal()
    func didTapLogout()
}

class MyAccountView: UIView {
    weak var delegate: MyAccountViewDelegate?
    
    fileprivate let rootFlexContainer = UIView()
    private let optionsContainer = UIView()
    
    private let topMargin: CGFloat = {
        let topMargin = DeviceMetrics.statusWithNavigationBarHeight
        return topMargin
    }()
    
    private let accountOptions = [
        "로그아웃",
        "회원 탈퇴"
    ]
    
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
            .marginTop(topMargin + 12)
            .define { flex in
                accountOptions.enumerated().forEach { index, option in
                    let containerView = UIView()
                    containerView.tag = index
                    
                    let optionLabel = UILabel()
                    optionLabel.text = option
                    styleLabel(for: optionLabel, fontStyle: .body1, textColor: .black, alignment: .left)
                    
                    containerView.flex.addItem(optionLabel)
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOptionTap(_:)))
                    containerView.addGestureRecognizer(tapGesture)
                    containerView.isUserInteractionEnabled = true
                    
                    flex.addItem(containerView)
                        .paddingLeft(20)
                        .paddingVertical(18)
                        .width(100%)
                }
            }
    }
    
    @objc private func handleOptionTap(_ gesture: UITapGestureRecognizer) {
        guard let containerView = gesture.view else { return }
        let index = containerView.tag
        
        switch index {
        case 0: // 로그아웃
            delegate?.didTapLogout()
        case 1: // 회원 탈퇴
            delegate?.didTapWithdrawal()
        default:
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout()
    }
}

#Preview {
    let view = MyAccountView()
    return view
}
