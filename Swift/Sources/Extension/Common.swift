//
//  Common.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import Foundation
import UIKit
import CommonCrypto

internal struct Common {
    internal struct Constant { }
    internal struct View { }
    internal struct Crypto { }
}

extension Common.Constant {
    
    static let width  = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
    static let navigationHeight = barHeight + 44.0
    static let tabBarHeight = (barHeight == 44 ? 83 : 49)
    static let kTopSafeAreaHeight = (barHeight - 20)
    static let kBottomSafeAreaHeight = (tabBarHeight - 49)
    static let barHeight: CGFloat = {
        if #available(iOS 13.0, *) {
            return Common.View.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }()
    
    static let isIphoneX: Bool = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return false
        }
        let size = UIScreen.main.bounds.size
        let notchValue: Int = Int(size.width / size.height * 100)
        if 216 == notchValue || 46 == notchValue {
            return true
        }
        guard #available(iOS 11.0, *) else { return false }
        if let bottomHeight = Common.View.keyWindow?.safeAreaInsets.bottom {
            return bottomHeight > 30
        }
        return false
    }()
}

extension Common.View {
    
    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    static var keyWindowPresentedController: UIViewController? {
        var viewController = Common.View.keyWindow?.rootViewController
        if let presentedController = viewController as? UITabBarController {
            viewController = presentedController.selectedViewController
        }
        while let presentedController = viewController?.presentedViewController {
            if let presentedController = presentedController as? UITabBarController {
                viewController = presentedController.selectedViewController
            } else {
                viewController = presentedController
            }
        }
        return viewController
    }
}

extension Common.Crypto {
    
    /// MD5
    static func MD5(_ string: String) -> String {
        let ccharArray = string.cString(using: String.Encoding.utf8)
        var uint8Array = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(ccharArray, CC_LONG(ccharArray!.count - 1), &uint8Array)
        return uint8Array.reduce("") { $0 + String(format: "%02X", $1) }
    }
}
