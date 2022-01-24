//
//  Cache.swift
//  KJPlayer
//
//  Created by abas on 2021/12/19.
//

import Foundation

/// 视频缓存协议
@objc public protocol KJPlayerCacheDelegate {
    
    /// Get whether the cache function needs to be turned on
    @objc(kj_cacheWithPlayer:)
    optional func kj_cache(with player: KJBasePlayer) -> Bool
    
    /// The current resource cache is successful
    @objc(kj_cacheSuccessedWithPlayer:)
    optional func kj_cacheSuccessed(with player: KJBasePlayer)
    
    /// Whether the currently playing video has a cache
    /// - Parameters:
    ///   - player: Player Kernel
    ///   - haveCached: Whether there is a cache
    ///   - cacheURL: Cache link, can be played directly
    @objc(kj_cacheBeginPlayHaveCachedWithPlayer:haveCached:cacheURL:)
    optional func kj_cacheBeginPlayHaveCached(with player: KJBasePlayer, haveCached: Bool, cacheURL: NSURL)
}

extension KJBasePlayer {
    
    /// Video caching protocol
    @objc weak var cacheDelegate: KJPlayerCacheDelegate? {
        get { objc_getAssociatedObject(self, &Keys.cacheDelegate) as? KJPlayerCacheDelegate }
        set {
            objc_setAssociatedObject(self, &Keys.cacheDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN)
            guard let function = newValue?.kj_cache(with:) else { return }
            self.openCache = function(self)
        }
    }
    
    /// Whether there is a cache
    @objc public var haveCached: Bool {
        get {
            if let _ = self.isCached {
                return self.isCached!
            } else {
                return false
            }
        }
    }
    
    /// Whether to enable the cache function
    @objc public var cache: Bool {
        get {
            if let _ = self.openCache {
                return self.openCache!
            } else {
                return false
            }
        }
    }
}

extension KJBasePlayer {
    internal struct Cache { }
    private struct Keys {
        static var cacheDelegate = "cacheDelegateKey"
        static var isCached = "haveCachedKey"
        static var openCache = "openCacheKey"
    }
    
    private var isCached: Bool? {
        get { objc_getAssociatedObject(self, &Keys.isCached) as? Bool }
        set { objc_setAssociatedObject(self, &Keys.isCached, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    private var openCache: Bool? {
        get { objc_getAssociatedObject(self, &Keys.openCache) as? Bool }
        set { objc_setAssociatedObject(self, &Keys.openCache, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}
