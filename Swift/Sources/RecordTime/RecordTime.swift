//
//  RecordTime.swift
//  KJPlayer
//
//  Created by abas on 2021/12/15.
//

import Foundation

/// 记录播放时间协议
@objc public protocol KJPlayerRecordDelegate {
    
    /// Get whether the response needs to be recorded
    @objc(kj_recordTimeWithPlayer:)
    func kj_recordTime(with player: KJBasePlayer) -> Bool
    
    /// Get the response to the last play time
    @objc(kj_recordTimeWithPlayer:lastTime:)
    optional func kj_recordTime(with player: KJBasePlayer, lastTime: TimeInterval)
}

extension KJBasePlayer {
    
    /// Record last played time protocol, priority is higher than skip title
    @objc weak var recordDelegate: KJPlayerRecordDelegate? {
        get { objc_getAssociatedObject(self, &Keys.recordDelegate) as? KJPlayerRecordDelegate }
        set {
            objc_setAssociatedObject(self, &Keys.recordDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN)
            guard let function = newValue?.kj_recordTime(with:) else { return }
            self.record = function(self)
        }
    }
    
    /// Actively save the current played time
    @objc public func kj_saveRecordLastTime() {
        KJBasePlayer.RecordTime.recordPlayedTimeIMP(self)
    }
    
    /// Reset current recorded time, Zero
    @objc public func kj_resetRecordedTime() {
        KJBasePlayer.RecordTime.deletePlayedTimeIMP(self)
    }
    
    /// Stop record played time
    @objc public func kj_stopRecordPlayedTime(_ stop: Bool) {
        if self.record != nil {
            self.record = !stop
        }
    }
}

extension KJBasePlayer {
    internal struct RecordTime { }
    private struct Keys {
        static var recordDelegate = "recordDelegateKey"
        static var record = "recordKey"
    }
    
    private var record: Bool? {
        get { objc_getAssociatedObject(self, &Keys.record) as? Bool }
        set { objc_setAssociatedObject(self, &Keys.record, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}

extension KJBasePlayer.RecordTime {
    
    /// Get the last playing time
    internal static func lastPlayedTimeIMP(_ player: KJBasePlayer) -> TimeInterval {
        guard let _ = player.record, let originalURL = player.originalURL else { return 0.0 }
        let name = Common.Function.intactName(originalURL)
        let dbid = Common.Crypto.MD5(name)
        let (total, time) = RecordTimeData.lastPlayTime(with: dbid)
        if total > 0 {
            player.totalTimeObserve = total
        }
        if let function = player.recordDelegate?.kj_recordTime(with:lastTime:) {
            function(player, time)
        }
        return time
    }
    
    /// Save played time
    internal static func recordPlayedTimeIMP(_ player: KJBasePlayer) {
        guard let _ = player.record, let originalURL = player.originalURL else { return }
        let name = Common.Function.intactName(originalURL)
        let dbid = Common.Crypto.MD5(name)
        RecordTimeData.savePlayedTime(player.currentTime, total: player.totalTime, dbid: dbid)
    }
    
    /// Delete played time record
    internal static func deletePlayedTimeIMP(_ player: KJBasePlayer) {
        guard let originalURL = player.originalURL else { return }
        let name = Common.Function.intactName(originalURL)
        let dbid = Common.Crypto.MD5(name)
        RecordTimeData.DB.delete(with: dbid)
    }
}
