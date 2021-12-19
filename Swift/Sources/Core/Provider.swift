//
//  Provider.swift
//  KJPlayer
//
//  Created by abas on 2021/12/16.
//

import Foundation

@objc public class Provider: NSObject {
    
    /// Video link
    internal var videoURL: String? = ""
    /// Video request header
    internal var requestHeader: [String: Any]? = nil
    
    /// Audio link
    internal var audioURL: String? = ""
    
    @objc var title: String = ""
    /// Time space
    @objc var timeSpace: Double = 1.0
    /// How many seconds can the buffer be played before it can be played?
    /// 缓冲达到该目标之后才能自动播放
    @objc var cacheTime: Double = 0.0
    /// Whether to enable only fast forward to the cached position
    /// 是否开启只能快进到缓冲位置
    @objc var openAdvanceCache: Bool = false
    
    private override init() { }
    
    @objc public init(videoURL: String?, requestHeader: [String: Any]? = nil) {
        self.videoURL = videoURL
        self.requestHeader = requestHeader
    }
    
    @objc public init(audioURL: String?) {
        self.audioURL = audioURL
    }
}
