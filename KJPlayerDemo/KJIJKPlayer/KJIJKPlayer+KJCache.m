//
//  KJIJKPlayer+KJCache.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/3/1.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJIJKPlayer+KJCache.h"
#if __has_include(<IJKMediaFramework/IJKMediaFramework.h>)
#import <IJKMediaFramework/IJKMediaFramework.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface KJIJKPlayer ()
PLAYER_CACHE_COMMON_EXTENSION_PROPERTY

@end
@implementation KJIJKPlayer (KJCache)
/* 判断当前资源文件是否有缓存，修改为指定链接地址 */
- (void)kj_judgeHaveCacheWithVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL{
    self.locality = NO;
    KJCacheManager.kJudgeHaveCacheURL(^(BOOL locality) {
        self.locality = locality;
        if (locality) {
            self.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeCachedComplete];
        }
    }, videoURL);
}

@end
#pragma clang diagnostic pop
#endif
