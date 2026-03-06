//
//  PermissionGuideVC.swift
//  LottoMate
//
//  Created by Mirae on 4/8/25.
//

import UIKit
import FlexLayout
import PinLayout
import CoreLocation
import AVFoundation

class PermissionGuideVC: UIViewController, CLLocationManagerDelegate {
    // MARK: - Properties
    private let locationManager = CLLocationManager()

    // MARK: - UI Components
    private let containerView = UIView()
    
    private let statusBarHeight = DeviceMetrics.statusBarHeight
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "더 편리한 사용을 위해\r앱 접근 권한을 확인해주세요"
        label.numberOfLines = 2
        styleLabel(for: label, fontStyle: .title3, textColor: .black, alignment: .left)
        return label
    }()
    
    private let cameraAuthImg = CommonImageView(imageName: "ch_camera")
    private let locationAuthImg = CommonImageView(imageName: "ch_location")
    
    private let cameraAuthLabel: UILabel = {
        let label = UILabel()
        label.text = "카메라(선택)"
        styleLabel(for: label, fontStyle: .headline2, textColor: .black, alignment: .left)
        return label
    }()
    
    private let cameraAuthSubLabel: UILabel = {
        let label = UILabel()
        label.text = "복권의 QR코드로\r당첨을 확인할 수 있어요"
        label.numberOfLines = 2
        styleLabel(for: label, fontStyle: .label2, textColor: .gray100, alignment: .left)
        return label
    }()
    
    private let locationAuthLabel: UILabel = {
        let label = UILabel()
        label.text = "사용자 위치 정보(선택)"
        styleLabel(for: label, fontStyle: .headline2, textColor: .black, alignment: .left)
        return label
    }()
    
    private let locationAuthSubLabel: UILabel = {
        let label = UILabel()
        label.text = "내 주변의 로또 판매점을\r확인할 수 있어요"
        label.numberOfLines = 2
        styleLabel(for: label, fontStyle: .label2, textColor: .gray100, alignment: .left)
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "*선택사항으로 접근 허용하지 않아도 로또메이트를 이용할 수 있어요"
        styleLabel(for: label, fontStyle: .caption2, textColor: .gray100, alignment: .left)
        return label
    }()
    
    private let confirmButton = StyledButton(
        title: "확인",
        buttonStyle: .solid(.large, .active),
        cornerRadius: 8,
        verticalPadding: 12,
        horizontalPadding: 0
    )
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        locationManager.delegate = self
        setupView()
        addActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.top().horizontally().bottom()
        containerView.flex.layout()
    }
    
    private func setupView() {
        view.addSubview(containerView)
        
        let topMargin = (UIScreen.main.bounds.height - statusBarHeight) / 7.3846
        
        containerView.flex
            .direction(.column)
            .gap(44)
            .paddingHorizontal(20)
            .backgroundColor(.white)
            .paddingTop(statusBarHeight + topMargin)
            .define { flex in
                
                flex.addItem(titleLabel)
                
                flex.addItem()
                    .direction(.column)
                    .paddingVertical(24)
                    .paddingHorizontal(28)
                    .gap(24)
                    .backgroundColor(.gray10)
                    .cornerRadius(16)
                    .define { flex in
                        flex.addItem()
                            .direction(.row)
                            .alignItems(.center)
                            .gap(20)
                            .define { flex in
                                flex.addItem(cameraAuthImg)
                                    .size(60)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(4)
                                    .define { flex in
                                        flex.addItem(cameraAuthLabel)
                                        flex.addItem(cameraAuthSubLabel)
                                    }
                            }
                        flex.addItem()
                            .direction(.row)
                            .alignItems(.center)
                            .gap(20)
                            .define { flex in
                                flex.addItem(locationAuthImg)
                                flex.addItem()
                                    .direction(.column)
                                    .gap(4)
                                    .define { flex in
                                        flex.addItem(locationAuthLabel)
                                        flex.addItem(locationAuthSubLabel)
                                    }
                            }
                        flex.addItem(infoLabel)
                    }
                
                flex.addItem()
                    .backgroundColor(.white)
                    .width(100%)
                    .grow(1)
                
                // 하단 버튼
                flex.addItem(confirmButton)
                    .marginBottom(36)
            }
    }
    
    private func addActions() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func confirmButtonTapped() {
        OnboardingManager.shared.setPermissionGuideCompleted(true)

        requestLocationPermission()
        requestCameraPermission()

        switchToMainApp()
    }

    // MARK: - Permission Requests
    private func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                // 필요 시 메인 스레드에서 granted 여부에 따른 UI 처리
                // DispatchQueue.main.async { ... }
            }
        }
    }

    // MARK: - Navigation
    private func switchToMainApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            print("Error: Could not find SceneDelegate.")
            return
        }

        let mainVC = TabBarViewController()
        sceneDelegate.window?.rootViewController = mainVC
        sceneDelegate.window?.makeKeyAndVisible()

        UIView.transition(with: sceneDelegate.window!,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }

    // MARK: - CLLocationManagerDelegate (선택적이지만 권장)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // 권한 상태 변경 시 처리 (예: 거부 시 설정으로 안내)
        // switch manager.authorizationStatus {
        // case .denied, .restricted:
        //     // 설정 앱으로 유도하는 알림 표시 등
        // case .authorizedWhenInUse, .authorizedAlways:
        //     // 권한 허용됨
        // default:
        //     break
        // }
    }
}
