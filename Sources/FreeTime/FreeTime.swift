//
//  TryLookTime.swift
//  KJPlayer
//
//  Created by abas on 2021/12/18.
//

import Foundation

/// 免费观看时间协议
@objc public protocol KJPlayerFreeDelegate {
    
    /// Get free watching time
    @objc(kj_freeLookTimeWithPlayer:)
    func kj_freeLookTime(with player: KJBasePlayer) -> TimeInterval
    
    /// Free watching time has ended
    @objc(kj_freeLookTimeWithPlayer:currentTime:)
    optional func kj_freeLookTime(with player: KJBasePlayer, currentTime: TimeInterval)
}

extension KJBasePlayer {
    
    /// Free watching time protocol
    @objc weak var freeDelegate: KJPlayerFreeDelegate? {
        get { objc_getAssociatedObject(self, &Keys.freeDelegate) as? KJPlayerFreeDelegate }
        set {
            objc_setAssociatedObject(self, &Keys.freeDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN)
            guard let function = newValue?.kj_freeLookTime(with:) else { return }
            self.tryTime = function(self)
        }
    }
    
    @objc public var freeTime: TimeInterval {
        get { return (self.tryTime != nil) ? self.tryTime! : 0.0 }
    }
    
    /// 关闭免费试看限制
    @objc public func kj_closeFreeLookTimeLimit() {
        self.closeTLook = true
        self.tryLooked = false
        self.playerStatus = .beginPlay
    }
    
    /// 继续开启试看限制，播放下一个不同视频可以不用管，
    /// 主要针对于打开试看限制之后，重播会不再开启试看限制的影响
    /// Continue to open the free watching limit, and you can leave it alone when playing the next different video,
    /// Mainly aimed at the effect that the replay will no longer open the trial limit after opening the trial limit
    @objc public func kj_againOpenFreeLookTimeLimit() {
        self.closeTLook = false
    }
}

extension KJBasePlayer {
    internal struct FreeTime { }
    private struct Keys {
        static var freeDelegate = "freeDelegateKey"
        static var closeTLook = "closeTLookKey"
        static var tryTime = "tryTimeKey"
        static var tryLooked = "tryLookedKey"
    }
    private var tryTime: TimeInterval? {
        get { objc_getAssociatedObject(self, &Keys.tryTime) as? TimeInterval }
        set {
            objc_setAssociatedObject(self, &Keys.tryTime, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if let time = newValue, time > 0 {
                self.closeTLook = false
            }
        }
    }
    private var closeTLook: Bool? {
        get { objc_getAssociatedObject(self, &Keys.closeTLook) as? Bool }
        set { objc_setAssociatedObject(self, &Keys.closeTLook, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    private var tryLooked: Bool? {
        get { objc_getAssociatedObject(self, &Keys.tryLooked) as? Bool }
        set { objc_setAssociatedObject(self, &Keys.tryLooked, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}

extension KJBasePlayer.FreeTime {
    
    internal static func freeTimeEnded(_ player: KJBasePlayer) -> Bool {
        return (player.tryLooked != nil) ? player.tryLooked! : false
    }
    
    internal static func canContinueLook(_ player: KJBasePlayer, time: TimeInterval) -> Bool {
        guard let tryTime = player.tryTime, tryTime > 0 else { return false }
        /// 总时长为零时刻不处理试看
        if player.totalTime <= 0 {
            player.tryLooked = false
            return false
        }
        if let close = player.closeTLook, close {
            player.tryLooked = false
            return false
        }
        if time >= tryTime {
            player.currentTimeObserve = tryTime
            if let tryLooked = player.tryLooked, tryLooked == false {
                player.tryLooked = true
                player.playerStatus = .paused(user: false)
                if let function = player.freeDelegate?.kj_freeLookTime(with:currentTime:) {
                    function(player, tryTime)
                }
            }
        } else {
            player.tryLooked = false
        }
        return player.tryLooked!
    }
}
