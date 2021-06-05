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

#pragma mark - 心跳包板块
/* 最大断连次数，默认3次 */
@property (nonatomic,assign) int maxConnect;
/* 是否需要开启心跳包检测卡顿和断线，默认no */
@property (nonatomic,assign) BOOL openPing;//TODO:还有问题，待调试
/* 心跳包状态 */
@property (nonatomic,copy,readwrite) void(^kVideoPingTimerState)(KJPlayerVideoPingTimerState state);

#pragma mark - 动态切换板块，TODO：还不完善，待调试
/* 动态切换播放内核，核心就是切换isa */
- (void)kj_dynamicChangeSourcePlayer:(Class)clazz;
/* 是否进行过动态切换内核 */
@property (nonatomic,copy,readonly) BOOL (^kPlayerDynamicChangeSource)(void);
/* 当前播放器内核名 */
@property (nonatomic,copy,readonly) NSString * (^kPlayerCurrentSourceName)(void);

@end

NS_ASSUME_NONNULL_END
