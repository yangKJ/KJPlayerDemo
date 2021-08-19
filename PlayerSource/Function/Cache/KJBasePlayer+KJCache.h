//
//  KJBasePlayer+KJCache.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo
//  视频缓存相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJBasePlayer (KJCache)

/// 判断是否为本地缓存视频，如果是则修改为指定链接地址
- (BOOL)kj_judgeHaveCacheWithVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL;

@end

NS_ASSUME_NONNULL_END
