//
//  NSObject+KJBackgroundMonitoring.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/9/4.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "NSObject+KJBackgroundMonitoring.h"

@interface NSObject ()
@property (nonatomic,assign) BOOL needGround;// 是否需要前后台回调
@property (nonatomic,copy) kBackgroundMonitoringBlock xxblock;
@end

@implementation NSObject (KJBackgroundMonitoring)
#pragma mark - public
// 注册进入后台 进入前台事件
- (void)registergroundBlock:(kBackgroundMonitoringBlock)block {
    @synchronized(self) {
        self.xxblock = block;
        self.needGround = YES;
    }
    [self setupgroundNotificationCenter];
}
// 继续前后台监听
- (void)resumegroundListen {
    @synchronized(self) {
        self.needGround = YES;
    }
}
// 暂停前后台监听
- (void)pausegroundListen {
    @synchronized(self) {
        self.needGround = NO;
    }
}

#pragma mark - private
- (void)setupgroundNotificationCenter {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    });
}
/// 进入前台
- (void)applicationBecomeActive {
    if (!self.needGround) return;
    !self.xxblock?:self.xxblock(KJApplicationTypeActive);
}
/// 进入后台
- (void)applicationEnterBackground {
    if (!self.needGround) return;
    !self.xxblock?:self.xxblock(KJApplicationTypeBackground);
}
#pragma mark - geter/seter
- (BOOL)needGround {
    return objc_getAssociatedObject(self, @selector(needGround));
}
- (void)setNeedGround:(BOOL)needGround {
    objc_setAssociatedObject(self, @selector(needGround), @(needGround), OBJC_ASSOCIATION_ASSIGN);
}
- (kBackgroundMonitoringBlock)xxblock {
    return objc_getAssociatedObject(self, @selector(xxblock));
}
- (void)setXxblock:(kBackgroundMonitoringBlock)xxblock {
    objc_setAssociatedObject(self, @selector(xxblock), xxblock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
