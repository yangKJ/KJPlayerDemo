//
//  KJPlayer.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import Foundation
import UIKit

/// kjplayer common protocol method
public protocol KJPlayer {
    /// The original video address, used to replay the error and record the last play
    var originalURL: NSURL? { get }
    /// Link for play
    var playURL: NSURL? { get }
    /// Is it playing
    var isPlaying: Bool { get }
    /// Whether to pause for the user
    var isUserPause: Bool { get }
    /// Whether it is a live streaming media, the total time during the live broadcast is invalid
    var isLiveStreaming: Bool { get }
    /// Whether it is an online resource
    var isOnlineSource: Bool { get }
    /// Replay
    var isReplay: Bool { get }
    /// Current playing time
    var currentTime: TimeInterval { get }
    /// Total video time
    var totalTime: TimeInterval { get }
    /// Current video size
    var videoSize: CGSize { get }
    /// loaded progress
    var loadedProgress: Float { get }
    
    /// Whether the current playback is a video playback
    var isVideo: Bool { get }
    
    // MARK: - methods
    /// Start playing will respond to the last playing time and skip the opening
    /// The last play priority is higher than the skip opening
    func kj_play()
    /// replay will respond to skip the opening
    func kj_replay()
    /// pause
    func kj_pause()
    /// stop
    func kj_stop()
    /// play at specified time, fast forward or rewind function
    func kj_appointTime(_ time: TimeInterval)
    /// screenshot of the current time
    func kj_currentTimeScreenshots(_ screenshots: @escaping (_ image: UIImage) -> Void)
}

extension KJPlayer {
    public var originalURL: NSURL? { return nil }
    public var playURL: NSURL? { return nil }
    public var isPlaying: Bool { return false }
    public var isUserPause: Bool { return false }
    public var isLiveStreaming: Bool { return false }
    public var isOnlineSource: Bool { return true }
    public var isReplay: Bool { return false }
    public var currentTime: TimeInterval { return 0 }
    public var totalTime: TimeInterval { return 0 }
    public var videoSize: CGSize { return .zero }
    public var loadedProgress: Float { return 0.0 }
    public var isVideo: Bool { return true }
}

extension KJPlayer {
    public func kj_play() { }
    public func kj_replay() { }
    public func kj_pause() { }
    public func kj_stop() { }
    public func kj_appointTime(_ time: TimeInterval) { }
    public func kj_currentTimeScreenshots(_ screenshots: (_ image: UIImage) -> Void) { }
}
