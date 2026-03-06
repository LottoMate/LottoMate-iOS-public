//
//  LoginViewController.swift
//  LottoMate
//
//  Created by Mirae on 10/3/24.
//

import UIKit
import GoogleSignIn

class LoginViewController: BaseViewController {
    override func loadView() {
        view = LoginView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = NavBarConfiguration(
            style: .closeButtonOnly,
            rightButtonImage: UIImage(named: "icon_X"),
            buttonTintColor: .gray100
        )
        configureNavBar(config)
    }
}
