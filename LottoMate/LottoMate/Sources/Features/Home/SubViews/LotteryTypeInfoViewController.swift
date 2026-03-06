//
//  LotteryTypeInfoViewController.swift
//  LottoMate
//
//  Created by Mirae on 11/14/24.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxRelay

class LotteryTypeInfoViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private let lotteryTypeInfoView: LotteryTypeInfoView = {
        let view = LotteryTypeInfoView()
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func loadView() {
        view = lotteryTypeInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        lotteryTypeInfoView.confirmButtonTapped
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}
