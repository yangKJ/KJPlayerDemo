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

NS_ASSUME_NONNULL_BEGIN
// 弱引用
#define PLAYER_WEAKSELF __weak __typeof(&*self) weakself = self
// 屏幕尺寸
#define PLAYER_SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define PLAYER_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
// 颜色
#define PLAYER_UIColorFromHEXA(hex,a) [UIColor colorWithRed:((hex&0xFF0000)>>16)/255.0f green:((hex&0xFF00)>>8)/255.0f blue:(hex&0xFF)/255.0f alpha:a]
// 公共ivar
#define PLAYER_COMMON_PROPERTY \
@synthesize delegate = _delegate;\
@synthesize useCacheFunction = _useCacheFunction;\
@synthesize roregroundResume = _roregroundResume;\
@synthesize backgroundPause = _backgroundPause;\
@synthesize playerView = _playerView;\
@synthesize videoURL = _videoURL;\
@synthesize speed = _speed;\
@synthesize volume = _volume;\
@synthesize muted = _muted;\
@synthesize cacheTime = _cacheTime;\
@synthesize seekTime = _seekTime;\
@synthesize currentTime = _currentTime;\
@synthesize errorCode = _errorCode;\
@synthesize localityData = _localityData;\
@synthesize background = _background;\
@synthesize timeSpace = _timeSpace;\
@synthesize kPlayerTimeImage = _kPlayerTimeImage;\
@synthesize placeholder = _placeholder;\
@synthesize videoGravity = _videoGravity;\
@synthesize requestHeader = _requestHeader;\
@synthesize autoPlay = _autoPlay;\
@synthesize userPause = _userPause;\
@synthesize isPlaying = _isPlaying;\
@synthesize kVideoSize = _kVideoSize;\
@synthesize kVideoTotalTime = _kVideoTotalTime;\
@synthesize kVideoURLFromat = _kVideoURLFromat;\
@synthesize kVideoTryLookTime = _kVideoTryLookTime;\
@synthesize kVideoAdvanceAndReverse = _kVideoAdvanceAndReverse;\

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
/// 几种错误的code
typedef NS_ENUM(NSInteger, KJPlayerErrorCode) {
    KJPlayerErrorCodeNormal = 0, /// 正常播放
    KJPlayerErrorCodeOtherSituations = 1, /// 其他情况
    KJPlayerErrorCodeVideoURLFault = 100, /// 视频地址不正确
    KJPlayerErrorCodeNetworkOvertime = -1001, /// 请求超时：-1001
    KJPlayerErrorCodeServerNotFound  = -1003, /// 找不到服务器：-1003
    KJPlayerErrorCodeServerInternalError = -1004, /// 服务器内部错误：-1004
    KJPlayerErrorCodeNetworkInterruption = -1005, /// 网络中断：-1005
    KJPlayerErrorCodeNetworkNoConnection = -1009, /// 无网络连接：-1009
};
/// 缓存状态
typedef NS_ENUM(NSInteger, KJPlayerLoadState) {
    KJPlayerLoadStateNone = 0,/// 没有缓存
    KJPlayerLoadStateLoading, /// 缓存数据中
    KJPlayerLoadStateComplete,/// 缓存结束
    KJPlayerLoadStateError,   /// 缓存失败
};
static NSString * const _Nonnull KJPlayerLoadStateStringMap[] = {
    [KJPlayerLoadStateNone]     = @"没有缓存",
    [KJPlayerLoadStateLoading]  = @"缓存数据中",
    [KJPlayerLoadStateComplete] = @"缓存结束",
    [KJPlayerLoadStateError]    = @"缓存失败",
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
    KJPlayerVideoGravityResizeAspect = 0,/// 最大边等比充满
    KJPlayerVideoGravityResizeAspectFill,/// 拉伸充满
    KJPlayerVideoGravityResizeOriginal,  /// 原始尺寸
};
/// 视频格式
typedef NS_ENUM(NSUInteger, KJPlayerVideoFromat) {
    KJPlayerVideoFromat_none, /// 未知格式
    KJPlayerVideoFromat_mp4,
    KJPlayerVideoFromat_wav,
    KJPlayerVideoFromat_avi,
    KJPlayerVideoFromat_m3u8,
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
    if ([fromat isEqualToString:@"mp4"] || [fromat isEqualToString:@"MP4"]) {
        return KJPlayerVideoFromat_mp4;
    }else if ([fromat isEqualToString:@"wav"] || [fromat isEqualToString:@"WAV"]) {
        return KJPlayerVideoFromat_wav;
    }else if ([fromat isEqualToString:@"avi"] || [fromat isEqualToString:@"AVI"]) {
        return KJPlayerVideoFromat_avi;
    }else if ([fromat isEqualToString:@"m3u8"]) {
        return KJPlayerVideoFromat_m3u8;
    }else{
        return KJPlayerVideoFromat_none;
    }
}
// 根据链接获取格式
NS_INLINE KJPlayerVideoFromat kPlayerFromat(NSURL *url){
    if (url == nil) return KJPlayerVideoFromat_none;
    NSArray *array = [url.path componentsSeparatedByString:@"."];
    if (array.count == 0) {
        return KJPlayerVideoFromat_none;
    }else{
        return kPlayerVideoURLFromat(array.lastObject);
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
    return kPlayerMD5(url.resourceSpecifier?:url.absoluteString);
}
// 得到完整的沙盒路径
NS_INLINE NSString * kPlayerIntactSandboxPath(NSString *videoName){
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).lastObject;
    return [document stringByAppendingPathComponent:videoName];
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

#endif /* KJPlayerType_h */

NS_ASSUME_NONNULL_END
