//
//  KJAVPlayer+KJCache.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  边播边缓存分支

#import "KJAVPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJAVPlayer (KJCache)
/* 本地资源 */
@property (nonatomic,assign,readonly) BOOL locality;
/* 媒体数据 */
@property (nonatomic,strong) AVURLAsset *_Nullable asset;

/* 判断当前资源文件是否有缓存，修改为指定链接地址 */
- (void)kj_judgeHaveCacheWithVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL;
// 判断是否含有视频轨道
BOOL kPlayerHaveTracks(NSURL *videoURL, void(^assetblock)(AVURLAsset *), NSDictionary *requestHeader);

@end

NS_ASSUME_NONNULL_END
