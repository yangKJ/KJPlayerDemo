//
//  TryLookTime.swift
//  KJPlayer
//
//  Created by abas on 2021/12/18.
//

import Foundation

/// 免费观看时间协议
@objc public protocol KJPlayerFreeDelegate {
    
    /// Get free look time
    @objc(kj_freeLookTimeWithPlayer:)
    func kj_freeLookTime(with player: KJBasePlayer) -> TimeInterval
    
    /// Free viewing time has ended
    @objc(kj_freeLookReached:currentTime:)
    optional func kj_freeLookReached(with player: KJBasePlayer, currentTime: TimeInterval)
}

extension KJBasePlayer {
    
    @objc public var freeTime: TimeInterval {
        get { return 0.0 }
    }
    
    @objc public func kj_closeFreeLookTimeLimit() {
        
    }
    
    @objc public func kj_againOpenFreeLookTimeLimit() {
        
    }
}

extension KJBasePlayer {
    internal struct FreeTime { }
    
}

extension KJBasePlayer.FreeTime {
    
    internal static func canContinueLook(_ player: KJBasePlayer, time: TimeInterval) -> Bool {
        
        return false
    }
}
