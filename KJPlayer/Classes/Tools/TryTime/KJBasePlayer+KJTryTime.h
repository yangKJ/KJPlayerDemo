//
//  KJBasePlayer+KJTryTime.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/16.
//  https://github.com/yangKJ/KJPlayerDemo
//  免费试看时间相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KJPlayerTryLookDelegate;
/// 免费试看时间相关
@interface KJBasePlayer (KJTryTime)

/// 免费试看协议
@property (nonatomic, weak) id<KJPlayerTryLookDelegate> tryLookDelegate;
/// 是否试看结束
@property (nonatomic, assign, readonly) BOOL tryLooked;

/// 关闭试看
- (void)closeTryLook;

/// 继续开启试看限制，播放下一个不同视频可以不用管
- (void)againPlayOpenTryLook;

@end

/// 免费试看协议
@protocol KJPlayerTryLookDelegate <NSObject>

@optional;

/// 获取免费试看时间
/// @param player 播放器内核
/// @return 试看时间，返回零不限制
- (NSTimeInterval)kj_tryLookTimeWithPlayer:(__kindof KJBasePlayer *)player;

/// 试看结束响应
/// @param player 播放器内核
/// @param currentTime 当前播放时间
- (void)kj_tryLookEndWithPlayer:(__kindof KJBasePlayer *)player currentTime:(NSTimeInterval)currentTime;

/// 试看响应
/// @param player 播放器内核
/// @param tryTime 试看时间
/// @param currentTime 当前播放时间
/// @param lookEnd 试看是否结束
- (void)kj_tryLookWithPlayer:(__kindof KJBasePlayer *)player
                     tryTime:(NSTimeInterval)tryTime
                 currentTime:(NSTimeInterval)currentTime
                     lookEnd:(BOOL)lookEnd;

@end

NS_ASSUME_NONNULL_END
