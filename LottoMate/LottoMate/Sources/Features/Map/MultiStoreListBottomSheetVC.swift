//
//  MapStoreListBottomSheetVC.swift
//  LottoMate
//
//  Created by Mirae on 2/20/25.
//

import Foundation
import UIKit
import ReactorKit

class MultiStoreListBottomSheetVC: UIViewController, View {
    var disposeBag = DisposeBag()
    
    override func loadView() {
        let bottomSheetView = MultiStoreListBottomSheetView()
        bottomSheetView.reactor = reactor
        view = bottomSheetView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bind(reactor: MapViewReactor) { }
}
