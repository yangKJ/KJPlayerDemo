//
//  Timer.swift
//  KJPlayer
//
//  Created by abas on 2021/12/18.
//

import Foundation
import UIKit

/// 该计时器会一直跑起来，需要使用的地方自行借取
/// The timer will keep running and borrow it from the place where it needs to be used
extension KJBasePlayer {
    private struct Keys {
        static var timer = "timerKey"
    }
    
    private var timer: Timer? {
        get { objc_getAssociatedObject(self, &Keys.timer) as? Timer }
        set { objc_setAssociatedObject(self, &Keys.timer, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    /// Initialize the timer
    /// - Parameter time: time interval, default `1`
    internal func setupTimer(_ time: TimeInterval?) {
        self.timer?.invalidate()
        self.timer = Timer.kj_scheduledTimer(withTimeInterval: time ?? 1,
                                             repeats: true,
                                             block: { [weak self] (timer) in
            guard let `self` = self else { return }
            self.runingCommonTimer(sender: timer)
        })
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    internal func deinitTimer() {
        if let _ = self.timer {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    /// Modify the time interval
    /// - Parameter time: time interval
    internal func changeTimeInterval(_ time: TimeInterval) {
        self.deinitTimer()
        self.setupTimer(time)
    }
    
    @objc internal func runingCommonTimer(sender: Timer?) {
        NotificationCenter.default.post(name: KJBasePlayer.kNotification.timerKey, object: self)
    }
}
