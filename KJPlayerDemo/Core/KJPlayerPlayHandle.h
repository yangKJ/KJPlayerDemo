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

@protocol KJPlayerPlayHandle <NSObject>
@required
/* 是否使用缓存功能，默认yes */
@property (nonatomic,assign) BOOL useCacheFunction;
/* 是否开启退出后台暂停和返回播放功能，默认yes */
@property (nonatomic,assign) BOOL useOpenAppEnterBackground;
/* 进入后台是否停止播放，默认yes */
@property (nonatomic,assign) BOOL stopWhenAppEnterBackground;
/* 视频地址 */
@property (nonatomic,strong) NSURL *assetURL;
/* 播放器状态 */
@property (nonatomic,assign,readonly) KJPlayerState state;
/* 播放失败 */
@property (nonatomic,assign,readonly) KJPlayerErrorCode errorCode;
/* 缓存状态 */
@property (nonatomic,assign,readonly) KJPlayerLoadState loadState;
/* 是否为本地资源 */
@property (nonatomic,assign,readonly) BOOL localityData;
/* 播放速度 */
@property (nonatomic,assign,readonly) CGFloat speed;
/* 是否正在播放 */
@property (nonatomic,assign,readonly) BOOL isPlaying;
/* 当前播放时间 */
@property (nonatomic,assign,readonly) NSTimeInterval currentTime;
/* 视频总时长 */
@property (nonatomic,copy,readwrite) void(^kTotleTime)(NSTimeInterval time);

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
- (void)kj_playerSeekToTime:(CGFloat)seconds;
/* 切换倍速 */
- (void)kj_playerSwitchingTimesSpeed:(CGFloat)speed;

@end

NS_ASSUME_NONNULL_END
