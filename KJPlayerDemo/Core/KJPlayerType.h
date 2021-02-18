//
//  KJPlayerType.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/8.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  枚举文件夹和公共方法

#ifndef KJPlayerType_h
#define KJPlayerType_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import "DBPlayerDataInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
// 弱引用
#define PLAYER_WEAKSELF __weak __typeof(&*self) weakself = self
// 屏幕尺寸
#define PLAYER_SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define PLAYER_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
// 颜色
#define PLAYER_UIColorFromHEXA(hex,a) [UIColor colorWithRed:((hex&0xFF0000)>>16)/255.0f green:((hex&0xFF00)>>8)/255.0f blue:(hex&0xFF)/255.0f alpha:a]

/// 播放器的几种状态
typedef NS_ENUM(NSInteger, KJPlayerState) {
    KJPlayerStateFailed = 0,/// 播放错误
    KJPlayerStateBuffering, /// 加载中缓存数据
    KJPlayerStatePreparePlay,/// 可以播放（可以取消加载状态）
    KJPlayerStatePausing, /// 暂停中
    KJPlayerStatePlayFinished, /// 播放结束
    KJPlayerStateStopped, /// 停止
    KJPlayerStatePlaying, /// 播放中
};
/// 播放状态
static NSString * const _Nonnull KJPlayerStateStringMap[] = {
    [KJPlayerStateFailed]  = @"failed",
    [KJPlayerStateBuffering] = @"buffering",
    [KJPlayerStatePreparePlay] = @"preparePlay",
    [KJPlayerStatePausing] = @"pausing",
    [KJPlayerStatePlayFinished] = @"playFinished",
    [KJPlayerStateStopped] = @"stop",
    [KJPlayerStatePlaying] = @"playing",
};
/// 自定义错误情况
typedef NS_ENUM(NSInteger, KJPlayerCustomCode) {
    KJPlayerCustomCodeNormal = 0, /// 正常播放
    KJPlayerCustomCodeOtherSituations = 1,/// 其他情况
    KJPlayerCustomCodeCacheNone = 6,/// 没有缓存
    KJPlayerCustomCodeCachedComplete = 7,/// 缓存完成
    KJPlayerCustomCodeSaveDatabase = 8,/// 成功存入数据库
    KJPlayerCustomCodeFinishLoading = 96,/// 取消加载网络
    KJPlayerCustomCodeAVPlayerItemStatusUnknown = 97,/// playerItem状态未知
    KJPlayerCustomCodeAVPlayerItemStatusFailed = 98,/// playerItem状态出错
    KJPlayerCustomCodeVideoURLUnknownFormat = 99,/// 未知视频格式
    KJPlayerCustomCodeVideoURLFault = 100,/// 视频地址不正确
    KJPlayerCustomCodeWriteFileFailed = 101,/// 写入缓存文件错误
    KJPlayerCustomCodeReadCachedDataFailed = 102,/// 读取缓存数据错误
    KJPlayerCustomCodeSaveDatabaseFailed = 103,/// 存入数据库错误
};
/// 手势操作的类型
typedef NS_ENUM(NSUInteger, KJPlayerGestureType) {
    KJPlayerGestureTypeProgress = 0, /// 视频进度调节操作
    KJPlayerGestureTypeVoice    = 1, /// 声音调节操作
    KJPlayerGestureTypeLight    = 2, /// 屏幕亮度调节操作
    KJPlayerGestureTypeNone     = 3, /// 无任何操作
};
/// 播放类型
typedef NS_ENUM(NSUInteger, KJPlayerPlayType) {
    KJPlayerPlayTypeReplay = 0, /// 重复播放
    KJPlayerPlayTypeOrder  = 1, /// 顺序播放
    KJPlayerPlayTypeRandom = 2, /// 随机播放
    KJPlayerPlayTypeOnce   = 3, /// 仅播放一次
};
/// 手机方向
typedef NS_ENUM(NSUInteger, KJPlayerDeviceDirection) {
    KJPlayerDeviceDirectionCustom,/// 其他
    KJPlayerDeviceDirectionTop,   /// 上
    KJPlayerDeviceDirectionBottom,/// 下
    KJPlayerDeviceDirectionLeft,  /// 左
    KJPlayerDeviceDirectionRight, /// 右
};
/// 播放器充满类型
typedef NS_ENUM(NSUInteger, KJPlayerVideoGravity) {
    KJPlayerVideoGravityResizeAspect = 0,/// 最大边等比充满，按比例压缩
    KJPlayerVideoGravityResizeAspectFill,/// 原始尺寸，视频不会有黑边
    KJPlayerVideoGravityResizeOriginal,  /// 拉伸充满，视频会变形
};
/// 视频格式
typedef NS_ENUM(NSUInteger, KJPlayerVideoFromat) {
    KJPlayerVideoFromat_none, /// 未知格式
    KJPlayerVideoFromat_mp4,
    KJPlayerVideoFromat_wav,
    KJPlayerVideoFromat_avi,
    KJPlayerVideoFromat_m3u8,
};
/// 跳过播放
typedef NS_ENUM(NSUInteger, KJPlayerVideoSkipState) {
    KJPlayerVideoSkipStateHead, /// 跳过片头
    KJPlayerVideoSkipStateFoot, /// 跳过片尾
};
static NSString * const _Nonnull KJPlayerVideoFromatStringMap[] = {
    [KJPlayerVideoFromat_mp4]  = @".mp4",
    [KJPlayerVideoFromat_wav]  = @".wav",
    [KJPlayerVideoFromat_avi]  = @".avi",
    [KJPlayerVideoFromat_m3u8] = @".m3u8",
};
static NSString * const _Nonnull KJPlayerVideoFromatMimeStringMap[] = {
    [KJPlayerVideoFromat_mp4]  = @"video/mp4",
    [KJPlayerVideoFromat_wav]  = @"video/wav",
    [KJPlayerVideoFromat_avi]  = @"video/avi",
    [KJPlayerVideoFromat_m3u8] = @"video/m3u8",
};
NS_INLINE KJPlayerVideoFromat kPlayerVideoURLFromat(NSString * fromat){
    if ([fromat containsString:@"mp4"] || [fromat containsString:@"MP4"]) {
        return KJPlayerVideoFromat_mp4;
    }else if ([fromat containsString:@"wav"] || [fromat containsString:@"WAV"]) {
        return KJPlayerVideoFromat_wav;
    }else if ([fromat containsString:@"avi"] || [fromat containsString:@"AVI"]) {
        return KJPlayerVideoFromat_avi;
    }else if ([fromat containsString:@"m3u8"]) {
        return KJPlayerVideoFromat_m3u8;
    }else{
        return KJPlayerVideoFromat_none;
    }
}
// 根据链接获取格式
NS_INLINE KJPlayerVideoFromat kPlayerFromat(NSURL *url){
    if (url == nil) return KJPlayerVideoFromat_none;
    if (url.pathExtension.length) {
        return kPlayerVideoURLFromat(url.pathExtension);
    }
    NSArray * array = [url.path componentsSeparatedByString:@"."];
    if (array.count == 0) {
        return KJPlayerVideoFromat_none;
    }else{
        return kPlayerVideoURLFromat(array.lastObject);
    }
}
NS_INLINE void kGCD_player_async(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        dispatch_async(queue, block);
    }
}
NS_INLINE void kGCD_player_main(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        if ([[NSThread currentThread] isMainThread]) {
            dispatch_async(queue, block);
        }else{
            dispatch_sync(queue, block);
        }
    }
}
// MD5加密
NS_INLINE NSString * kPlayerMD5(NSString *string){
    const char *str = [string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (uint)strlen(str), digist);
    NSMutableString *outPutStr = [NSMutableString stringWithCapacity:10];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [outPutStr appendFormat:@"%02X", digist[i]];
    }
    return [outPutStr lowercaseString];
}
// 文件名
NS_INLINE NSString * kPlayerIntactName(NSURL *url){
    NSString *name = kPlayerMD5(url.resourceSpecifier?:url.absoluteString);
    return [@"video_" stringByAppendingString:name];
}
// 设置时间显示
NS_INLINE NSString * kPlayerConvertTime(CGFloat second){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    if (second / 3600 >= 1) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    }else{
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:second]];
}
// 获取当前的旋转状态
NS_INLINE CGAffineTransform kPlayerDeviceOrientation(void){
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    }else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}
// 寻找响应者
NS_INLINE __kindof UIResponder * kPlayerLookupResponder(Class clazz, UIView *view){
    __kindof UIResponder *_Nullable next = view.nextResponder;
    while (next != nil && [next isKindOfClass:clazz] == NO) {
        next = next.nextResponder;
    }
    return next;
}

#endif /* KJPlayerType_h */

NS_ASSUME_NONNULL_END
