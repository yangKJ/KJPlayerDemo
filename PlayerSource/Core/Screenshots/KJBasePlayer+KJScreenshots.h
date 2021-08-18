//
//  KJBasePlayer+KJScreenshots.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo
//  视频截屏相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJBasePlayer (KJScreenshots)

/// 获取当前截屏
@property (nonatomic,copy,readonly) void (^kVideoTimeScreenshots)(void(^)(UIImage * image));
/// 子线程获取封面图，图片会存储在磁盘
@property (nonatomic,copy,readonly) void(^kVideoPlaceholderImage)(void(^)(UIImage * image), NSURL *, NSTimeInterval);

@end

NS_ASSUME_NONNULL_END
