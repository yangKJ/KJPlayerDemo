//
//  KJBasePlayer.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import Foundation
import UIKit

@objcMembers open class KJBasePlayer: NSObject {
    
    public weak var delegate: KJPlayerDelegate?
    /// Player control
    public weak var playerView: KJPlayerView?
    /// Configuration information.
    public var provider: Provider? = nil
    
    /// Play speed, 0 ~ 2.
    public var speed: Float = 1.0
    /// is mute
    public var muted: Bool = false
    /// play volume
    public var volume: Float = 1.0
    /// Whether to open auto play
    public var autoPlay: Bool = true
    
    // MARK: - private
    private var _originalURL: NSURL? = nil
    private var _playURL: NSURL? = nil
    private var userPause: Bool = false
    private var localed: Bool = false
    private var replay: Bool = false
    private var playing: Bool = false
    
    public convenience init(withPlayerView view: KJPlayerView) {
        self.init()
        self.playerView = view
    }
    
    public override init() {
        super.init()
        self.setupTimer(1)
        self.setupNotification()
    }
    
    deinit {
        #if DEBUG
        print("🎷\(String(describing: self)): Deinited")
        #endif
        NotificationCenter.default.removeObserver(self)
        self.deinitTimer()
        BridgeMethod.deinit(self).dealloc()
    }
    
    internal func getVideoFrame() -> CGRect {
        guard let playerView = playerView else {
            return .zero
        }
        return playerView.bounds
    }
    
    /// Mainly deal with state and UI related here,
    /// `Sub class deal with the main logical ideas
    var playerStatus: PlayerStatus? {
        didSet {
            guard let playerStatus = playerStatus else {
                return
            }
            switch playerStatus {
            case .prepare(let provider):
                self.playFailedObserve = nil
                self.userPause = false
                self.replay = false
                self.playing = false
                self.playFinishedTimeObserve = 0.0
                self.setupVideoURL(provider.videoURL)
                break
            case .beginPlay:
                self.userPause = false
                self.playing = true
                break
            case .playing(let time):
                self.playing = true
                if userPause == false, !BridgeMethod.freeLookEnded(self) {
                    self.playStateObserve = .playing
                }
                self.currentTimeObserve = time
                break
            case .paused(let user):
                self.playing = false
                if user == true {
                    self.playStateObserve = .paused
                }
                self.userPause = user
                break
            case .playFinished(let skip):
                self.playing = false
                if skip {
                    self.playFinishedTimeObserve = self.currentTime
                } else {
                    self.playFinishedTimeObserve = self.totalTime
                }
                BridgeMethod.end(self).playFinished()
                break
            case .failed(let error):
                self.playing = false
                self.playFailedObserve = error
                break
            }
        }
    }
    
    /// Configuration play ink
    @discardableResult
    private func setupVideoURL(_ urlString: String?) -> NSURL? {
        var videoURL: NSURL? = nil
        if let videoURLString = urlString {
            if Common.Function.isOnlineResource(videoURLString) {
                self.localed = false
                videoURL = NSURL.init(string: videoURLString)
            } else {
                self.localed = true
                videoURL = NSURL.init(fileURLWithPath: videoURLString)
            }
        }
        self._originalURL = videoURL
        self._playURL = videoURL
        return videoURL
    }
    
    // MARK: - Observe
    internal var playStateObserve: KJPlayerState? {
        willSet {
            guard let newState = newValue else { return }
            var state: KJPlayerState?
            if playStateObserve == nil {
                state = newState
            } else if newState != playStateObserve {
                state = newState
            } else {
                return
            }
            if let function = self.delegate?.kj_player(_:state:) {
                DispatchQueue.main.async {
                    function(self, state!)
                }
            }
        }
    }
    
    internal var currentTimeObserve: TimeInterval? = 0.0 {
        willSet {
            guard let newTime = newValue else { return }
            guard let oldTime = currentTimeObserve else { return }
            if newTime != oldTime, let function = self.delegate?.kj_player(_:current:) {
                DispatchQueue.main.async {
                    function(self, newTime)
                }
            }
        }
    }
    
    internal var loadedTimeObserve: TimeInterval? = 0.0 {
        willSet {
            guard let newTime = newValue else { return }
            guard let oldTime = loadedTimeObserve else { return }
            if newTime != oldTime, newTime > 0, let function = self.delegate?.kj_player(_:loadedTime:) {
                DispatchQueue.main.async {
                    function(self, newTime)
                }
            }
        }
    }
    
    internal var totalTimeObserve: TimeInterval? = 0.0 {
        willSet {
            guard let newTime = newValue else { return }
            guard let oldTime = totalTimeObserve else { return }
            if newTime != oldTime, newTime > 0, let function = self.delegate?.kj_player(_:total:) {
                DispatchQueue.main.async {
                    function(self, newTime)
                }
            }
        }
    }
    
    internal var videoSizeObserve: CGSize? = .zero {
        willSet {
            guard let newVideoSize = newValue else { return }
            guard let oldVideoSize = videoSizeObserve else { return }
            if newVideoSize != oldVideoSize, let function = self.delegate?.kj_player(_:videoSize:) {
                DispatchQueue.main.async {
                    function(self, newVideoSize)
                }
            }
        }
    }
    
    internal var playFailedObserve: NSError? = nil {
        willSet {
            guard let newError = newValue else { return }
            guard let oldError = playFailedObserve else { return }
            if newError != oldError, let function = self.delegate?.kj_player(_:playFailed:) {
                DispatchQueue.main.async {
                    function(self, newError)
                }
            }
        }
    }

    /// End of play observer
    private var playFinishedTimeObserve: TimeInterval? {
        willSet {
            guard let newTime = newValue else { return }
            if playFinishedTimeObserve == nil || newTime != playFinishedTimeObserve {
                if let function = self.delegate?.kj_player(_:playFinished:), newTime > 0 {
                    DispatchQueue.main.async {
                        function(self, newTime)
                    }
                }
            }
        }
    }
}

extension KJBasePlayer: KJPlayer {
    public var currentTime: TimeInterval { return self.currentTimeObserve! }
    public var totalTime: TimeInterval { return self.totalTimeObserve! }
    public var videoSize: CGSize { return self.videoSizeObserve! }
    public var originalURL: NSURL? { return self._originalURL }
    public var playURL: NSURL? { return self._playURL }
    public var isPlaying: Bool { return self.playing }
    public var isUserPause: Bool { return self.userPause }
    public var isOnlineSource: Bool { return self.localed }
    public var isReplay: Bool { return self.replay }
    public var loadedProgress: Float {
        if self.isOnlineSource == false {
            return 1.0
        }
        if self.totalTime <= 0 {
            return 0
        }
        return Float(min(self.loadedTimeObserve! / self.totalTime, 1))
    }
    
    public var isLiveStreaming: Bool {
        if let videoURL = self._originalURL {
            return Common.Function.videoAesset(videoURL) == .HLS
        } else {
            return false
        }
    }
    
    public func kj_play() {
        self.userPause = false
        self.playerStatus = .beginPlay
    }
    
    public func kj_replay() {
        self.replay = true
        self.userPause = false
        let time = BridgeMethod.skipTime(self)
        self.kj_appointTime(time)
    }
    
    public func kj_pause() {
        self.userPause = true
        self.playerStatus = .paused(user: true)
    }
    
    public func kj_stop() {
        self.userPause = false
        if let function = self.delegate?.kj_player(_:stopped:) {
            DispatchQueue.main.async {
                function(self, self.currentTime)
            }
        }
    }
    
    public func kj_appointTime(_ time: TimeInterval) {
        self.currentTimeObserve = time
    }
}
