//
//  KJOldPlayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  老版本AVPlayer内核

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KJPlayerType.h"
NS_ASSUME_NONNULL_BEGIN

@protocol KJOldPlayerDelegate;
@interface KJOldPlayer : NSObject
/* 单例 */
+ (instancetype)sharedInstance;
/* 播放器 */
@property (nonatomic,strong,readonly) AVPlayer *videoPlayer;
/* 播放器Layer */
@property (nonatomic,strong,readonly) AVPlayerLayer *videoPlayerLayer;
/* 视频总时间 */
@property (nonatomic,assign,readonly) CGFloat videoTotalTime;
/* 是否为本地资源 */
@property (nonatomic,assign,readonly) BOOL videoIsLocalityData;

/* 进入后台是否停止播放，默认yes */
@property (nonatomic,assign) BOOL stopWhenAppEnterBackground;
/* 是否开启退出后台暂停和返回播放功能，默认yes */
@property (nonatomic,assign) BOOL useOpenAppEnterBackground;
/* 委托 */
@property (nonatomic,weak) id <KJOldPlayerDelegate> delegate;

/* 设置开始播放时间，默认为0 */
@property (nonatomic,assign) CGFloat startPlayTime;
/* 播放地址 */
- (AVPlayerLayer*)kj_playerPlayWithURL:(NSURL*)url;
/* 重播地址 */
- (void)kj_playerReplayWithURL:(NSURL*)url;
/* 设置开始播放时间 */
- (void)kj_playerSeekToTime:(CGFloat)seconds BeginPlayBlock:(KJPlayerSeekBeginPlayBlock)block;
/* 恢复播放 */
- (void)kj_playerResume;
/* 暂停 */
- (void)kj_playerPause;
/* 停止 */
- (void)kj_playerStop;

#pragma mark - 回调事件处理
/* 当前播放器状态 */
@property (nonatomic,readwrite,copy) void (^kPlayerStateBlcok)(KJOldPlayer *player, KJPlayerState state, KJPlayerErrorCode errorCode);
/* 播放进度 */
@property (nonatomic,readwrite,copy) void (^kPlayerPlayProgressBlcok)(KJOldPlayer *player, CGFloat progress, CGFloat currentTime, CGFloat durationTime);
/* 缓存完成 */
@property (nonatomic,readwrite,copy) void (^kPlayerLoadingBlcok)(KJOldPlayer *player, CGFloat loadedProgress, BOOL complete, BOOL saveSuccess);

@end
/// 委托代理
@protocol KJOldPlayerDelegate <NSObject>
@optional;
/* 当前播放器状态 */
- (void)kj_player:(KJOldPlayer*)player State:(KJPlayerState)state ErrorCode:(KJPlayerErrorCode)errorCode;
/* 播放进度 */
- (void)kj_player:(KJOldPlayer*)player Progress:(CGFloat)progress CurrentTime:(CGFloat)currentTime DurationTime:(CGFloat)durationTime;
/* 缓存完成 */
- (void)kj_player:(KJOldPlayer*)player LoadedProgress:(CGFloat)loadedProgress LoadComplete:(BOOL)complete SaveSuccess:(BOOL)saveSuccess;

@end

NS_ASSUME_NONNULL_END
