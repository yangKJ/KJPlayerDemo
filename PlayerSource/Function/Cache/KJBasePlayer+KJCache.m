//
//  KJBasePlayer+KJCache.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJCache.h"
#import "KJCacheManager.h"
#import "KJLogManager.h"

@interface KJBasePlayer ()
/// 错误信息
@property (nonatomic, strong) NSError * playError;
@property (nonatomic, assign) BOOL locality;

@end

@implementation KJBasePlayer (KJCache)

- (NSURL *)kj_cacheIMP:(NSURL *)videoURL{
    
    self.locality = [self kj_judgeHaveCacheWithVideoURL:&videoURL];
    
    return videoURL;
}

#pragma mark - public method

/// 判断是否为本地缓存视频，如果是则修改为指定链接地址
- (BOOL)kj_judgeHaveCacheWithVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL{
    if ([KJCacheManager kj_haveCacheURL:videoURL]) {
        self.playError = [KJLogManager kj_errorSummarizing:KJPlayerCustomCodeCachedComplete];
        return YES;
    }
    return NO;
}

@end
