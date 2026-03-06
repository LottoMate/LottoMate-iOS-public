//
//  WinningInfoDetailViewController.swift
//  LottoMate
//
//  Created by Mirae on 7/30/24.
//  당첨 정보 상세

import UIKit
import ReactorKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa
import RxRelay
import BottomSheet

class WinningInfoDetailViewController: BaseViewController, View {
    
    fileprivate var mainView: WinningInfoDetailView {
        return self.view as! WinningInfoDetailView
    }
    
    private let viewModel = LottoMateViewModel.shared
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    var disposeBag = DisposeBag()
    
    let reactor = SpeetoWinningInfoReactor()
    
    lazy var winningInfoDetailView: WinningInfoDetailView = {
        let view = WinningInfoDetailView()
        view.bind(reactor: reactor)
        return view
    }()
    
    let speetoPageSelectorVC = SpeetoPageSelectorVC()
    
    override func loadView() {
        view = winningInfoDetailView
        mainView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 뷰를 나타낼때마다 색이 적용되어 opacity가 변경됨... 점점 불투명해짐.
        changeStatusBarBgColor(bgColor: .commonNavBar)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(reactor: reactor)
        setupBindings()
        
        // !NO_SERVER
        viewModel.fetchLottoHome()
        viewModel.lottoDrawRoundPickerViewData()
        viewModel.pensionLotteryDrawRoundPickerViewData()
        
        let config = NavBarConfiguration(
            style: .backButtonWithTitle,
            title: "당첨 정보 상세",
            buttonTintColor: .gray100
        )
        configureNavBar(config)
    }
    
    @objc override func leftButtonTapped() {
        navigationController?.popViewController(animated: true)
        didTapBackButton()
    }
    
    func setupBindings() {
        viewModel.drawRoundTapEvent
            .subscribe(onNext: { isTapped in
                guard let tapped = isTapped else { return }
                if tapped {
                    self.showDrawRoundTest()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.speetoPageTapEvent
            .subscribe(onNext: { isTapped in
                guard let tapped = isTapped else { return }
                if tapped {
                    self.showSpeetoPageSelector()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.latestLotteryResult
            .subscribe(onNext: { result in
                if let latestLottoDrawNumber = result?.the645.drwNum {
                    self.viewModel.fetchLottoResult(round: latestLottoDrawNumber)
                }
                if let latestPensionLotteryResult = result?.the720.drwNum {
                    self.viewModel.fetchPensionLotteryResult(round: latestPensionLotteryResult)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func showDrawRoundTest() {
        let viewController = DrawPickerViewController()
        viewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 1.25)
        
        presentBottomSheet(viewController: viewController, configuration: BottomSheetConfiguration(
            cornerRadius: 32,
            pullBarConfiguration: .hidden,
            shadowConfiguration: .default
        ), canBeDismissed: {
            true
        }, dismissCompletion: {
            // handle bottom sheet dismissal completion
        })
    }
    
    func showSpeetoPageSelector() {
//        let vc = SpeetoPageSelectorVC()
        speetoPageSelectorVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 1.25)
        
        presentBottomSheet(viewController: speetoPageSelectorVC,
                           configuration: BottomSheetConfiguration(
                            cornerRadius: 0,
                            pullBarConfiguration: .hidden,
                            shadowConfiguration: .default))
    }
    
    // 전체 타입에 대한 리액터로 수정 필요
    func bind(reactor: SpeetoWinningInfoReactor) {
        speetoPageSelectorVC.bind(reactor: reactor)
    }
}

extension WinningInfoDetailViewController: WinningInfoDetailViewDelegate {
    func didTapBackButton() {
        navigationController?.popViewController(animated: true)
        // 뒤로간 후 다시 돌아올 때 회차 선택 피커뷰 나타남을 방지
        self.viewModel.drawRoundTapEvent.accept(false)
    }
}
