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
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN
// 弱引用
#define PLAYER_WEAKSELF __weak __typeof(self) weakself = self
#define PLAYER_STRONGSELF __strong __typeof(self) strongself = weakself
// 窗口
#define PLAYER_KeyWindow \
({UIWindow *window;\
if (@available(iOS 13.0, *)) {\
window = [UIApplication sharedApplication].windows.firstObject;\
} else {\
window = [UIApplication sharedApplication].keyWindow;\
}\
window;})
// 屏幕尺寸
#define PLAYER_SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define PLAYER_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
// 判断是否为iPhone X 系列
#define PLAYER_iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 13.0, *)) {\
isPhoneX = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom > 0.0;\
}else if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})
// statusBar height
#define PLAYER_STATUSBAR_HEIGHT (PLAYER_iPhoneX ? 44.0f : 20.f)
// (navigationBar + statusBar) height
#define PLAYER_STATUSBAR_NAVIGATION_HEIGHT (PLAYER_iPhoneX ? 88.0f : 64.f)
// tabar距底边高度
#define PLAYER_BOTTOM_SPACE_HEIGHT (PLAYER_iPhoneX ? 34.0f : 0.0f)
// 颜色
#define PLAYER_UIColorFromHEXA(hex,a) [UIColor colorWithRed:((hex&0xFF0000)>>16)/255.0f green:((hex&0xFF00)>>8)/255.0f blue:(hex&0xFF)/255.0f alpha:a]
// 缓存路径
#define PLAYER_CACHE_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject
#define PLAYER_CACHE_VIDEO_DIRECTORY [PLAYER_CACHE_PATH stringByAppendingPathComponent:@"videos"]
// 临时路径名称
#define PLAYER_TEMP_READ_NAME @"player.temp.read"

/// HLS介绍：https://blog.csdn.net/u011857683/article/details/84863250 
/// Asset类型
typedef NS_ENUM(NSUInteger, KJPlayerAssetType) {
    KJPlayerAssetTypeNONE,/// 其他类型
    KJPlayerAssetTypeFILE,/// 文件类型，mp4等
    KJPlayerAssetTypeHLS, /// 流媒体，m3u8
};
/// 根据链接获取Asset类型
NS_INLINE KJPlayerAssetType kPlayerVideoAesstType(NSURL * url){
    if (url == nil) return KJPlayerAssetTypeNONE;
    if (url.pathExtension.length) {
        if ([url.pathExtension containsString:@"m3u8"] || [url.pathExtension containsString:@"ts"]) {
            return KJPlayerAssetTypeHLS;
        } else {
            return KJPlayerAssetTypeFILE;
        }
    }
    NSArray * array = [url.path componentsSeparatedByString:@"."];
    if (array.count == 0) {
        return KJPlayerAssetTypeNONE;
    } else if ([array.lastObject containsString:@"m3u8"] || [array.lastObject containsString:@"ts"]) {
        return KJPlayerAssetTypeHLS;
    }
    return KJPlayerAssetTypeFILE;
}
/// 播放器的几种状态
typedef NS_ENUM(NSInteger, KJPlayerState) {
    KJPlayerStateFailed = 0,/// 播放错误
    KJPlayerStateBuffering, /// 加载中缓存数据
    KJPlayerStatePreparePlay,/// 可以播放（可以取消加载状态）
    KJPlayerStatePausing, /// 暂停中
    KJPlayerStatePlaying, /// 播放中
    KJPlayerStateStopped, /// 停止
    KJPlayerStatePlayFinished,/// 播放结束
};
/// 播放状态
static NSString * const _Nonnull KJPlayerStateStringMap[] = {
    [KJPlayerStateFailed] = @"failed",
    [KJPlayerStateBuffering] = @"buffering",
    [KJPlayerStatePreparePlay] = @"preparePlay",
    [KJPlayerStatePausing] = @"pausing",
    [KJPlayerStatePlayFinished] = @"playFinished",
    [KJPlayerStateStopped] = @"stop",
    [KJPlayerStatePlaying] = @"playing",
};
/// 手势操作的类型
typedef NS_OPTIONS(NSUInteger, KJPlayerGestureType) {
    KJPlayerGestureTypeSingleTap  = 1 << 1,/// 单击手势
    KJPlayerGestureTypeDoubleTap  = 1 << 2,/// 双击手势
    KJPlayerGestureTypeLong       = 1 << 3,/// 长按操作
    KJPlayerGestureTypeProgress   = 1 << 4,/// 视频进度调节操作
    KJPlayerGestureTypeVolume     = 1 << 5,/// 声音调节操作
    KJPlayerGestureTypeBrightness = 1 << 6,/// 屏幕亮度调节操作
    
    KJPlayerGestureTypePan = KJPlayerGestureTypeProgress | KJPlayerGestureTypeVolume | KJPlayerGestureTypeBrightness,
    KJPlayerGestureTypeAll = KJPlayerGestureTypeSingleTap | KJPlayerGestureTypeDoubleTap | KJPlayerGestureTypeLong | KJPlayerGestureTypePan, 
};
/// KJBasePlayerView上面的Layer层次，zPosition改变图层的显示顺序
typedef NS_ENUM(NSUInteger, KJBasePlayerViewLayerZPosition) {
    KJBasePlayerViewLayerZPositionPlayer = 0,/// 播放器的AVPlayerLayer层
    /// `1` 被全屏时刻的 KJBasePlayerView 占用
    KJBasePlayerViewLayerZPositionInteraction = 2,/// 支持交互的控件，例如顶部底部操作面板
    KJBasePlayerViewLayerZPositionLoading = 3,/// 加载指示器和文本提醒框
    KJBasePlayerViewLayerZPositionButton = 4,/// 锁定屏幕，返回等控件
    KJBasePlayerViewLayerZPositionDisplayLayer = 5,/// 快进音量亮度等控件层
};
/// 播放类型
typedef NS_ENUM(NSUInteger, KJPlayerPlayType) {
    KJPlayerPlayTypeReplay = 0, /// 重复播放
    KJPlayerPlayTypeOrder  = 1, /// 顺序播放
    KJPlayerPlayTypeRandom = 2, /// 随机播放
    KJPlayerPlayTypeOnce   = 3, /// 仅播放一次
};
/// 播放器充满类型
typedef NS_ENUM(NSUInteger, KJPlayerVideoGravity) {
    KJPlayerVideoGravityResizeAspect = 0,/// 最大边等比充满，按比例压缩
    KJPlayerVideoGravityResizeAspectFill,/// 原始尺寸，视频不会有黑边
    KJPlayerVideoGravityResizeOriginal,  /// 拉伸充满，视频会变形
};
/// 当前屏幕状态
typedef NS_ENUM(NSUInteger, KJPlayerVideoScreenState) {
    KJPlayerVideoScreenStateSmallScreen,/// 小屏
    KJPlayerVideoScreenStateFullScreen, /// 全屏
    KJPlayerVideoScreenStateFloatingWindow,/// 浮窗
};

