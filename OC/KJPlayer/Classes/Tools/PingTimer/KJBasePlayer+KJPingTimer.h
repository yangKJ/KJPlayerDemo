//
//  KJBasePlayer+KJPingTimer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  心跳包

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN
/// 心跳包状态
typedef NS_ENUM(NSUInteger, KJPlayerVideoPingTimerState) {
    KJPlayerVideoPingTimerStateFailed = 0,/// 心跳死亡
    KJPlayerVideoPingTimerStatePing,      /// 正常心跳当中
    KJPlayerVideoPingTimerStateReconnect, /// 重新连接
};
@protocol KJPlaterPingDelegate;
/// 心跳包相关
@interface KJBasePlayer (KJPingTimer)

/// 心跳协议
@property (nonatomic, weak) id<KJPlaterPingDelegate> pingDelegate;

@end

@protocol KJPlaterPingDelegate <NSObject>

@optional;

/// 是否开启心跳包协议
/// @param player 播放器内核
- (BOOL)kj_openPingWithPlayer:(__kindof KJBasePlayer *)player;

/// 心跳状态协议
/// @param player 播放器内核
/// @param beatState 心跳包状态
- (void)kj_pingStateWithPlayer:(__kindof KJBasePlayer *)player beatState:(KJPlayerVideoPingTimerState)beatState;

@end

NS_ASSUME_NONNULL_END
