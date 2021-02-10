//
//  KJBasePlayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/8.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  播放器协议

#import <Foundation/Foundation.h>
#import "KJPlayerType.h"

NS_ASSUME_NONNULL_BEGIN
@protocol KJPlayerDelegate;
@protocol KJBasePlayer <NSObject>
@required
/* 委托代理 */
@property (nonatomic,weak) id <KJPlayerDelegate> delegate;
/* 播放器载体 */
@property (nonatomic,strong) UIView *playerView;
/* 视频请求头 */
@property (nonatomic,strong) NSDictionary *requestHeader;
/* 是否使用缓存功能，默认no */
@property (nonatomic,assign) BOOL useCacheFunction;
/* 返回前台继续播放，默认no */
@property (nonatomic,assign) BOOL roregroundResume;
/* 进入后台暂停播放，默认no */
@property (nonatomic,assign) BOOL backgroundPause;
/* 是否开启自动播放，默认yes */
@property (nonatomic,assign) BOOL autoPlay;
/* 是否为用户暂停，默认no */
@property (nonatomic,assign) BOOL userPause;
/* 播放速度，默认1倍速 */
@property (nonatomic,assign) float speed;
/* 播放音量 */
@property (nonatomic,assign) float volume;
/* 是否静音 */
@property (nonatomic,assign) BOOL muted;
/* 缓存达到多少秒才能播放，默认5秒 */
@property (nonatomic,assign) NSTimeInterval cacheTime;
/* 指定时间播放（跳过片头）*/
@property (nonatomic,assign) NSTimeInterval seekTime;
/* 背景颜色，默认黑色 */
@property (nonatomic,assign) CGColorRef background;
/* 时间刻度，默认1秒 */
@property (nonatomic,assign) NSTimeInterval timeSpace;
/* 占位图 */
@property (nonatomic,strong) UIImage *placeholder;
/* 视频显示模式，默认KJPlayerVideoGravityResizeAspect */
@property (nonatomic,assign) KJPlayerVideoGravity videoGravity;
/* 获取视频总时长 */
@property (nonatomic,copy,readwrite) void (^kVideoTotalTime)(NSTimeInterval time);
/* 获取视频格式 */
@property (nonatomic,copy,readwrite) void (^kVideoURLFromat)(KJPlayerVideoFromat fromat);
/* 免费试看时间和试看结束回调，默认0不限制 */
@property (nonatomic,copy,readonly) void (^kVideoTryLookTime)(void(^_Nullable lookEnd)(bool end), NSTimeInterval time);

/* ************************* 分割线，上述属性需在videoURL之前设置 *****************************/
/* 视频地址 */
@property (nonatomic,strong) NSURL *videoURL;

/* ************************* 分割线，下面属性需在videoURL之后获取 *****************************/
/* 是否为本地资源 */
@property (nonatomic,assign,readonly) BOOL localityData;
/* 是否正在播放 */
@property (nonatomic,assign,readonly) BOOL isPlaying;
/* 当前播放时间 */
@property (nonatomic,assign,readonly) NSTimeInterval currentTime;
/* 播放失败 */
@property (nonatomic,assign,readonly) KJPlayerErrorCode errorCode;
/* 获取视频尺寸大小 */
@property (nonatomic,copy,readwrite) void (^kVideoSize)(CGSize size);
/* 获取指定时间视频帧图片 */
@property (nonatomic,copy,readonly) UIImage * (^kPlayerTimeImage)(NSTimeInterval time);
/* 快进或快退 */
@property (nonatomic,copy,readonly) void (^kVideoAdvanceAndReverse)(NSTimeInterval, void(^_Nullable)(bool finished));

/* 准备播放 */
- (void)kj_playerPlay;
/* 重播 */
- (void)kj_playerReplay;
/* 继续 */
- (void)kj_playerResume;
/* 暂停 */
- (void)kj_playerPause;
/* 停止 */
- (void)kj_playerStop;

@end
/// 委托代理
@protocol KJPlayerDelegate <NSObject>
@optional;
/* 当前播放器状态 */
- (void)kj_player:(id<KJBasePlayer>)player state:(KJPlayerState)state;
/* 播放进度 */
- (void)kj_player:(id<KJBasePlayer>)player currentTime:(NSTimeInterval)time totalTime:(NSTimeInterval)total;
/* 缓存状态 */
- (void)kj_player:(id<KJBasePlayer>)player loadstate:(KJPlayerLoadState)state;
/* 缓存进度 */
- (void)kj_player:(id<KJBasePlayer>)player loadProgress:(CGFloat)progress;

@end
NS_ASSUME_NONNULL_END
