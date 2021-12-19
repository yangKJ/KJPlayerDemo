//
//  Notification.swift
//  KJPlayer
//
//  Created by abas on 2021/12/15.
//

import Foundation
import UIKit

extension KJBasePlayer {
    internal struct kNotification {
        /// Notification of changes in the position and size of the control
        static let playViewRectName = Notification.Name(rawValue: "kPlayerViewRectNotification")
        /// Size information change key
        static let playViewRectKey = "kPlayerViewRectKey"
        /// The timer will keep running
        static let timerKey = NSNotification.Name(rawValue: "kPlayerRuningCommonTimerKey")
    }
    
    /// Add notification observer
    internal func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerViewRectChanged(_:)),
                                               name: KJBasePlayer.kNotification.playViewRectName,
                                               object: nil)
    }
    
    /// The position and size of the control changes
    /// - Parameter notification: Notification message
    @objc func playerViewRectChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let _ = userInfo[kNotification.playViewRectKey] as? CGRect else { return }

    }
}
