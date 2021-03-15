//
//  KJBasePlayer+KJPingTimer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJPingTimer.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface KJBasePlayer ()
@property (nonatomic,assign) NSTimeInterval lastTime;
@property (nonatomic,strong) NSString *taskName;
@end

@implementation KJBasePlayer (KJPingTimer)
//关闭心跳包（名字别乱改）
- (void)kj_closePingTimer{
    if (!self.openPing) return;
    NSString *task = objc_getAssociatedObject(self, &taskNameKey);
    if (task) {
        [KJGCDTimer kj_cancelTimer:task];
        objc_setAssociatedObject(self, &taskNameKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
//继续心跳（名字别乱改）
- (void)kj_resumePingTimer{
    if (!self.openPing) return;
    NSString *task = objc_getAssociatedObject(self, &taskNameKey);
    if (task) {
        [KJGCDTimer kj_resumeTimer:task];
    }else if (self.taskName) {
        PLAYERLogOneInfo(@"--- 🎉🎉 成功创建心跳包 ---");
    }
}
//暂停心跳（名字别乱改）
- (void)kj_pausePingTimer{
    if (!self.openPing) return;
    NSString *task = objc_getAssociatedObject(self, &taskNameKey);
    if (task) {
        [KJGCDTimer kj_pauseTimer:task];
    }
}

#pragma mark - 心跳包
- (void)pingInvoke{
    if (self.userPause || self.tryLooked || self.isLiveStreaming) {// 用户暂停和试看时间已到，直播流媒体
        return;
    }
    PLAYERLogOneInfo(@"--- 🚗 心跳包 🚗 ---:%.2f",self.currentTime);
    static int xxxx;
    KJPlayerVideoPingTimerState state;
    if (self.currentTime > self.lastTime) {
        xxxx = 0;
        self.lastTime = self.currentTime;
        state = KJPlayerVideoPingTimerStatePing;
    }else{
        xxxx++;
        if (xxxx > self.maxConnect) {
            xxxx = 0;
            self.lastTime = 0;
            [self kj_closePingTimer];
            state = KJPlayerVideoPingTimerStateFailed;
        }else{
            state = KJPlayerVideoPingTimerStateReconnect;
        }
    }
    if (self.kVideoPingTimerState) {
        self.kVideoPingTimerState(state);
    }
}

#pragma mark - lazy
static char taskNameKey;
- (NSString *)taskName{
    NSString *task = objc_getAssociatedObject(self, &taskNameKey);
    if (task == nil) {
        if (!self.maxConnect) self.maxConnect = 3;
        task = [KJGCDTimer kj_createTimerWithTarget:self selector:@selector(pingInvoke) start:0 interval:self.timeSpace repeats:YES async:YES];
        objc_setAssociatedObject(self, &taskNameKey, task, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return task;
}

#pragma mark - Associated
- (NSTimeInterval)lastTime{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}
- (void)setLastTime:(NSTimeInterval)lastTime{
    objc_setAssociatedObject(self, @selector(lastTime), @(lastTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (int)maxConnect{
    return [objc_getAssociatedObject(self, _cmd) intValue];;
}
- (void)setMaxConnect:(int)maxConnect{
    objc_setAssociatedObject(self, @selector(maxConnect), @(maxConnect), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void (^)(KJPlayerVideoPingTimerState))kVideoPingTimerState{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setKVideoPingTimerState:(void (^)(KJPlayerVideoPingTimerState))kVideoPingTimerState{
    objc_setAssociatedObject(self, @selector(kVideoPingTimerState), kVideoPingTimerState, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)openPing{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setOpenPing:(BOOL)openPing{
    objc_setAssociatedObject(self, @selector(openPing), @(openPing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
