//
//  QRWinningCheckLoadingManager.swift
//  LottoMate
//
//  Created by Mirae on 4/28/25.
//

import UIKit

/// QR 스캔 후 당첨 확인 과정에서 나타나는 로딩 화면을 관리하는 매니저
class QRWinningCheckLoadingManager {
    static let shared = QRWinningCheckLoadingManager()
    
    private var loadingView: QRWinningCheckLoadingView?
    private var currentStage: LoadingStage = .none
    
    private init() {}
    
    enum LoadingStage {
        case none
        case first  // 첫 번째 로딩 단계
        case second // 두 번째 로딩 단계
    }
    
    /// 첫 번째 로딩 단계를 표시합니다 (QR 인식 후 결과 확인 중)
    func showFirstLoadingStage(onComplete: (() -> Void)? = nil) {
        guard loadingView == nil else { return }
        
        DispatchQueue.main.async {
            let window = self.getKeyWindow()
            
            let loadingView = QRWinningCheckLoadingView()
            loadingView.setStage(.first)
            
            if let window = window {
                loadingView.frame = window.bounds
                window.addSubview(loadingView)
            } else {
                print("No window found!")
            }
            
            self.loadingView = loadingView
            self.currentStage = .first
            
            // 첫 번째 로딩 애니메이션을 위한 지연 (1.5초)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete?()
            }
        }
    }
    
    /// 두 번째 로딩 단계로 전환합니다 (당첨 결과 계산 중)
    func showSecondLoadingStage() {
        DispatchQueue.main.async {
            if self.currentStage == .first {
                self.loadingView?.setStage(.second)
                self.currentStage = .second
            } else if self.loadingView == nil {
                // 첫 번째 단계가 누락된 경우 (비정상적인 케이스) 첫 번째 단계부터 시작
                self.showFirstLoadingStage {
                    self.showSecondLoadingStage()
                }
            }
        }
    }
    
    /// 로딩 화면을 숨깁니다
    func hideLoading() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.loadingView?.alpha = 0
            }, completion: { _ in
                self.loadingView?.removeFromSuperview()
                self.loadingView = nil
                self.currentStage = .none
            })
        }
    }
    
    private func getKeyWindow() -> UIWindow? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first { $0.isKeyWindow }
        }
        return nil
    }
} 