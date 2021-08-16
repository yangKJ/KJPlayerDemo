//
//  KJBaseFunctionPlayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/8.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  播放器协议，功能区

#import <Foundation/Foundation.h>
#import "KJPlayerType.h"

NS_ASSUME_NONNULL_BEGIN
@protocol KJPlayerDelegate;
@protocol KJBaseFunctionPlayer <NSObject>
@required
/// 委托代理
@property (nonatomic,weak) id <KJPlayerDelegate> delegate;
/// 视频请求头
@property (nonatomic,strong) NSDictionary *requestHeader;
/// 返回前台继续播放，默认no
@property (nonatomic,assign) BOOL roregroundResume;
/// 进入后台暂停播放，默认no
@property (nonatomic,assign) BOOL backgroundPause;
/// 是否开启自动播放，默认yes
@property (nonatomic,assign) BOOL autoPlay;
/// 是否开启只允许快进到已缓存位置，默认no
@property (nonatomic,assign) BOOL openAdvanceCache;
/// 播放速度，默认1倍速
@property (nonatomic,assign) float speed;
/// 播放音量
@property (nonatomic,assign) float volume;
/// 是否静音
@property (nonatomic,assign) BOOL muted;
/// 缓存达到多少秒才能播放，默认零秒
@property (nonatomic,assign) NSTimeInterval cacheTime;
/// 时间刻度，默认1秒
@property (nonatomic,assign) NSTimeInterval timeSpace;
/// 免费试看时间和试看结束回调，默认0不限制
@property (nonatomic,copy,readonly) void (^kVideoTryLookTime)(void(^_Nullable)(void), NSTimeInterval time);

// ************************* 分割线，上述属性需在videoURL之前设置 ****************************
/// 视频地址，这个和下面的方法互斥，支持m3u8
@property (nonatomic,strong) NSURL *videoURL;
/// 使用边播边缓存
//@property (nonatomic,copy,readonly) BOOL (^kVideoCanCacheURL)(NSURL *videoURL, BOOL cache);

// ************************* 分割线，下面属性需在videoURL之后获取 ****************************
/// 原始视频地址，用于出错重播和记录上次播放
@property (nonatomic,strong,readonly) NSURL *originalURL;
/// 播放失败
@property (nonatomic,strong,readonly) NSError *playError;
/// 本地资源
@property (nonatomic,assign,readonly) BOOL locality;
/// 是否正在播放
@property (nonatomic,assign,readonly) BOOL isPlaying;
/// 是否为用户暂停
@property (nonatomic,assign,readonly) BOOL userPause;
/// 是否为直播流媒体，直播时总时间无效
@property (nonatomic,assign,readonly) BOOL isLiveStreaming;
/// 是否试看结束
@property (nonatomic,assign,readonly) BOOL tryLooked;
/// 当前播放时间
@property (nonatomic,assign,readonly) NSTimeInterval currentTime;
/// 视频总时间
@property (nonatomic,assign,readonly) NSTimeInterval totalTime;
/// 快进或快退
@property (nonatomic,copy,readonly) void (^kVideoAdvanceAndReverse)(NSTimeInterval, void(^_Nullable)(BOOL finished));

#pragma mark - method
/// 准备播放
- (void)kj_play;
/// 重播
- (void)kj_replay;
/// 继续
- (void)kj_resume;
/// 暂停
- (void)kj_pause;
/// 停止
- (void)kj_stop;
/// 指定时间播放，快进或快退功能
/// @param time 指定时间
- (void)kj_appointTime:(NSTimeInterval)time;

#pragma mark - NSNotification
/// 进入后台
- (void)kj_detectAppEnterBackground:(NSNotification *)notification;
/// 进入前台
- (void)kj_detectAppEnterForeground:(NSNotification *)notification;

@end

// 公共ivar
#define PLAYER_COMMON_FUNCTION_PROPERTY \
@synthesize delegate = _delegate;\
@synthesize roregroundResume = _roregroundResume;\
@synthesize backgroundPause = _backgroundPause;\
@synthesize videoURL = _videoURL;\
@synthesize originalURL = _originalURL;\
@synthesize speed = _speed;\
@synthesize volume = _volume;\
@synthesize muted = _muted;\
@synthesize cacheTime = _cacheTime;\
@synthesize currentTime = _currentTime;\
@synthesize totalTime = _totalTime;\
@synthesize playError = _playError;\
@synthesize timeSpace = _timeSpace;\
@synthesize requestHeader = _requestHeader;\
@synthesize autoPlay = _autoPlay;\
@synthesize openAdvanceCache = _openAdvanceCache;\
@synthesize isPlaying = _isPlaying;\
@synthesize tryLooked = _tryLooked;\
@synthesize locality = _locality;\
@synthesize userPause = _userPause;\
@synthesize isLiveStreaming = _isLiveStreaming;\
@synthesize kVideoTryLookTime = _kVideoTryLookTime;\
@synthesize kVideoAdvanceAndReverse = _kVideoAdvanceAndReverse;\

NS_ASSUME_NONNULL_END
