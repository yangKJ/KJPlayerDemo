//
//  KJBasePlayer+KJBackgroundMonitoring.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/29.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJBackgroundMonitoring.h"
#import <objc/runtime.h>

@interface KJBasePlayer ()

@property (nonatomic, copy, readwrite) void(^monitoring)(BOOL isBackground, BOOL isPlaying);

@end

@implementation KJBasePlayer (KJBackgroundMonitoring)

- (void)kj_backgroundMonitoringIMP:(void(^)(BOOL isBackground, BOOL isPlaying))monitoring{
    //禁止锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kj_detectAppEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kj_detectAppEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    self.monitoring = monitoring;
}

/// 进入后台
- (void)kj_detectAppEnterBackground:(NSNotification *)notification{
    self.monitoring ? self.monitoring(YES, self.backgroundPause) : nil;
    if (self.backgroundPause) {
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    } else {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    //手机静音下也可播放声音
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}
/// 进入前台
- (void)kj_detectAppEnterForeground:(NSNotification *)notification{
    self.monitoring ? self.monitoring(NO, self.roregroundResume) : nil;
}

#pragma mark - Associated

- (BOOL)backgroundPause{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setBackgroundPause:(BOOL)backgroundPause{
    objc_setAssociatedObject(self, @selector(backgroundPause), @(backgroundPause), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)roregroundResume{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setRoregroundResume:(BOOL)roregroundResume{
    objc_setAssociatedObject(self, @selector(roregroundResume), @(roregroundResume), OBJC_ASSOCIATION_ASSIGN);
}

- (void (^)(BOOL, BOOL))monitoring{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setMonitoring:(void (^)(BOOL, BOOL))monitoring{
    objc_setAssociatedObject(self, @selector(monitoring), monitoring, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
