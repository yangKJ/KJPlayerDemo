//
//  KJIJKPlayer+KJCache.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/3/1.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  边播边缓存分支

#import "KJIJKPlayer.h"

NS_ASSUME_NONNULL_BEGIN

#if __has_include(<IJKMediaFramework/IJKMediaFramework.h>)
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface KJIJKPlayer (KJCache)
/* 本地资源 */
@property (nonatomic,assign,readonly) BOOL locality;

/* 判断当前资源文件是否有缓存，修改为指定链接地址 */
- (void)kj_judgeHaveCacheWithVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL;

@end

#endif
NS_ASSUME_NONNULL_END
