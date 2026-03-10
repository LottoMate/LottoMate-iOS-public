//
//  QRScannerManager.swift
//  LottoMate
//
//  Created by Mirae on 12/24/24.
//

import UIKit
import VisionKit
import RxSwift
import RxRelay

protocol QRScannerManagerDelegate: AnyObject {
    func qrScannerManager(_ manager: QRScannerManager, didScanResult result: String)
    func qrScannerManager(_ manager: QRScannerManager, didFailWithError error: Error)
}

class QRScannerManager: NSObject {
    static let shared = QRScannerManager()
    private var dataScannerViewController: DataScannerViewController?
    private weak var delegate: QRScannerManagerDelegate?
    
    let scanResult = PublishSubject<String>()
    let scanError = PublishRelay<Error>()
    let scannerDismissed = PublishSubject<Void>()
    
    private var isProcessingResult = false
    
    private override init() {
        super.init()
        Task {
            await setupDataScanner()
        }
    }
    
    func resetScanResult() {
        isProcessingResult = false
    }
    
    @MainActor
    private func setupDataScanner() {
        guard DataScannerViewController.isSupported,
              DataScannerViewController.isAvailable else {
            return
        }
        dataScannerViewController = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .fast,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isGuidanceEnabled: false,
            isHighlightingEnabled: true
        )
        dataScannerViewController?.delegate = self
    }
    
    func setDelegate(_ delegate: QRScannerManagerDelegate) {
        self.delegate = delegate
    }
    
    @MainActor
    func presentScanner(from viewController: UIViewController, with overlayView: UIView? = nil) {
        resetScanResult()
        
        guard let scanner = dataScannerViewController else {
            let error = NSError(
                domain: "QRScannerManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Scanner not available"]
            )
            delegate?.qrScannerManager(self, didFailWithError: error)
            scanError.accept(error)
            return
        }
        
        // Dismiss any existing scanner before presenting a new one
        if scanner.presentingViewController != nil {
            dismissScanner(animated: false) {
                self.presentNewScanner(scanner: scanner, from: viewController, with: overlayView)
            }
        } else {
            presentNewScanner(scanner: scanner, from: viewController, with: overlayView)
        }
    }
    
    @MainActor
    private func presentNewScanner(scanner: DataScannerViewController, from viewController: UIViewController, with overlayView: UIView? = nil) {
        // Clear any existing subviews from the overlay container
        scanner.overlayContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        // 오버레이 뷰가 있으면 추가
        if let overlayView = overlayView {
            overlayView.frame = viewController.view.bounds
            scanner.overlayContainerView.addSubview(overlayView)
        }
        
        scanner.modalPresentationStyle = .fullScreen
        viewController.present(scanner, animated: true) {
            try? scanner.startScanning()
            
            // 스캐너가 표시된 후에 버튼을 추가 (이렇게 하면 뷰 계층이 준비된 상태에서 버튼 추가)
            Task { @MainActor in
                self.addCloseButton(to: scanner)
            }
        }
    }
    
    @MainActor
    private func addCloseButton(to scanner: DataScannerViewController) {
        // 기존에 추가된 버튼이 있다면 제거
        scanner.view.subviews.forEach { view in
            if let button = view as? UIButton {
                button.removeFromSuperview()
            }
        }
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(named: "icon_X"), for: .normal)
        closeButton.tintColor = .white.withAlphaComponent(0.6)
        closeButton.backgroundColor = .clear
        closeButton.layer.cornerRadius = 0
        
        // 버튼 크기 및 위치 설정
        closeButton.frame = CGRect(x: scanner.view.bounds.width - 44, y: 60, width: 24, height: 24)
        
        // 버튼에 태그를 설정하여 식별 가능하게
        closeButton.tag = 100
        
        // 액션 추가
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // 버튼을 window에 직접 추가 (DataScannerViewController의 뷰가 아닌)
        if let window = scanner.view.window {
            window.addSubview(closeButton)
            window.bringSubviewToFront(closeButton)
        } else {
            scanner.view.addSubview(closeButton)
            scanner.view.bringSubviewToFront(closeButton)
        }
    }
    
    @objc private func closeButtonTapped() {
        print("QRScannerManager: X 버튼 탭됨!")
        dismissScanner()
    }
    
    @MainActor
    func stopScanning() {
        dataScannerViewController?.stopScanning()
    }
    
    func dismissScanner(animated: Bool = true, completion: (() -> Void)? = nil) {
        // Stop scanning before dismissing
        Task { @MainActor in
            dataScannerViewController?.stopScanning()
            
            // 추가된 버튼들 제거
            if let scanner = dataScannerViewController {
                if let window = scanner.view.window {
                    window.subviews.forEach { view in
                        if let button = view as? UIButton, button.tag == 100 {
                            button.removeFromSuperview()
                        }
                    }
                }
                
                scanner.view.subviews.forEach { view in
                    if let button = view as? UIButton, button.tag == 100 {
                        button.removeFromSuperview()
                    }
                }
            }
            
            // Clear any subviews from the overlay container
            dataScannerViewController?.overlayContainerView.subviews.forEach { $0.removeFromSuperview() }
            
            // Dismiss the scanner
            if dataScannerViewController?.presentingViewController != nil {
                dataScannerViewController?.dismiss(animated: animated) {
                    self.scannerDismissed.onNext(())
                    completion?()
                }
            } else {
                self.scannerDismissed.onNext(())
                completion?()
            }
        }
    }
}

extension QRScannerManager: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        guard let item = addedItems.first, !isProcessingResult else { return }
        
        if case .barcode(let barcode) = item, let payloadString = barcode.payloadStringValue {
            isProcessingResult = true
            
            delegate?.qrScannerManager(self, didScanResult: payloadString)
            scanResult.onNext(payloadString)
            
            // Ensure proper cleanup
            Task { @MainActor in
                stopScanning()
                
                // Clear any subviews from the overlay container
                dataScanner.overlayContainerView.subviews.forEach { $0.removeFromSuperview() }
                
                dismissScanner()
            }
        }
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
        delegate?.qrScannerManager(self, didFailWithError: error)
        scanError.accept(error)
    }
}

