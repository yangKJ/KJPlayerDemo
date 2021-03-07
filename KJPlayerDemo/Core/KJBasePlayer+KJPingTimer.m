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
@property (nonatomic,strong) NSTimer *pingTimer;//心跳包
@end

@implementation KJBasePlayer (KJPingTimer)
#pragma mark - Associated
static char pingTimerKey;
- (NSTimer *)pingTimer{
    return objc_getAssociatedObject(self, &pingTimerKey);
}
- (void)setPingTimer:(NSTimer *)pingTimer{
    objc_setAssociatedObject(self, &pingTimerKey, pingTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
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

//关闭心跳包（名字别乱改）
- (void)kj_closePingTimer{
    if (!self.openPing) return;
    NSTimer *timer = objc_getAssociatedObject(self, &pingTimerKey);
    if (timer) {
        [timer invalidate];
        objc_setAssociatedObject(self, &pingTimerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
//继续心跳（名字别乱改）
- (void)kj_resumePingTimer{
    if (!self.openPing) return;
    if (self.pingTimer) {
        [self.pingTimer setFireDate:[NSDate date]];
    }else{
        if (!self.maxConnect) self.maxConnect = 3;
        [self kj_closePingTimer];
        PLAYER_WEAKSELF;
        @autoreleasepool {
            NSThread *thread = [[NSThread alloc] initWithBlock:^{
                weakself.pingTimer = [NSTimer timerWithTimeInterval:weakself.timeSpace target:weakself selector:@selector(pingInvoke) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:weakself.pingTimer forMode:NSRunLoopCommonModes];
                [[NSRunLoop currentRunLoop] run];
            }];
            [thread start];
            thread = nil;
        }
    }
}
//暂停心跳（名字别乱改）
- (void)kj_pausePingTimer{
    if (!self.openPing) return;
    if (self.pingTimer) {
        [self.pingTimer setFireDate:[NSDate distantFuture]];
    }
}

#pragma mark - 心跳包
- (void)pingInvoke{
    if (self.userPause || self.tryLooked || self.isLiveStreaming) {// 用户暂停和试看时间已到，直播流媒体
        return;
    }
#ifdef DEBUG
    NSLog(@"---心跳包---%.2f",self.currentTime);
#endif
    static int xx;
    if (self.currentTime > self.lastTime) {
        self.lastTime = self.currentTime;
        xx = 0;
        if (self.kVideoPingTimerState) self.kVideoPingTimerState(KJPlayerVideoPingTimerStatePing);
    }else{
        xx++;
        if (xx > self.maxConnect) {
            xx = 0;
            self.lastTime = 0;
            [self kj_closePingTimer];
            if (self.kVideoPingTimerState) self.kVideoPingTimerState(KJPlayerVideoPingTimerStateFailed);
        }else{
            [self.pingTimer setFireDate:[NSDate distantFuture]];
            if (self.kVideoPingTimerState) self.kVideoPingTimerState(KJPlayerVideoPingTimerStateReconnect);
        }
    }
}

@end
