//
//  Enum.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import Foundation
import UIKit

@objc public enum KJPlayerState : Int {
    case playing
    case paused
    
    public var mapString: String {
        switch self {
        case .playing:
            return "playing"
        case .paused:
            return "paused"
        @unknown default:
            return ""
        }
    }
    
    var controlPlayImage: UIImage? {
        switch self {
        case .playing:
            return UIImage(named: "")
        case .paused:
            return UIImage(named: "")
        default:
            return nil
        }
    }
}

/// Player video full type
@objc public enum KJPlayerVideoGravity : Int {
    /// 最大边等比充满，按比例压缩
    /// The largest side is filled proportionally and compressed proportionally
    case resizeAspect = 0
    /// 原始尺寸，视频不会有黑边
    /// Original size, the video will not have black borders
    case resizeAspectFill
    /// 拉伸充满，视频会变形
    /// Stretched to full, the video will be distorted
    case resizeOriginal
}

// MARK: - Internal use of the project
internal enum PlayerAsset: Int {
    case NONE, FILE, HLS
}

internal enum PlayerFailed {
    case knownFailed(_ error: NSError)
    case customFailed(_ code: Int, message: String = "", userInfo: [String: Any]? = nil)
    
    var playerFailed: NSError {
        switch self {
        case .knownFailed(let error):
            return error
        case .customFailed(let code, let message, let userInfo):
            if message == "" {
                return NSError.init(domain: "player.domain", code: code, userInfo: userInfo)
            }
            return NSError.init(domain: message, code: code, userInfo: userInfo)
        }
    }
}

internal enum PlayerStatus {
    /// Start preparing to play
    case prepare(provider: Provider)
    /// Whether to enable playback for the user
    case beginPlay
    /// Is it playing
    case playing(time: TimeInterval)
    /// Whether the user actively chooses to pause
    case paused(user: Bool)
    /// Whether the playback is complete,
    /// the video will respond to the end of the complete play and skip end play
    case playFinished(skip: Bool)
    /// Whether the playback is wrong
    case failed(error: NSError?)
}
