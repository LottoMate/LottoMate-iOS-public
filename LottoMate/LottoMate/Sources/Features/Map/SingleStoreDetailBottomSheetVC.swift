//
//  StoreInfoBottomSheetViewController.swift
//  LottoMate
//
//  Created by Mirae on 10/10/24.
//

import UIKit
import ReactorKit

class SingleStoreDetailBottomSheetVC: UIViewController, View {
    var disposeBag = DisposeBag()
    
    let storeInfoBottomSheetView = SingleStoreDetailBottomSheetView()
    
    override func loadView() {
        storeInfoBottomSheetView.reactor = reactor
        view = storeInfoBottomSheetView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bind(reactor: MapViewReactor) {
        reactor.state
            .map { $0.selectedStore }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] store in
                self?.storeInfoBottomSheetView.updateStoreInfo(
                    with: store,
                    currentLocation: reactor.currentState.currentLocation
                )
            })
            .disposed(by: disposeBag)
    }
}
