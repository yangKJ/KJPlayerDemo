//
//  KJPlayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//  播放器功能区

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KJPlayerTool.h"

NS_ASSUME_NONNULL_BEGIN

/// 几种错误的code
typedef NS_ENUM(NSInteger, KJPlayerErrorCode) {
    KJPlayerErrorCodeNoError         = 0, /// 正常播放
    KJPlayerErrorCodeOtherSituations = 1, /// 其他情况
    KJPlayerErrorCodeVideoUrlError = 100, /// 视频地址不正确
    KJPlayerErrorCodeNetworkOvertime = -1001, /// 请求超时：-1001
    KJPlayerErrorCodeServerNotFound  = -1003, /// 找不到服务器：-1003
    KJPlayerErrorCodeServerInternalError = -1004, /// 服务器内部错误：-1004
    KJPlayerErrorCodeNetworkInterruption = -1005, /// 网络中断：-1005
    KJPlayerErrorCodeNetworkNoConnection = -1009, /// 无网络连接：-1009
};

/// 播放器的几种状态
typedef NS_ENUM(NSInteger, KJPlayerState) {
    KJPlayerStateLoading = 1, /// 加载中 缓存数据
    KJPlayerStatePlaying = 2, /// 播放中
    KJPlayerStatePlayEnd = 3, /// 播放结束
    KJPlayerStateStopped = 4, /// 停止
    KJPlayerStatePause   = 5, /// 暂停
    KJPlayerStateError   = 6, /// 播放错误
};
@class KJPlayer;
@protocol KJPlayerDelegate <NSObject>

@optional;
/** 当前播放器状态 */
- (void)kj_player:(KJPlayer*)player State:(KJPlayerState)state ErrorCode:(KJPlayerErrorCode)errorCode;
/** 播放进度
 *  progress 播放进度 0~1
 *  currentTime 当前播放时间
 *  durationTime 视频总时间
 */
- (void)kj_player:(KJPlayer *)player Progress:(CGFloat)progress CurrentTime:(CGFloat)currentTime DurationTime:(CGFloat)durationTime;

/** 缓存完成
 *  loadedProgress 缓存进度 0~1
 *  complete 缓存完成
 *  saveSuccess 视频保存成功
 */
- (void)kj_player:(KJPlayer *)player LoadedProgress:(CGFloat)loadedProgress LoadComplete:(BOOL)complete SaveSuccess:(BOOL)saveSuccess;

@end

@interface KJPlayer : NSObject

/* 单例 */
+ (instancetype)sharedInstance;
/* 播放器 */
@property (nonatomic,strong,readonly) AVPlayer *videoPlayer;
/* 播放器Layer */
@property (nonatomic,strong,readonly) AVPlayerLayer *videoPlayerLayer;
/* 视频第一帧图片 */
@property (nonatomic,strong,readonly) UIImage *videoFristImage;
/* 视频总时间 */
@property (nonatomic,assign,readonly) CGFloat videoTotalTime;
/* 是否为本地资源 */
@property (nonatomic,assign,readonly) BOOL videoIsLocalityData;

/* 进入后台是否停止播放，默认yes */
@property (nonatomic,assign) BOOL stopWhenAppEnterBackground;
/* 是否需要显示第一帧图片，默认no */
@property (nonatomic,assign) BOOL needDisplayFristImage;
/** 委托 */
@property (nonatomic,weak) id <KJPlayerDelegate> delegate;

/* 播放地址 */
- (AVPlayerLayer*)kj_playerPlayWithURL:(NSURL*)url;
/* 重播地址 */
- (void)kj_playerReplayWithURL:(NSURL*)url;
/* 设置开始播放时间 */
- (void)kj_playerSeekToTime:(CGFloat)seconds;
/* 恢复播放 */
- (void)kj_playerResume;
/* 暂停 */
- (void)kj_playerPause;
/* 停止 */
- (void)kj_playerStop;

/************************* 事件处理 *************************/
/** 当前播放器状态 */
@property (nonatomic,copy) void (^kPlayerStateBlcok)(KJPlayer *player, KJPlayerState state, KJPlayerErrorCode errorCode);
/** 缓存完成
 *  loadedProgress 缓存进度 0~1
 *  complete 缓存完成
 *  saveSuccess 视频保存成功
 */
@property (nonatomic,copy) void (^kPlayerLoadingBlcok)(KJPlayer *player, CGFloat loadedProgress, BOOL complete, BOOL saveSuccess);
/** 播放进度
 *  progress 播放进度 0~1
 *  currentTime 当前播放时间
 *  durationTime 视频总时间
 */
@property (nonatomic,copy) void (^kPlayerPlayProgressBlcok)(KJPlayer *player, CGFloat progress, CGFloat currentTime, CGFloat durationTime);

@end

NS_ASSUME_NONNULL_END