#pragma mark - 公共属性`ivar`宏定义

/// 公共属性区域
#define PLAYER_COMMON_EXTENSION_PROPERTY \
@property (nonatomic,assign) NSTimeInterval tryTime;\
@property (nonatomic,assign) NSTimeInterval skipHeadTime;\
@property (nonatomic,assign) NSTimeInterval skipFootTime;\
@property (nonatomic,assign) NSTimeInterval currentTime;\
@property (nonatomic,assign) NSTimeInterval totalTime;\
@property (nonatomic,assign) KJPlayerState state;\
@property (nonatomic,strong) NSError *playError;\
@property (nonatomic,strong) NSURL *originalURL;\
@property (nonatomic,assign) CGSize tempSize;\
@property (nonatomic,assign) float progress;\
@property (nonatomic,assign) BOOL buffered;\
@property (nonatomic,assign) BOOL cache;\
@property (nonatomic,assign) BOOL tryLooked;\
@property (nonatomic,assign) BOOL locality;\
@property (nonatomic,assign) BOOL userPause;\
@property (nonatomic,assign) BOOL isLiveStreaming;\
@property (nonatomic,strong) dispatch_group_t group;\

#pragma mark - 简单公共函数，这里只适合放简单的函数
// 子线程
NS_INLINE void kGCD_player_async(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    } else {
        dispatch_async(queue, block);
    }
}
// 主线程
NS_INLINE void kGCD_player_main(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    } else if ([[NSThread currentThread] isMainThread]) {
        dispatch_async(queue, block);
    } else {
        dispatch_sync(queue, block);
    }
}
// 网址转义，中文空格字符解码
NS_INLINE NSURL * kPlayerURLCharacters(NSString * urlString){
    NSString * encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [NSURL URLWithString:encodedString];
}
// 哈西加密
NS_INLINE NSString * kPlayerSHA512String(NSString * string){
    const char * cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData * data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
    return [NSString stringWithString:output];
}
// 文件名
NS_INLINE NSString * kPlayerIntactName(NSURL * url){
    return kPlayerSHA512String(url.resourceSpecifier ?: url.absoluteString);
}
// 设置时间显示
NS_INLINE NSString * kPlayerConvertTime(CGFloat second){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    if (second / 3600 >= 1) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    } else {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:second]];
}
// 隐士调用
NS_INLINE void kPlayerPerformSel(id target, NSString * selName){
    SEL sel = NSSelectorFromString(selName);
    if ([target respondsToSelector:sel]) {
        IMP imp = [target methodForSelector:sel];
        void (* tempFunc)(id target, SEL) = (void *)imp;
        tempFunc(target, sel);
    }
}

#endif /** KJPlayerType_h */

NS_ASSUME_NONNULL_END
