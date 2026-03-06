//
//  WinnerGuideVC.swift
//  LottoMate
//
//  Created by Mirae on 3/26/25.
//

import UIKit

class WinnerGuideVC: BaseViewController {
    
    private let winnerGuideView: WinnerGuideView = {
        let view = WinnerGuideView()
        return view
    }()
    
    override func loadView() {
        view = winnerGuideView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let config = NavBarConfiguration(
            style: .backButtonWithTitle,
            title: "당첨자 가이드",
            buttonTintColor: .gray100
        )
        configureNavBar(config)
    }
}

#Preview {
    let view = WinnerGuideVC()
    return view
}
