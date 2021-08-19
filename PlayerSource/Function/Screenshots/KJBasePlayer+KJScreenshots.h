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

/// 获取当前时间截屏
/// @param screenshots 截屏回调
- (void)kj_currentTimeScreenshots:(void(^)(UIImage * image))screenshots;

/// 获取指定时间截屏
/// @param time 指定时间
/// @param screenshots 截屏回调
- (void)kj_appointTime:(NSTimeInterval)time screenshots:(void(^)(UIImage * image))screenshots;

/// 子线程获取封面图，图片会存储在磁盘
/// @param time 时间节点
/// @param url 视频地址
/// @param placeholder 封面图
- (void)kj_placeholderImageWithTime:(NSTimeInterval)time
                           videoURL:(NSString *)url
                        placeholder:(void(^)(UIImage * image))placeholder;

#pragma mark - 截图封面缓存板块

/// 存入视频封面图
/// @param image 封面图
/// @param videoURL 链接
+ (void)kj_saveVideoCoverImage:(UIImage *)image videoURL:(NSURL *)videoURL;

/// 读取视频封面图
/// @param url 链接
+ (UIImage *)kj_getVideoCoverImageWithURL:(NSURL *)url;

/// 清除视频封面图
/// @param url 链接
+ (void)kj_clearVideoCoverImageWithURL:(NSURL *)url;

/// 清除全部封面缓存
+ (void)kj_clearAllVideoCoverImage;

@end

NS_ASSUME_NONNULL_END
