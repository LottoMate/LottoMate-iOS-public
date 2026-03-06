//
//  LoadingViewManager.swift
//  LottoMate
//
//  Created by Mirae on 10/14/24.
//

import UIKit

class LoadingViewManager {
    static let shared = LoadingViewManager()
    private var loadingView: UIView?
    
    private init() {}
    
    func showLoading() {
        guard loadingView == nil else { return }
        
        DispatchQueue.main.async {
            let window = self.getKeyWindow()
            
            let loadingView = MapLoadingView()
            if let window = window {
                loadingView.frame = window.bounds
                window.addSubview(loadingView)
            } else {
                print("No window found!")
            }
            
            self.loadingView = loadingView
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.loadingView?.removeFromSuperview()
            self.loadingView = nil
        }
    }
    
    private func getKeyWindow() -> UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window
    }
}
