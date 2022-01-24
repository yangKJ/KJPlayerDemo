//
//  KJAVPlayer.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import Foundation
import AVFoundation
import UIKit

@objc public class KJAVPlayer: KJBasePlayer {
    private struct Keys {
        static let status = "status"
        static let videoSize = "presentationSize"
        static let loadedTime = "loadedTimeRanges"
    }
    
    private var timeObserver: Any? = nil
    private var videoPlayer: AVPlayer? {
        didSet {
            if let videoPlayer = videoPlayer {
                videoPlayer.usesExternalPlaybackWhileExternalScreenIsActive = true
            }
        }
    }
    
    internal var playerLayer: AVPlayerLayer? {
        didSet {
            guard let playerLayer = playerLayer, let view = playerView else {
                return
            }
            DispatchQueue.main.async {
                playerLayer.frame = self.getVideoFrame()
                playerLayer.backgroundColor = view.background
                switch view.videoGravity {
                case .resizeAspect:
                    playerLayer.videoGravity = .resizeAspect
                    break
                case .resizeAspectFill:
                    playerLayer.videoGravity = .resizeAspectFill
                    break
                case .resizeOriginal:
                    playerLayer.videoGravity = .resize
                    break
                }
                if playerLayer.superlayer == nil {
                    view.layer.addSublayer(playerLayer)
                }
            }
        }
    }
    
    /// Media Resource Management Object
    private var playerItem: AVPlayerItem? {
        didSet {
            if let item = playerItem {
                item.addObserver(self, forKeyPath: KJAVPlayer.Keys.status, options: .new, context: nil)
                item.addObserver(self, forKeyPath: KJAVPlayer.Keys.videoSize, options: .new, context: nil)
                item.addObserver(self, forKeyPath: KJAVPlayer.Keys.loadedTime, options: .new, context: nil)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(avplayerItemDidPlayToEndTime(_:)),
                                                       name: .AVPlayerItemDidPlayToEndTime,
                                                       object: item)
            }
        }
    }
    
    deinit {
        self.resetVideoPlayer()
    }
    
    // MARK: - kvo
    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        guard let item = self.playerItem else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        // Monitor player status
        if keyPath == KJAVPlayer.Keys.status {
            if item.status == .readyToPlay {
                self.totalTimeObserve = CMTimeGetSeconds(item.duration)
                self.playerStatus = .beginPlay
            } else {
                self.playerStatus = .failed(error: item.error as NSError?)
            }
        }
        // Monitor video size
        else if keyPath == KJAVPlayer.Keys.videoSize {
            self.videoSizeObserve = item.presentationSize
        }
        // Monitor video loaded time
        else if keyPath == KJAVPlayer.Keys.loadedTime {
            guard let ranges = item.loadedTimeRanges.first?.timeRangeValue else {
                return
            }
            let start = CMTimeGetSeconds(ranges.start)
            let duration = CMTimeGetSeconds(ranges.duration)
            self.loadedTimeObserve = start + duration
        }
    }
    
    /// Video play finished
    @objc func avplayerItemDidPlayToEndTime(_ notification: Notification) {
        self.playerStatus = .playFinished(skip: false)
    }
    
    // MARK: - override method
    public override var muted: Bool {
        didSet {
            if let videoPlayer = videoPlayer {
                videoPlayer.isMuted = muted
            }
        }
    }
    
    public override var speed: Float {
        didSet {
            guard let videoPlayer = videoPlayer, fabsf(videoPlayer.rate) > 0.00001 else {
                return
            }
            let speed = max(min(speed, 2), 0)
            videoPlayer.rate = speed
        }
    }
    
    public override var volume: Float {
        didSet {
            guard let videoPlayer = videoPlayer else {
                return
            }
            let volume = max(min(volume, 1), 0)
            videoPlayer.volume = volume
        }
    }
    
    public override var provider: Provider? {
        didSet {
            guard let provider = provider else {
                return
            }
            self.playerPreparing(provider)
        }
    }
    
    override var playerStatus: PlayerStatus? {
        didSet {
            guard let status = playerStatus else { return }
            super.playerStatus = status
            switch status {
            case .prepare(_):
                videoPlayer?.pause()
                break
            case .beginPlay:
                self.beginPlay()
                break
            case .playing(let time):
                self.playing(time: time)
                break
            case .paused(let user):
                self.pausedPlay(user: user)
                break
            default: break
            }
        }
    }
    
    override func runingCommonTimer(sender: Timer?) {
        super.runingCommonTimer(sender: sender)
        guard let player = videoPlayer,
              BridgeMethod.playing(self, time: self.currentTime).playing else {
                  return
              }
        if isPlaying == false, autoPlay {
            self.configPlayer(player)
        }
    }
}

