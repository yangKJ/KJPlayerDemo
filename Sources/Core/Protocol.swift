//
//  Protocol.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import Foundation
import UIKit

@objc public protocol KJPlayerDelegate: NSObjectProtocol {
    
    /// Current player status
    @objc(kj_player:state:)
    optional func kj_player(_ player: KJBasePlayer, state: KJPlayerState)
    
    /// Player play failed
    @objc(kj_player:playFailed:)
    optional func kj_player(_ player: KJBasePlayer, playFailed: NSError)
    
    /// Video loaded time
    @objc(kj_player:loadedTime:)
    optional func kj_player(_ player: KJBasePlayer, loadedTime: TimeInterval)
    
    @objc(kj_player:currentTime:)
    optional func kj_player(_ player: KJBasePlayer, current: TimeInterval)

    @objc(kj_player:videoTime:)
    optional func kj_player(_ player: KJBasePlayer, total: TimeInterval)
    
    @objc(kj_player:videoSize:)
    optional func kj_player(_ player: KJBasePlayer, videoSize: CGSize)
    
    /// At the end of the playback, the video will respond to the end of the complete play and skip end play
    /// 播放结束，音视频`自然完整播放`和`跳过片尾播放结束`均会响应
    @objc(kj_player:playFinished:)
    optional func kj_player(_ player: KJBasePlayer, playFinished: TimeInterval)
    
    @objc(kj_player:stopped:)
    optional func kj_player(_ player: KJBasePlayer, stopped: TimeInterval)
}

@objc public protocol KJPlayerBaseViewDelegate: NSObjectProtocol {
    
    /// Single tap gesture feedback
    @objc(kj_basePlayerView:singleTap:)
    optional func kj_basePlayerView(_ view: KJPlayerView, singleTap: CGPoint)
    
    /// Double tap gesture feedback
    @objc(kj_basePlayerView:doubleTap:)
    optional func kj_basePlayerView(_ view: KJPlayerView, doubleTap: Bool)
    
    /// Long press gesture feedback
    @objc(kj_basePlayerView:longPress:)
    optional func kj_basePlayerView(_ view: KJPlayerView, longPress: UILongPressGestureRecognizer)
    
    /// Volume gesture feedback
    @objc(kj_basePlayerView:volumeValue:)
    optional func kj_basePlayerView(_ view: KJPlayerView, volumeValue: Float) -> Bool
    
    /// Brightness gesture feedback
    @objc(kj_basePlayerView:brightnessValue:)
    optional func kj_basePlayerView(_ view: KJPlayerView, brightnessValue: Float) -> Bool
}
