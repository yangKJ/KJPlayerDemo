//
//  KJBasePlayer+KJCache.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo
//  视频缓存相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KJPlayerCacheDelegate;
/// 视频缓存相关
@interface KJBasePlayer (KJCache)

/// 视频缓存协议
@property (nonatomic, weak) id<KJPlayerCacheDelegate> cacheDelegate;
/// 本地资源
@property (nonatomic, assign, readonly) BOOL locality;
/// 缓存功能
@property (nonatomic, assign, readonly) BOOL cache;

@end

/// 视频缓存相关协议
@protocol KJPlayerCacheDelegate <NSObject>

@optional;

/// 获取是否需要开启缓存功能
/// @param player 播放器内核
- (BOOL)kj_cacheWithPlayer:(__kindof KJBasePlayer *)player;

/// 当前播放视频是否拥有缓存
/// @param player 播放器内核
/// @param haveCache 是否拥有缓存
/// @param cacheVideoURL 缓存视频链接地址
- (void)kj_cacheWithPlayer:(__kindof KJBasePlayer *)player
                 haveCache:(BOOL)haveCache
             cacheVideoURL:(NSURL *)cacheVideoURL;

/// 当前视频缓存状态
/// @param player 播放器内核
/// @param cacheSuccess 是否缓存成功
- (void)kj_cacheWithPlayer:(__kindof KJBasePlayer *)player
              cacheSuccess:(BOOL)cacheSuccess;

@end

NS_ASSUME_NONNULL_END
