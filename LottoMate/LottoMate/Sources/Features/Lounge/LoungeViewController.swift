//
//  LoungeViewController.swift
//  LottoMate
//
//  Created by Mirae on 11/18/24.
//

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift

class LoungeViewController: BaseViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private let loungeView: LoungeView = {
        let view = LoungeView()
        return view
    }()
    
    override func loadView() {
        view = loungeView
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configNaviBar()
        
        view.addSubview(rootFlexContainer)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        rootFlexContainer.pin.top(view.safeAreaInsets.top).horizontally()
//        rootFlexContainer.flex.layout(mode: .adjustHeight)
//    }
    
    private func configNaviBar() {
        let config = NavBarConfiguration(
            style: .titleAndSetting,
            title: "라운지",
            rightButtonImage: UIImage(named: "icon_setting"),
            buttonTintColor: .gray100)
        configureNavBar(config)
    }
}

#Preview {
    let view = LoungeView()
    return view
}
