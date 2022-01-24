//
//  AVPlayerViewController.swift
//  KJPlayerDemo_Example
//
//  Created by 77。 on 2021/12/23.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import KJPlayer

class AVPlayerViewController: BaseViewController {

    lazy var playerView: KJPlayerView = {
        let view = KJPlayerView.init(frame: .zero)
        view.background = UIColor.red.cgColor
        view.backgroundColor = UIColor.green
        view.image = UIImage.init(named: "bear")
        return view
    }()
    
    lazy var player: KJAVPlayer = {
        let videoURL = "https://mp4.vjshi.com/2017-11-21/7c2b143eeb27d9f2bf98c4ab03360cfe.mp4"
        let provider = Provider.init(videoURL: videoURL)
        let player = KJAVPlayer.init(withPlayerView: playerView)
        player.delegate = self
        player.provider = provider
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
        self.player.kj_play()
    }

    func setupUI() {
        self.view.addSubview(self.playerView)
        self.playerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalTo(self.view).inset(20)
            make.height.equalTo(self.playerView.snp.width).multipliedBy(0.5)
        }
    }
}

extension AVPlayerViewController: KJPlayerDelegate {
    
    func kj_player(_ player: KJBasePlayer, state: KJPlayerState) {
        print("----state:\(state.mapString)")
    }
    
    func kj_player(_ player: KJBasePlayer, current: TimeInterval) {
//        print("----current:\(current)")
    }
    
    func kj_player(_ player: KJBasePlayer, playFailed: NSError) {
        print("----playFailed:\(playFailed)")
    }
    
    func kj_player(_ player: KJBasePlayer, loadedTime: TimeInterval) {
        print("----loadedTime:\(loadedTime)")
    }
    
    func kj_player(_ player: KJBasePlayer, total: TimeInterval) {
        print("----total:\(total)")
    }
    
    func kj_player(_ player: KJBasePlayer, videoSize: CGSize) {
        print("----videoSize:\(videoSize)")
    }
    
    func kj_player(_ player: KJBasePlayer, playFinished: TimeInterval) {
        print("----playFinished:\(playFinished)")
        player.kj_replay()
    }
}
