//
//  KJBasePlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer.h"
#import "KJCacheManager.h"

@interface KJBasePlayer ()
/// 错误信息
@property (nonatomic, strong) NSError * playError;
@end

@implementation KJBasePlayer

PLAYER_COMMON_FUNCTION_PROPERTY
PLAYER_COMMON_UI_PROPERTY

static KJBasePlayer *_instance = nil;
static dispatch_once_t onceToken;
+ (instancetype)kj_sharedInstance{
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}
+ (void)kj_attempDealloc{
    onceToken = 0;
    _instance = nil;
}
- (void)dealloc{
#ifdef DEBUG
    NSLog(@"------- 🎈 %@已销毁 🎈 -------\n", self);
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"state"];
    [self removeObserver:self forKeyPath:@"progress"];
    [self removeObserver:self forKeyPath:@"playError"];
    [self removeObserver:self forKeyPath:@"currentTime"];
    //记录播放时间，`KJBasePlayer+KJRecordTime`
    kPlayerPerformSel(self, @"kj_saveRecordLastTime");
}
- (instancetype)init{
    if (self = [super init]) {
        [self kj_addNotificationCenter];
    }
    return self;
}
- (void)kj_addNotificationCenter{
    //禁止锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kj_detectAppEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kj_detectAppEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kj_basePlayerViewChange:)
                                                 name:kPlayerBaseViewChangeNotification
                                               object:nil];
    //kvo
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    [self addObserver:self forKeyPath:@"state" options:options context:nil];
    [self addObserver:self forKeyPath:@"progress" options:options context:nil];
    [self addObserver:self forKeyPath:@"playError" options:options context:nil];
    [self addObserver:self forKeyPath:@"currentTime" options:options context:nil];
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if ([keyPath isEqualToString:@"state"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:state:)]) {
            if ([change[@"new"] intValue] != [change[@"old"] intValue]) {
                KJPlayerState state = (KJPlayerState)[change[@"new"] intValue];
                PLAYERLogOneInfo(@"-- 🎷当前播放器状态 - %@",KJPlayerStateStringMap[state]);
                kGCD_player_main(^{
                    [self.delegate kj_player:self state:state];
                });
                // 心跳相关操作，`KJBasePlayer+KJPingTimer`
                SEL sel = NSSelectorFromString(@"kj_pingTimerWithState:");
                if ([self respondsToSelector:sel]) {
                    IMP imp = [self methodForSelector:sel];
                    void (* tempFunc)(id target, SEL, KJPlayerState) = (void *)imp;
                    tempFunc(self, sel, state);
                }
            }
        }
    } else if ([keyPath isEqualToString:@"progress"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:loadProgress:)]) {
            if (self.totalTime<=0) return;
            CGFloat new = [change[@"new"] floatValue], old = [change[@"old"] floatValue];
            if (new != old || (new == 0 && old == 0)) {
                PLAYERLogTwoInfo(@"-- 😪当前播放进度:%.2f",new);
                kGCD_player_main(^{
                    [self.delegate kj_player:self loadProgress:new];
                });
            }
        }
    } else if ([keyPath isEqualToString:@"playError"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:playFailed:)]) {
            if (change[@"new"] != change[@"old"]) {
                kGCD_player_main(^{
                    [self.delegate kj_player:self playFailed:change[@"new"]];
                });
            }
        }
    } else if ([keyPath isEqualToString:@"currentTime"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:currentTime:)]) {
            CGFloat new = [change[@"new"] floatValue], old = [change[@"old"] floatValue];
            if (new != old || (new == 0 && old == 0)) {
                PLAYERLogTwoInfo(@"-- 🥁当前播放时间:%.2f",new);
                kGCD_player_main(^{
                    [self.delegate kj_player:self currentTime:new];
                });
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSNotification

/// 进入后台
- (void)kj_detectAppEnterBackground:(NSNotification *)notification{
    if (self.backgroundPause) {
        [self kj_pause];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    } else {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    //手机静音下也可播放声音
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}
/// 进入前台
- (void)kj_detectAppEnterForeground:(NSNotification *)notification{
    if (self.roregroundResume && self.userPause == NO && ![self isPlaying]) {
        [self kj_resume];
    }
}
/// 控件载体位置和尺寸发生变化
- (void)kj_basePlayerViewChange:(NSNotification *)notification{
    SEL sel = NSSelectorFromString(@"kj_displayPictureWithSize:");
    if ([self respondsToSelector:sel]) {
        CGRect rect = [notification.userInfo[kPlayerBaseViewChangeKey] CGRectValue];
        IMP imp = [self methodForSelector:sel];
        void (* tempFunc)(id target, SEL, CGSize) = (void *)imp;
        tempFunc(self, sel, rect.size);
    }
}

#pragma mark - child method, subclass should override.

/// 准备播放 
- (void)kj_play{ }
/// 重播 
- (void)kj_replay{ }
/// 继续 
- (void)kj_resume{ }
/// 暂停 
- (void)kj_pause{
    // 心跳相关操作，`KJBasePlayer+KJPingTimer`
    kPlayerPerformSel(self, @"kj_pausePingTimer");
}
/// 停止 
- (void)kj_stop{
    // 心跳相关操作，`KJBasePlayer+KJPingTimer`
    kPlayerPerformSel(self, @"kj_closePingTimer");
}
/// 指定时间播放
/// @param time 指定时间
- (void)kj_appointTime:(NSTimeInterval)time {
    
}

#pragma mark - private subclass method

/// 功能处理，名字不能修改
- (void)kj_subclassFunction{
#pragma mark - 记录播放/跳过片头
//    if (self.recordLastTime) {
//        NSTimeInterval time = [DBPlayerData kj_getLastTimeDbid:kPlayerIntactName(self.originalURL)];
//        if (self.recordTimeBlock) {
//            kGCD_player_main(^{
//                self.recordTimeBlock(time);
//            });
//        }
//        self.kVideoAdvanceAndReverse(time,nil);
//    }else if (self.skipHeadTime) {
//        if (self.skipTimeBlock) {
//            kGCD_player_main(^{
//                self.skipTimeBlock(KJPlayerVideoSkipStateHead);
//            });
//        }
//        self.kVideoAdvanceAndReverse(self.skipHeadTime,nil);
//    } else {
//        [self kj_autoPlay];
//    }
}

#pragma mark - public method

/// 判断是否为本地缓存视频，如果是则修改为指定链接地址
- (BOOL)kj_judgeHaveCacheWithVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL{
    if ([KJCacheManager kj_haveCacheURL:videoURL]) {
        self.playError = [KJCustomManager kj_errorSummarizing:KJPlayerCustomCodeCachedComplete];
        return YES;
    }
    return NO;
}

@end
