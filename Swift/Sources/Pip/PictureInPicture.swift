//
//  PictureInPicture.swift
//  KJPlayer
//
//  Created by abas on 2021/12/16.
//

import Foundation
import AVFoundation
import AVKit

/// 开启画中画协议，该功能只有`AVPlayer`内核才具有
/// Open the Picture-in-Picture protocol, this function is only available in the `AVPlayer` kernel
@objc public protocol KJPlayerPipDelegate {
    
    /// Open pip
    @objc(kj_pipDidOpen:viewController:)
    func kj_pipDidOpen(with player: KJAVPlayer, viewController: AVPictureInPictureController)
    
    /// Stop pip
    @objc(kj_pipDidStop:viewController:)
    func kj_pipDidStop(with player: KJAVPlayer, viewController: AVPictureInPictureController)
    
    @objc(kj_pipFailed:failed:viewController:)
    optional func kj_pipFailed(with player: KJAVPlayer, failed: NSError, viewController: AVPictureInPictureController)
  
    @objc(kj_pipWillOpen:viewController:)
    optional func kj_pipWillOpen(with player: KJAVPlayer, viewController: AVPictureInPictureController)
    
    @objc(kj_pipWillStop:viewController:)
    optional func kj_pipWillStop(with player: KJAVPlayer, viewController: AVPictureInPictureController)
}

extension KJAVPlayer {
    
    @objc weak var pipDelegate: KJPlayerPipDelegate? {
        get { objc_getAssociatedObject(self, &Keys.pipDelegate) as? KJPlayerPipDelegate }
        set { objc_setAssociatedObject(self, &Keys.pipDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    /// Open pip
    @objc public func openPip() {
        if let playerLayer = playerLayer, self.pipViewController == nil {
            self.setupAVPictureInPictureController(playerLayer)
        }
        self.pipViewController?.startPictureInPicture()
    }
    
    @objc public func closePip() {
        if self.pipViewController != nil {
            pipViewController?.stopPictureInPicture()
            self.pipViewController = nil
        }
    }
}

extension KJAVPlayer {
    
    private struct Keys {
        static var pipDelegate = "pipDelegateKey"
        static var pipViewController = "pipViewControllerKey"
    }
    private var pipViewController: AVPictureInPictureController? {
        get { objc_getAssociatedObject(self, &Keys.pipViewController) as? AVPictureInPictureController }
        set { objc_setAssociatedObject(self, &Keys.pipViewController, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    /// Configure picture-in-picture view controller
    /// - Parameter layer: video display layer
    private func setupAVPictureInPictureController(_ layer: AVPlayerLayer) {
        if AVPictureInPictureController.isPictureInPictureSupported() {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error {
                print(error)
            }
            self.pipViewController?.delegate = nil
            self.pipViewController = AVPictureInPictureController(playerLayer: layer)
            self.pipViewController?.delegate = self
        }
    }
}

extension KJAVPlayer: AVPictureInPictureControllerDelegate {
    
    /// 即将开启画中画
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if let function = self.pipDelegate?.kj_pipWillOpen(with:viewController:) {
            function(self, pictureInPictureController)
        }
    }
    
    /// 已经开启画中画
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if let function = self.pipDelegate?.kj_pipDidOpen(with:viewController:) {
            function(self, pictureInPictureController)
        }
    }
    
    /// 开启画中画失败
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        if let function = self.pipDelegate?.kj_pipFailed(with:failed:viewController:) {
            function(self, error as NSError, pictureInPictureController)
        }
    }
    
    /// 即将关闭画中画
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if let function = self.pipDelegate?.kj_pipWillStop(with:viewController:) {
            function(self, pictureInPictureController)
        }
    }
    
    /// 已经关闭画中画
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if let function = self.pipDelegate?.kj_pipDidStop(with:viewController:) {
            function(self, pictureInPictureController)
        }
    }
    
    /// 关闭画中画且恢复播放界面
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        
    }
}
