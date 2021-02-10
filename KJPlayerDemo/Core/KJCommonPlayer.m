//
//  KJCommonPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJCommonPlayer.h"

@implementation KJCommonPlayer
PLAYER_COMMON_PROPERTY
static KJCommonPlayer *_instance = nil;
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

- (instancetype)init{
    if (self == [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kj_playerAppDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kj_playerAppWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - NSNotification
//进入后台
- (void)kj_playerAppDidEnterBackground:(NSNotification *)notification{
    if (self.backgroundPause) {
        [self kj_playerPause];
    }else{
//        AVAudioSession * session = [AVAudioSession sharedInstance];
//        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//        [session setActive:YES error:nil];
    }
}
//进入前台
- (void)kj_playerAppWillEnterForeground:(NSNotification *)notification{
    if (self.roregroundResume && self.userPause == NO) {
        [self kj_playerResume];
    }
}

#pragma mark - public method
/* 准备播放 */
- (void)kj_playerPlay{ }
/* 重播 */
- (void)kj_playerReplay{ }
/* 继续 */
- (void)kj_playerResume{ }
/* 暂停 */
- (void)kj_playerPause{ }
/* 停止 */
- (void)kj_playerStop{ }

@end
