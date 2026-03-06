//
//  StoreBottomSheetContainerViewController.swift
//  LottoMate
//
//  Created by Mirae on 3/4/25.
//

import Foundation
import UIKit
import ReactorKit

class StoreBottomSheetContainerViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    
    /// 판매점 리스트 형태
    private let listViewController = MultiStoreListBottomSheetVC()
    /// 판매점 하나의 정보
    private let detailViewController = SingleStoreDetailBottomSheetVC()
    
    private var currentViewController: UIViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 기본 리스트 뷰 표시
        showViewController(listViewController)
    }
    
    func bind(reactor: MapViewReactor) {
        // 리스트 뷰 컨트롤러에 reactor 전달
        listViewController.reactor = reactor
        
        // 상세 뷰 컨트롤러에 reactor 전달
        detailViewController.reactor = reactor
        
        reactor.state
            .map { $0.bottomSheetViewMode }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewMode in
                guard let self = self else { return }
                
                switch viewMode {
                case .list:
                    self.showViewController(self.listViewController)
                case .detail:
                    self.showViewController(self.detailViewController)
                    
                    // 바텀 시트 높이 조정
                    if let bottomSheet = self.findParentBottomSheet() {
                        bottomSheet.expandToMidHeight()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showViewController(_ viewController: UIViewController) {
        // 현재 표시 중인 뷰 컨트롤러 제거
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
        
        // 새 뷰 컨트롤러 추가
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
        
        currentViewController = viewController
    }
    
    private func findParentBottomSheet() -> CustomBottomSheetViewController? {
        var parentViewController = self.parent
        while parentViewController != nil {
            if let bottomSheet = parentViewController as? CustomBottomSheetViewController {
                return bottomSheet
            }
            parentViewController = parentViewController?.parent
        }
        return nil
    }
}
