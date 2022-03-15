//
//  KJFreeViewController.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJFreeViewController.h"

#if __has_include(<KJPlayer/KJBasePlayer+KJTryTime.h>)

#import <KJPlayer/KJBasePlayer+KJTryTime.h>

@interface KJFreeViewController () <KJPlayerDelegate, KJPlayerTryLookDelegate>

@end

@implementation KJFreeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.player.delegate = self;
    self.player.tryLookDelegate = self;
    self.player.videoURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2017-11-21/7c2b143eeb27d9f2bf98c4ab03360cfe.mp4"];
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state{
    if (state == KJPlayerStateBuffering || state == KJPlayerStatePausing) {
        [self.basePlayerView.loadingLayer kj_startAnimation];
    } else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
        [self.basePlayerView.loadingLayer kj_stopAnimation];
        [self.basePlayerView.hintTextLayer kj_hideHintText];
    }
}
/* 播放进度 */
- (void)kj_player:(KJBasePlayer*)player currentTime:(NSTimeInterval)time{
    self.slider.value = time;
    self.label.text = kPlayerConvertTime(time);
}
/* 缓存进度 */
- (void)kj_player:(KJBasePlayer*)player loadProgress:(CGFloat)progress{
    [self.progressView setProgress:progress animated:YES];
}
/* 播放错误 */
- (void)kj_player:(KJBasePlayer*)player playFailed:(NSError*)failed{
    
}

#pragma mark - KJPlayerTryLookDelegate

- (NSTimeInterval)kj_tryLookTimeWithPlayer:(__kindof KJBasePlayer *)player{
    return 28;
}

- (void)kj_tryLookEndWithPlayer:(__kindof KJBasePlayer *)player currentTime:(NSTimeInterval)currentTime{
    [self.basePlayerView.loadingLayer kj_startAnimation];
    [self.basePlayerView.hintTextLayer kj_displayHintText:@"试看时间已到，请缴费～"
                                                     time:0
                                                 position:KJPlayerHintPositionBottom];
}

@end

#endif
