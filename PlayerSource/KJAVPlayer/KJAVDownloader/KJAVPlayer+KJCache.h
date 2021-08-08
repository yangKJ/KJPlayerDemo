//
//  KJAVPlayer+KJCache.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  边播边缓存分支，暂时只支持文件类型，流媒体不支持

#import "KJAVPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJAVPlayer (KJCache)
/// 使用边播边缓存，与 videoURL 互斥 
@property (nonatomic,copy,readonly) BOOL (^kVideoCanCacheURL)(NSURL *videoURL, BOOL cache);

@end

NS_ASSUME_NONNULL_END
