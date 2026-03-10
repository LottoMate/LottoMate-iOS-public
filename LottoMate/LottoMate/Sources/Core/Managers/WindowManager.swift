//
//  WindowManager.swift
//  LottoMate
//
//  Created by Mirae on 10/31/24.
//

import UIKit

final class WindowManager {
    static func findKeyWindow(from source: Any? = nil) -> UIWindow? {
        if let view = source as? UIView {
            return view.window
        } else if let viewController = source as? UIViewController {
            return viewController.view.window
        }
        
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
    }
}
