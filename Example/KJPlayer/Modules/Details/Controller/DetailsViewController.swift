//
//  DetailsViewController.swift
//  KJPlayer_Example
//
//  Created by 77。 on 2021/11/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import KJPlayer
import SnapKit

class DetailsViewController: UIViewController {
    
    public var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.setupInit()
        self.setupUI()
    }
    
    private func setupInit() {
        self.title = self.name
    }
    
    private func setupUI() {
        self.view.addSubview(self.backview)
        self.backview.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(64)
            make.left.right.equalTo(self.view)
            make.height.equalTo(self.backview.snp.width).multipliedBy(1)
        }
    }
    
    private lazy var backview: KJBasePlayerView = {
        let backview = KJBasePlayerView()
        backview.backgroundColor = UIColor.green
        backview.delegate = self
        backview.gestureType = .all
        backview.autoRotate = false
        backview.image = UIImage.init(named: "8")
        backview.layer.masksToBounds = true
        backview.hintTextLayer.kj_setHintFont(UIFont.systemFont(ofSize: 13),
                                              textColor: UIColor.green,
                                              background: UIColor.green.withAlphaComponent(0.3),
                                              maxWidth: 200)
        return backview
    }()
    
    private lazy var player: KJAVPlayer = {
        let player = KJAVPlayer()
        player.delegate = self
        player.skipDelegate = self
        player.playerView = self.backview
        player.placeholder = self.backview.image!
        player.timeSpace = 2
        return player
    }()
    
    public var videoUrl: String = "" {
        didSet {
            self.player.videoURL = NSURL.init(string: videoUrl)! as URL
            self.backview.loadingLayer.kj_startAnimation()
        }
    }
    
}

// MARK: KJPlayerDelegate
extension DetailsViewController: KJPlayerDelegate {
    
    /// 播放器状态响应
    /// - Parameters:
    ///   - player: 内核
    ///   - state: 状态
    func kj_player(_ player: KJBasePlayer, state: KJPlayerState) {
        switch state {
        case .buffering:
            self.backview.loadingLayer.kj_startAnimation()
            break
        case .preparePlay, .playing:
            self.backview.loadingLayer.kj_stopAnimation()
            break
        case .pausing:
            self.backview.loadingLayer.kj_startAnimation()
            self.backview.hintTextLayer.kj_displayHintText("暂停ing",
                                                           time: 5,
                                                           position: KJPlayerHintPositionBottom)
            break
        case .playFinished:
            player.kj_replay()
            break
        case .stopped, .failed:
            break
        @unknown default: break
        }
    }
    
    /// 当前播放时间响应
    /// - Parameters:
    ///   - player: 内核
    ///   - currentTime: 当前时间
    func kj_player(_ player: KJBasePlayer, currentTime: TimeInterval) {
        print("🎷🎷:total:\(player.totalTime),",
              "current:\(String(format:"%.5f", currentTime))")
    }
    
}

// MARK: KJPlayerBaseViewDelegate
extension DetailsViewController: KJPlayerBaseViewDelegate {
    
    /// 单双击手势响应
    /// - Parameters:
    ///   - view: 播放器载体控件
    ///   - tap: 是否单击
    func kj_basePlayerView(_ view: KJPlayerView, isSingleTap tap: Bool) {
        guard tap else {
            if self.player.isPlaying {
                self.player.kj_pause()
            } else {
                self.player.kj_resume()
            }
            return
        }
        if (view.displayOperation) {
            view.kj_hiddenOperationView()
        } else {
            view.kj_displayOperationView()
        }
    }
    
    /// 长按手势响应
    /// - Parameters:
    ///   - view: 播放器载体控件
    ///   - longPress: 长按手势
    func kj_basePlayerView(_ view: KJPlayerView, longPress: UILongPressGestureRecognizer) {
        let backView = view as! KJBasePlayerView
        switch longPress.state {
        case .began:
            self.player.speed = 2
            backView.hintTextLayer.kj_displayHintText("长按快进播放中...",
                                                      time: 0,
                                                      position: KJPlayerHintPositionTop)
            break
        case .ended, .cancelled, .failed:
            self.player.speed = 1
            backView.hintTextLayer.kj_hideHintText()
            break
        case .possible, .changed:
            break
        @unknown default: break
        }
    }
    
    /// 音量手势响应
    /// - Parameters:
    ///   - view: 播放器载体控件
    ///   - value: 音量值
    /// - Returns: 是否替换默认音量控件
    func kj_basePlayerView(_ view: KJPlayerView, volumeValue value: Float) -> Bool {
        self.player.volume = value
        return false
    }
    
    /// 亮度手势响应
    /// - Parameters:
    ///   - view: 播放器载体控件
    ///   - value: 亮度值
    /// - Returns: 是否替换默认亮度控件
    func kj_basePlayerView(_ view: KJPlayerView, brightnessValue value: Float) -> Bool {
        return false
    }
    
    /// 进度手势响应
    /// - Parameters:
    ///   - view: 播放器载体控件
    ///   - progress: 当前进度
    ///   - end: 是否结束
    /// - Returns: 当前时间和总时间、是否替换默认进度控件的结构体
    func kj_basePlayerView(_ view: KJPlayerView, progress: Float, end: Bool) -> KJPlayerTimeUnion {
        if end {
            let time = player.currentTime + Double(progress) * player.totalTime
            self.player.kj_appointTime(time)
        }
        return KJPlayerTimeUnion(currentTime: player.currentTime,
                                 totalTime: player.totalTime,
                                 isReplace: false)
    }
    
    /// 锁屏响应
    /// - Parameters:
    ///   - view: 播放器载体控件
    ///   - locked: 是否锁屏
    func kj_basePlayerView(_ view: KJPlayerView, locked: Bool) {
        
    }
    
    /// 屏幕状态响应
    /// - Parameters:
    ///   - view: 播放器载体控件
    ///   - screenState: 当前屏幕状态
    func kj_basePlayerView(_ view: KJPlayerView, screenState: KJPlayerVideoScreenState) {
        
    }
    
}

// MARK: KJPlayerSkipDelegate
extension DetailsViewController: KJPlayerSkipDelegate {
    
    /// 跳过片头
    /// - Parameter player: 内核
    /// - Returns: 需要跳过的时间
    func kj_skipHeadTime(with player: KJBasePlayer) -> TimeInterval {
        return 18
    }
    
    /// 跳过片头或片尾响应
    /// - Parameters:
    ///   - player: 内核
    ///   - currentTime: 当前时间
    ///   - totalTime: 总事件
    ///   - skipState: 跳过类型
    func kj_skipTime(with player: KJBasePlayer,
                     currentTime: TimeInterval,
                     totalTime: TimeInterval,
                     skipState: KJPlayerVideoSkipState) {
        switch skipState {
        case .head:
            self.backview.hintTextLayer.kj_displayHintText("跳过片头，自动播放",
                                                           time: 5,
                                                           position: KJPlayerHintPositionBottom)
            break
        case .foot: break
        @unknown default: break
        }
    }
    
}