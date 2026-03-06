//
//  SavedNumbersViewController.swift
//  LottoMate
//
//  Created by Mirae on 10/31/24.
//

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift

class SavedNumbersViewController: BaseViewController, View {
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    private let savedNumberView: SavedNumbersView = {
        let view = SavedNumbersView()
        return view
    }()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = savedNumberView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = NavBarConfiguration(
            style: .closeButtonOnly,
            rightButtonImage: UIImage(named: "icon_X"),
            buttonTintColor: .gray120
        )
        configureNavBar(config)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changeStatusBarBgColor(bgColor: .commonNavBar)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var statusBarHeight: CGFloat = 0.0
        
        if let windowScene = view.window?.windowScene {
            statusBarHeight = windowScene.statusBarManager?.statusBarFrame.height ?? 0
        }
        rootFlexContainer.pin.top(statusBarHeight).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    func bind(reactor: StorageViewReactor) {
        savedNumberView.reactor = reactor
    }
    
    @objc override func rightButtonTapped() {
        reactor?.action.onNext(.hideSavedNumbersView)
        
        guard let window = WindowManager.findKeyWindow() else { return }
        
        let savedNumbersViewController = window.rootViewController?.children.first(where: { $0 is SavedNumbersViewController })
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
            savedNumbersViewController?.view.transform = CGAffineTransform(translationX: 0, y: window.bounds.height)
        }) { _ in
            // 뷰 컨트롤러 제거
            savedNumbersViewController?.willMove(toParent: nil)
            savedNumbersViewController?.view.removeFromSuperview()
            savedNumbersViewController?.removeFromParent()
        }
    }
}

#Preview {
    SavedNumbersViewController()
}