// MARK: - private player methods
extension KJAVPlayer {
    
    private func resetVideoPlayer() {
        videoPlayer?.pause()
        videoPlayer?.replaceCurrentItem(with: nil)
        if let item = playerItem {
            item.removeObserver(self, forKeyPath: KJAVPlayer.Keys.status, context: nil)
            item.removeObserver(self, forKeyPath: KJAVPlayer.Keys.loadedTime, context: nil)
            item.removeObserver(self, forKeyPath: KJAVPlayer.Keys.videoSize, context: nil)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: item)
            playerItem = nil
        }
        if videoPlayer != nil && timeObserver != nil {
            videoPlayer!.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
    }
    
    private func playerPreparing(_ provider: Provider) {
        self.playerStatus = .prepare(provider: provider)
        self.setupVideoPlayer(self.playURL)
        let time = BridgeMethod.begin(self).preparing()
        if time > 0 {
            self.seekTime(time)
        }
    }
    
    private func setupVideoPlayer(_ videoURL: NSURL?) {
        guard let videoURL = videoURL, let provider = provider else { return }
        let asset = AVURLAsset.init(url: videoURL as URL, options: provider.requestHeader)
        self.playerItem = AVPlayerItem.init(asset: asset)
        //self.playerItem = AVPlayerItem.init(url: videoURL as URL)
        if videoPlayer == nil {
            self.videoPlayer = AVPlayer.init(playerItem: self.playerItem)
        } else {
            self.videoPlayer?.replaceCurrentItem(with: self.playerItem)
        }
        if let playerLayer = playerLayer {
            playerLayer.player = videoPlayer
        } else {
            playerLayer = AVPlayerLayer.init(player: videoPlayer)
        }
        self.setupTimeObserver()
    }
    
    /// Monitor play time change
    private func setupTimeObserver() {
        guard let videoPlayer = videoPlayer, let provider = provider else {
            return
        }
        if timeObserver != nil {
            videoPlayer.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
        let ctime = CMTime(seconds: provider.timeSpace, preferredTimescale: 1)
        timeObserver = videoPlayer.addPeriodicTimeObserver(forInterval: ctime,
                                                           queue: DispatchQueue.main) { [weak self] time in
            guard let `self` = self, self.isLiveStreaming == false else { return }
            let sec = CMTimeGetSeconds(time)
            self.playerStatus = .playing(time: sec)
        }
    }
    
    private func configPlayer(_ player: AVPlayer) {
        player.play()
        player.volume = max(min(volume, 1), 0)
        player.rate = max(min(speed, 2), 0)
        player.isMuted = muted
    }
    
    private func beginPlay() {
        guard let player = videoPlayer else { return }
        let canPlay = !BridgeMethod.playing(self, time: self.currentTime).playing
        if canPlay {
            self.configPlayer(player)
        } else {
            player.pause()
        }
    }
    
    private func playing(time: TimeInterval) {
        if BridgeMethod.playing(self, time: time).playing {
            self.playerStatus = .paused(user: false)
            return
        }
    }
    
    private func pausedPlay(user: Bool) {
        guard let player = videoPlayer else { return }
        player.pause()
    }
    
    private func seekTime(_ time: TimeInterval) {
        guard let videoPlayer = videoPlayer,
              !BridgeMethod.playing(self, time: time).playing else { return }
        let ctime = CMTime(seconds: time, preferredTimescale: 1)
        videoPlayer.seek(to: ctime)
    }
}

// MARK: - KJPlayer Protocol
extension KJAVPlayer {
    
    public override func kj_replay() {
        super.kj_replay()
        self.playerStatus = .beginPlay
    }
    
    public override func kj_stop() {
        super.kj_stop()
        self.resetVideoPlayer()
    }
    
    public override func kj_appointTime(_ time: TimeInterval) {
        super.kj_appointTime(time)
        self.seekTime(time)
    }
}
