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

@interface KJBasePlayer (KJPingTimer)
/* 最大断连次数，默认3次 */
@property (nonatomic,assign) int maxConnect;
/* 是否需要开启心跳包检测卡顿和断线，默认no */
@property (nonatomic,assign) BOOL openPing;//TODO:还有问题，待调试
/* 心跳包状态 */
@property (nonatomic,copy,readwrite) void(^kVideoPingTimerState)(KJPlayerVideoPingTimerState state);

@end

NS_ASSUME_NONNULL_END
