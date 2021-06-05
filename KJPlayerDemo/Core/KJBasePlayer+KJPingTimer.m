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
@property (nonatomic,strong) dispatch_source_t pingTimer;
@property (nonatomic,strong) NSString *lastSourceName;
@end

@implementation KJBasePlayer (KJPingTimer)
#pragma mark - 心跳包板块
//关闭心跳包（名字别乱改）
- (void)kj_closePingTimer{
    if (!self.openPing) return;
    if (self.pingTimer) {
        [self kj_playerStopTimer:self.pingTimer];
    }
}
//暂停心跳（名字别乱改）
- (void)kj_pausePingTimer{
    if (!self.openPing) return;
    if (self.pingTimer) {
        [self kj_playerPauseTimer:self.pingTimer];
    }
}
//继续心跳（名字别乱改）
- (void)kj_resumePingTimer{
    if (!self.openPing) return;
    if (self.pingTimer) {
        [self kj_playerResumeTimer:self.pingTimer];
    }else{
        if (!self.maxConnect) self.maxConnect = 3;
        self.pingTimer = [self kj_playerCreateAsyncTimer:YES Task:^{
            [self pingInvoke];
        } start:0 interval:self.timeSpace repeats:YES];
        PLAYERLogOneInfo(@"--- 🎉🎉 成功创建心跳包 ---");
    }
}
- (void)pingInvoke{
    if (self.userPause || self.tryLooked || self.isLiveStreaming) {// 用户暂停和试看时间已到，直播流媒体
        return;
    }
    PLAYERLogTwoInfo(@"--- 🚗 心跳包 🚗 ---:%.2f",self.currentTime);
//    static int xxxx;
    KJPlayerVideoPingTimerState state;
//    if (self.currentTime > self.lastTime) {
//        xxxx = 0;
//        self.lastTime = self.currentTime;
        state = KJPlayerVideoPingTimerStatePing;
//    }else{
//        xxxx++;
//        if (xxxx > self.maxConnect) {
//            xxxx = 0;
//            self.lastTime = 0;
//            [self kj_closePingTimer];
//            state = KJPlayerVideoPingTimerStateFailed;
//        }else{
//            state = KJPlayerVideoPingTimerStateReconnect;
//        }
//    }
    if (self.kVideoPingTimerState) {
        self.kVideoPingTimerState(state);
    }
}

#pragma mark - 动态切换板块
/* 动态切换播放内核 */
- (void)kj_dynamicChangeSourcePlayer:(Class)clazz{
    NSString *__name = NSStringFromClass([self class]);
    kPlayerPerformSel(self, @"kj_changeSourceCleanJobs");
    object_setClass(self, clazz);
    if ([__name isEqualToString:self.lastSourceName]) {
        return;
    }else{
        self.lastSourceName = __name;
    }
//    if ([__name isEqualToString:@"KJAVPlayer"]) {
//        [self setValue:nil forKey:@"tempView"];
//    }else if ([__name isEqualToString:@"KJIJKPlayer"]) {
//        [self setValue:nil forKey:@"playerOutput"];
//        [self setValue:nil forKey:@"playerLayer"];
//    }else if ([__name isEqualToString:@"KJMIDIPlayer"]) {
//
//    }
}
/* 是否进行过动态切换内核 */
- (BOOL (^)(void))kPlayerDynamicChangeSource{
    return ^BOOL{
        if (self.lastSourceName == nil || !self.lastSourceName.length) {
            return NO;
        }
        return ![self.lastSourceName isEqualToString:NSStringFromClass([self class])];
    };
}
/* 当前播放器内核名 */
- (NSString * (^)(void))kPlayerCurrentSourceName{
    return ^NSString * {
        NSString *name = NSStringFromClass([self class]);
        if ([name isEqualToString:@"KJAVPlayer"]) {
            return @"AVPlayer";
        }
        if ([name isEqualToString:@"KJIJKPlayer"]) {
            return @"IJKPlayer";
        }
        if ([name isEqualToString:@"KJMIDIPlayer"]) {
            return @"midi";
        }
        return @"Unknown";
    };
}

#pragma mark - Associated
- (NSString *)lastSourceName{
    return objc_getAssociatedObject(self, _cmd);;
}
- (void)setLastSourceName:(NSString *)lastSourceName{
    objc_setAssociatedObject(self, @selector(lastSourceName), lastSourceName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL)openPing{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setOpenPing:(BOOL)openPing{
    objc_setAssociatedObject(self, @selector(openPing), @(openPing), OBJC_ASSOCIATION_ASSIGN);
}
- (dispatch_source_t)pingTimer{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setPingTimer:(dispatch_source_t)timer{
    objc_setAssociatedObject(self, @selector(pingTimer), timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    objc_setAssociatedObject(self, @selector(maxConnect), @(maxConnect), OBJC_ASSOCIATION_ASSIGN);
}
- (void (^)(KJPlayerVideoPingTimerState))kVideoPingTimerState{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setKVideoPingTimerState:(void (^)(KJPlayerVideoPingTimerState))kVideoPingTimerState{
    objc_setAssociatedObject(self, @selector(kVideoPingTimerState), kVideoPingTimerState, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isHangUp{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setIsHangUp:(BOOL)isHangUp{
    objc_setAssociatedObject(self, @selector(isHangUp), @(isHangUp), OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - GCD 计时器
/* 创建异步定时器 */
- (dispatch_source_t)kj_playerCreateAsyncTimer:(BOOL)async
                                          Task:(void(^)(void))task
                                         start:(NSTimeInterval)start
                                      interval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats{
    if (!task || start < 0 || (interval <= 0 && repeats)) return nil;
    self.isHangUp = NO;
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    __block dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    __weak __typeof(self) weaktarget = self;
    dispatch_source_set_event_handler(timer, ^{
        if (weaktarget == nil) {
            dispatch_source_cancel(timer);
            timer = NULL;
        }else{
            if (repeats) {
                task();
            }else{
                task();
                [self kj_playerStopTimer:timer];
            }
        }
    });
    dispatch_resume(timer);
    return timer;
}
/* 取消计时器 */
- (void)kj_playerStopTimer:(dispatch_source_t)timer{
    self.isHangUp = NO;
    if (timer) {
        dispatch_source_cancel(timer);
        timer = NULL;
    }
}
/* 暂停计时器 */
- (void)kj_playerPauseTimer:(dispatch_source_t)timer{
    if (timer) {
        self.isHangUp = YES;
        dispatch_suspend(timer);
    }
}
/* 继续计时器 */
- (void)kj_playerResumeTimer:(dispatch_source_t)timer{
    if (timer && self.isHangUp) {
        self.isHangUp = NO;
        //挂起的时候注意，多次暂停的操作会导致线程锁的现象
        //dispatch_suspend和dispatch_resume是一对
        dispatch_resume(timer);
    }
}


@end
