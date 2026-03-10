//
//  DrawRoundBottomSheetViewController.swift
//  LottoMate
//
//  Created by Mirae on 9/6/24.
//

import UIKit

class DrawRoundBottomSheetViewController: UIViewController {
    fileprivate var mainView: DrawRoundBottomSheet {
        return self.view as! DrawRoundBottomSheet
    }
    
    let drawRoundBottomSheet = DrawRoundBottomSheet()
    
    override func loadView() {
        view = drawRoundBottomSheet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

#Preview {
    let view = DrawRoundBottomSheetViewController()
    return view
}
