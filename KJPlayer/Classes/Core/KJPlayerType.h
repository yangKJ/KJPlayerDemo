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
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN
// 弱引用
#define PLAYER_WEAKSELF __weak __typeof(self) weakself = self
#define PLAYER_STRONGSELF __strong __typeof(self) strongself = weakself
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
#define PLAYER_UIColorFromHEXA(hex,a) [UIColor colorWithRed:((hex&0xFF0000)>>16)/255.0f \
green:((hex&0xFF00)>>8)/255.0f blue:(hex&0xFF)/255.0f alpha:a]
// 缓存路径
#define PLAYER_CACHE_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject
#define PLAYER_CACHE_VIDEO_DIRECTORY [PLAYER_CACHE_PATH stringByAppendingPathComponent:@"videos"]
// 临时路径名称
#define PLAYER_TEMP_READ_NAME @"player.temp.read"
// 通知消息
#define PLAYER_POST_NOTIFICATION(__name__, __object__, __userInfo__) \
[[NSNotificationCenter defaultCenter] \
postNotificationName:__name__ object:__object__ userInfo:__userInfo__];
// 错误CODE通知消息
#define PLAYER_NOTIFICATION_CODE(__object__, __value__) \
PLAYER_POST_NOTIFICATION(kPlayerErrorCodeNotification, __object__, @{kPlayerErrorCodekey:__value__})

/// HLS介绍：https://blog.csdn.net/u011857683/article/details/84863250
/// Asset类型
typedef NS_ENUM(NSUInteger, KJPlayerAssetType) {
    KJPlayerAssetTypeNONE,/// 其他类型
    KJPlayerAssetTypeFILE,/// 文件类型，mp4等
    KJPlayerAssetTypeHLS, /// 流媒体，m3u8
};
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
    [KJPlayerStateFailed]       = @"failed",
    [KJPlayerStateBuffering]    = @"buffering",
    [KJPlayerStatePreparePlay]  = @"preparePlay",
    [KJPlayerStatePausing]      = @"pausing",
    [KJPlayerStatePlayFinished] = @"playFinished",
    [KJPlayerStateStopped]      = @"stop",
    [KJPlayerStatePlaying]      = @"playing",
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
/// 自定义错误情况
typedef NS_ENUM(NSInteger, KJPlayerCustomCode) {
    KJPlayerCustomCodeNormal = 0,/// 正常播放
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

/// 联合体，返回总时间和当前时间
typedef struct KJPlayerTimeUnion{
    NSTimeInterval currentTime;
    NSTimeInterval totalTime;
    bool isReplace; /// 是否替换自带UI，也就是是否使用CustomView模块
} KJPlayerTimeUnion;

#pragma mark - custom ivar

/// 公共属性区域
#define PLAYER_COMMON_EXTENSION_PROPERTY \
@property (nonatomic,assign) NSTimeInterval tryTime;\
@property (nonatomic,assign) NSTimeInterval skipHeadTime;\
@property (nonatomic,assign) NSTimeInterval skipFootTime;\
@property (nonatomic,assign) NSTimeInterval currentTime;\
@property (nonatomic,assign) NSTimeInterval totalTime;\
@property (nonatomic,assign) KJPlayerState state;\
@property (nonatomic,strong) NSURL *originalURL;\
@property (nonatomic,assign) CGSize tempSize;\
@property (nonatomic,assign) float progress;\
@property (nonatomic,assign) BOOL buffered;\
@property (nonatomic,assign) BOOL tryLooked;\
@property (nonatomic,assign) BOOL userPause;\
@property (nonatomic,assign) BOOL isLiveStreaming;\
@property (nonatomic,strong) dispatch_group_t group;\

#endif /* KJPlayerType_h */

NS_ASSUME_NONNULL_END
