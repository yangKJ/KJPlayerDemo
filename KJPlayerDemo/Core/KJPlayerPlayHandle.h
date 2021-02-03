//
//  KJPlayerPlayHandle.h
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
@protocol KJPlayerPlayHandle <NSObject>
@required
/* 委托代理 */
@property (nonatomic,weak) id <KJPlayerDelegate> delegate;
/* 播放器载体 */
@property (nonatomic,strong) UIView *playerView;
/* 视频地址 */
@property (nonatomic,strong) NSURL *videoURL;
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
/* 播放速度，默认1倍速 */
@property (nonatomic,assign) float speed;
/* 播放音量 */
@property (nonatomic,assign) float volume;
/* 缓存达到多少秒才能播放，默认5秒 */
@property (nonatomic,assign) NSTimeInterval cacheTime;
/* 背景颜色，默认黑色 */
@property (nonatomic,assign) CGColorRef background;
/* 时间刻度，默认1秒 */
@property (nonatomic,assign) NSTimeInterval timeSpace;
/* 占位图 */
@property (nonatomic,strong) UIImage *placeholder;
/* 视频显示模式，默认KJPlayerVideoGravityResizeAspect */
@property (nonatomic,assign) KJPlayerVideoGravity videoGravity;

/* 是否为本地资源 */
@property (nonatomic,assign,readonly) BOOL localityData;
/* 是否正在播放 */
@property (nonatomic,assign,readonly) BOOL isPlaying;
/* 当前播放时间 */
@property (nonatomic,assign,readonly) NSTimeInterval currentTime;
/* 播放失败 */
@property (nonatomic,assign,readonly) KJPlayerErrorCode errorCode;
/* 获取指定时间视频帧图片 */
@property (nonatomic,copy,readonly) UIImage * (^kPlayerTimeImage)(NSTimeInterval time);
/* 获取视频大小 */
@property (nonatomic,copy,readwrite) void (^kVideoSize)(CGSize size);

/* 单例属性 */
@property (nonatomic,strong,class,readonly,getter=kj_sharedInstance) id shared;
/* 创建单例 */
+ (instancetype)kj_sharedInstance;
/* 销毁单例 */
+ (void)kj_attempDealloc;
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
/* 设置开始播放时间 */
- (void)kj_playerSeekTime:(NSTimeInterval)seconds completionHandler:(void(^_Nullable)(BOOL finished))completionHandler;

@end
/// 委托代理
@protocol KJPlayerDelegate <NSObject>
@optional;
/* 当前播放器状态 */
- (void)kj_player:(id<KJPlayerPlayHandle>)player state:(KJPlayerState)state;
/* 播放进度 */
- (void)kj_player:(id<KJPlayerPlayHandle>)player currentTime:(NSTimeInterval)time totalTime:(NSTimeInterval)total;
/* 缓存状态 */
- (void)kj_player:(id<KJPlayerPlayHandle>)player loadstate:(KJPlayerLoadState)state;
/* 缓存进度 */
- (void)kj_player:(id<KJPlayerPlayHandle>)player loadProgress:(CGFloat)progress;

@end
NS_ASSUME_NONNULL_END
