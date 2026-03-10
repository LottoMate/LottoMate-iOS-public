//
//  StorageViewController.swift
//  LottoMate
//
//  Created by Mirae on 10/24/24.
//

import UIKit
import FlexLayout
import PinLayout

class ViewControllerTemplate: UIViewController {
    // MARK: - Properties
    fileprivate let rootFlexContainer = UIView()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(rootFlexContainer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.top(view.safeAreaInsets.top).horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
}
