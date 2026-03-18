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
    let initialState: WinningInfoDetailState
    
    fileprivate var mainView: WinningInfoDetailView {
        return self.view as! WinningInfoDetailView
    }
    
    private let viewModel = LottoMateViewModel.shared
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    var disposeBag = DisposeBag()
    
    let reactor = SpeetoWinningInfoReactor()
    
    lazy var winningInfoDetailView: WinningInfoDetailView = {
        let view = WinningInfoDetailView(initialLotteryType: initialState.selectedLotteryType)
        view.bind(reactor: reactor)
        return view
    }()
    
    let speetoPageSelectorVC = SpeetoPageSelectorVC()

    init(initialState: WinningInfoDetailState) {
        self.initialState = initialState
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(
            initialState: WinningInfoDetailState(
                selectedLotteryType: .lotto
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        applyInitialState()
        setupBindings()
        
        if viewModel.latestLotteryResult.value == nil {
            viewModel.fetchLottoHome()
        } else {
            viewModel.lottoDrawRoundPickerViewData()
            viewModel.pensionLotteryDrawRoundPickerViewData()
        }
        
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
        mainView.selectedLotteryType
            .distinctUntilChanged()
            .bind(to: viewModel.selectedLotteryType)
            .disposed(by: disposeBag)

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
                guard result != nil else { return }

                self.viewModel.lottoDrawRoundPickerViewData()
                self.viewModel.pensionLotteryDrawRoundPickerViewData()

                if let latestLottoDrawNumber = result?.the645.drwNum {
                    let shouldFetchLottoResult = self.viewModel.lottoResult.value == nil
                    if shouldFetchLottoResult {
                        self.viewModel.fetchLottoResult(round: latestLottoDrawNumber)
                    }
                }
                if let latestPensionLotteryResult = result?.the720.drwNum {
                    let shouldFetchPensionResult = self.viewModel.pensionLotteryResult.value == nil
                    if shouldFetchPensionResult {
                        self.viewModel.fetchPensionLotteryResult(round: latestPensionLotteryResult)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func applyInitialState() {
        viewModel.selectedLotteryType.onNext(initialState.selectedLotteryType)
        viewModel.latestLotteryResult.accept(initialState.latestLotteryResult)
        viewModel.lottoResult.accept(initialState.lottoRoundResult)
        viewModel.pensionLotteryResult.accept(initialState.pensionRoundResult)
        viewModel.currentLottoRound.accept(initialState.currentLottoRound)
        viewModel.currentPensionLotteryRound.accept(initialState.currentPensionLotteryRound)
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
