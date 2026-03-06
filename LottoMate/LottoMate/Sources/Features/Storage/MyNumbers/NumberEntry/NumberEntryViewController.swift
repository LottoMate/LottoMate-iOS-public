//
//  NumberEntryViewController.swift
//  LottoMate
//
//  Created by Mirae on 1/15/25.
//  로또 번호 등록

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift

class NumberEntryViewController: BaseViewController {
    private let reactor = HomeViewReactor()
    private let disposeBag = DisposeBag()
    
    private let numberEntryView: NumberEntryView = {
        let view = NumberEntryView()
        view.backgroundColor = .white
        return view
    }()
    
    override func loadView() {
        view = numberEntryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberEntryView.reactor = reactor
        reactor.action.onNext(.fetchInitialData)
        
        changeStatusBarBgColor(bgColor: .commonNavBar)
        
        let config = NavBarConfiguration(
            style: .backButtonWithTitle,
            title: "번호 등록",
            buttonTintColor: .gray100
        )
        
        configureNavBar(config)
        
        view.addSubview(rootFlexContainer)
    }
    
    @objc override func leftButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
