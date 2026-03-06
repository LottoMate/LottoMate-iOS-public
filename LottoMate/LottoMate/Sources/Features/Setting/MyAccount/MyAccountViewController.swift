import UIKit

protocol MyAccountViewControllerDelegate: AnyObject {
    func didRequestLogout()
}

class MyAccountViewController: BaseViewController {
    private let myAccountView = MyAccountView()
    weak var delegate: MyAccountViewControllerDelegate?
    
    override func loadView() {
        view = myAccountView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        myAccountView.delegate = self
    }
    
    private func setupNavBar() {
        let config = NavBarConfiguration(
            style: .backButtonWithTitle,
            title: "내 계정 관리",
            buttonTintColor: .gray100
        )
        configureNavBar(config)
    }
}

extension MyAccountViewController: MyAccountViewDelegate {
    func didTapLogout() {
        // 로그아웃 요청 처리
        delegate?.didRequestLogout()
        
        // 로그아웃 후 설정 화면으로 돌아가기
        navigationController?.popViewController(animated: true)
    }
    
    func didTapWithdrawal() {
        let withdrawalVC = WithdrawalViewController()
        navigationController?.pushViewController(withdrawalVC, animated: true)
    }
}

#Preview {
    MyAccountViewController()
}
