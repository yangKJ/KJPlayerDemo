//
//  SkipTime.swift
//  KJPlayer
//
//  Created by abas on 2021/12/18.
//

import Foundation

/// 跳过片头片尾协议
@objc public protocol KJPlayerSkipDelegate {
    
    /// Get the opening time of the beginning of the play
    @objc(kj_skipOpeningTimeWithPlayer:)
    optional func kj_skipOpeningTime(with player: KJBasePlayer) -> TimeInterval
    
    /// Get the ending time of the ending time
    @objc(kj_skipEndingTimeWithPlayer:)
    optional func kj_skipEndingTime(with player: KJBasePlayer) -> TimeInterval
    
    @objc(kj_skipOpeningTimeWithPlayer:openingTime:)
    optional func kj_skipOpeningTime(with player: KJBasePlayer, openingTime: TimeInterval)
    
    @objc(kj_skipEndingTimeWithPlayer:endingTime:)
    optional func kj_skipEndingTime(with player: KJBasePlayer, endingTime: TimeInterval)
}

extension KJBasePlayer {
    
}
