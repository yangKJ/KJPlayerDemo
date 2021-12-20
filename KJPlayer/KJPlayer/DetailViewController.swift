//
//  DetailViewController.swift
//  KJPlayer
//
//  Created by abas on 2021/12/17.
//

import UIKit

class DetailViewController: UIViewController {

    lazy var playButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("play", for: .normal)
        button.setTitle("paue", for: .selected)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.black, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        button.isSelected = true
        return button
    }()
    
    lazy var pipButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("pip", for: .normal)
        button.setTitle("close", for: .selected)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.black, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(pipAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()
    
    lazy var playerView: KJPlayerView = {
        let width = self.view.frame.width - 40
        let rect = CGRect(x: 20, y: 100, width: width, height: width / 2)
        let view = KJPlayerView.init(frame: rect)
        view.background = UIColor.red.cgColor
        view.backgroundColor = UIColor.green
        return view
    }()
    
    lazy var player: KJAVPlayer = {
        let provider = Provider.init(videoURL: self.title)
        let player = KJAVPlayer.init(withPlayerView: playerView)
        player.delegate = self
        player.recordDelegate = self
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
        self.view.backgroundColor = UIColor.white
        self.playButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        self.playButton.center = self.view.center
        self.pipButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        self.pipButton.center = CGPoint(x: self.playButton.center.x, y: self.playButton.center.y + 70)
        self.view.addSubview(self.playerView)
    }
}

// MARK: - actions
extension DetailViewController {
    
    @objc func buttonAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            self.player.kj_play()
        } else {
            self.player.kj_pause()
        }
    }
    
    @objc func pipAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            self.player.openPip()
        } else {
            self.player.closePip()
        }
    }
}

extension DetailViewController: KJPlayerDelegate {
    
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

extension DetailViewController: KJPlayerRecordDelegate {
    
    func kj_recordTime(with player: KJBasePlayer) -> Bool {
        return true
    }
    
    func kj_recordTime(with player: KJBasePlayer, lastTime: TimeInterval) {
        print("----lastTime:\(lastTime)")
    }
}
