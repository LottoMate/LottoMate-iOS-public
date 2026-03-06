//
//  DeviceMetrics.swift
//  LottoMate
//
//  Created by Mirae on 11/1/24.
//

import UIKit

enum DeviceMetrics {
    // 현재 활성화된 window를 가져오는 메서드
    static var keyWindow: UIWindow? {
        // iOS 15 이상
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene?.windows.first(where: { $0.isKeyWindow })
        }
        // iOS 15 미만
        else {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
    }
    
    static var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let bottomPadding = keyWindow?.safeAreaInsets.bottom ?? 0
            return bottomPadding > 0
        }
        return false
    }
    
    static var statusBarHeight: CGFloat {
        if #available(iOS 15.0, *) {
            // 활성화된 windowScene의 statusBarManager 사용
            guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            else { return 0 }
            return windowScene.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
    }
    
    /// 커스텀 네비게이션 바의 높이가 56으로 고정되기 때문에 56으로 설정
    static var navigationBarHeight: CGFloat {
        return 56
    }
    
    static var statusWithNavigationBarHeight: CGFloat {
        return statusBarHeight + navigationBarHeight
    }
    
    static var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return keyWindow?.safeAreaInsets ?? .zero
        }
        return .zero
    }
    
    /// 탭바의 전체 높이 (탭바 자체 높이 + bottom safe area)
    static var tabBarHeight: CGFloat {
        let baseTabBarHeight: CGFloat = 49 // 기본 탭바 높이
        let bottomInset = safeAreaInsets.bottom
        return baseTabBarHeight + bottomInset
    }
    
    /// 탭바의 기본 높이 (safe area 제외)
    static var tabBarBaseHeight: CGFloat {
        return 49
    }
    
    // 디바이스 모델 확인
    static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    // 디바이스별 실제 높이 값들
    struct Heights {
        static func forDevice() -> (statusBar: CGFloat, navigationBar: CGFloat) {
            let device = deviceModel
            
            switch device {
            // iPhone SE (2nd gen), 8, 7, 6s, 6
            case "iPhone8,1", "iPhone8,2", "iPhone8,4", "iPhone9,1", "iPhone9,3", "iPhone9,2", "iPhone9,4", "iPhone10,1", "iPhone10,4":
                return (20, 44)
                
            // iPhone X, XS, 11 Pro
            case "iPhone10,3", "iPhone10,6", "iPhone11,2", "iPhone12,3":
                return (44, 44)
                
            // iPhone XR, 11
            case "iPhone11,8", "iPhone12,1":
                return (48, 44)
                
            // iPhone 12, 12 Pro, 13, 13 Pro
            case "iPhone13,2", "iPhone13,3", "iPhone14,2", "iPhone14,3":
                return (47, 44)
                
            // iPhone 14 Pro, 14 Pro Max (Dynamic Island)
            case "iPhone15,2", "iPhone15,3":
                return (54, 44)
                
            // iPhone 15 Series
            case "iPhone15,4", "iPhone15,5", "iPhone16,1", "iPhone16,2":
                return (54, 44)
                
            // 기본값 (알 수 없는 기기)
            default:
                return hasNotch ? (44, 56) : (20, 44)
            }
        }
    }
    
    // 현재 기기의 정보를 출력
    static func printDeviceInfo() {
        let heights = Heights.forDevice()
        print("Device Model: \(deviceModel)")
        print("Has Notch: \(hasNotch)")
        print("Status Bar Height: \(heights.statusBar)")
        print("Navigation Bar Height: \(heights.navigationBar)")
        print("Total Navigation Height: \(heights.statusBar + heights.navigationBar)")
        print("Safe Area Insets: \(safeAreaInsets)")
    }
}
