//
//  Bridge.swift
//  KJPlayer
//
//  Created by abas on 2021/12/15.
//

import Foundation

/// 桥接相关，主要连接各个功能点和内核之间的联系
/// Bridging related, mainly connecting the connection between each function point and the kernel
internal enum BridgeMethod {
    ///`Initialization player`
    case `init`(_ player: KJBasePlayer)
    ///`Start preparing play`
    case begin(_ player: KJBasePlayer)
    ///`Playing`
    case playing(_ player: KJBasePlayer, time: TimeInterval)
    ///`Play end`
    case end(_ player: KJBasePlayer)
    ///`The player status has changed`
    case playState(_ player: KJBasePlayer, state: KJPlayerState)
    ///`Player destruction`
    case `deinit`(_ player: KJBasePlayer)
}

extension BridgeMethod {
    
    @discardableResult
    internal func initialization() -> (isBackground: Bool, isPlaying: Bool)? {
        switch self {
        case .`init`(_):
            return (true, true)
        default:
            return nil
        }
    }
}

extension BridgeMethod {
    
    internal func preparing() -> TimeInterval {
        var time = 0.0
        switch self {
        case .begin(let player):
            time = self.recordTime(player)
            if time > 0 { break }
            time = BridgeMethod.skipTime(player)
            if time > 0 { break }
        default:
            break
        }
        return time
    }
    
    private func recordTime(_ player: KJBasePlayer) -> TimeInterval {
        return KJBasePlayer.RecordTime.lastPlayedTimeIMP(player)
    }
    
    internal static func skipTime(_ player: KJBasePlayer) -> TimeInterval {
        
        return 10.0
    }
}

extension BridgeMethod {
    
    internal var playing: Bool {
        switch self {
        case .playing(let player, let time):
            if self.uncontinueLook(player, time: time) {
                return true
            }
            return false
        default:
            return false
        }
    }
    
    /// Can't continue watching
    private func uncontinueLook(_ player: KJBasePlayer, time: TimeInterval) -> Bool {
        ///`1.Played to or more than reached time
        if KJBasePlayer.FreeTime.canContinueLook(player, time: time) {
            return true
        }
        return false
    }
}

extension BridgeMethod {
    
    internal func playFinished() {
        switch self {
        case .end(let player):
            KJBasePlayer.RecordTime.deletePlayedTimeIMP(player)
            break
        default:
            break
        }
    }
}

extension BridgeMethod {
    
    internal func dealloc() {
        switch self {
        case .`deinit`(let player):
            KJBasePlayer.RecordTime.recordPlayedTimeIMP(player)
            break
        default:
            break
        }
    }
}

extension BridgeMethod {
    
    internal static func freeLookEnded(_ player: KJBasePlayer) -> Bool {
        return KJBasePlayer.FreeTime.freeTimeEnded(player)
    }
}
