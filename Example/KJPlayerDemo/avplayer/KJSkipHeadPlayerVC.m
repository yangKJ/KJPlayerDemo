//
//  KJSkipHeadPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJSkipHeadPlayerVC.h"

#if __has_include(<KJPlayer/KJBasePlayer+KJSkipTime.h>)

#import <KJPlayer/KJBasePlayer+KJSkipTime.h>

@interface KJSkipHeadPlayerVC () <KJPlayerDelegate, KJPlayerSkipDelegate>

@end

@implementation KJSkipHeadPlayerVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.basePlayerView.frame = CGRectMake(0, (self.view.frame.size.height-self.view.frame.size.width)/2-32, self.view.frame.size.width, self.view.frame.size.width);
    self.player.delegate = self;
    self.player.skipDelegate = self;
    self.player.videoURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2020-12-27/a86e0cb5d0ea55cd4864a6fc7609dce8.mp4"];
    [self.basePlayerView.hintTextLayer kj_setHintFont:[UIFont systemFontOfSize:15]
                                            textColor:UIColor.greenColor
                                           background:[UIColor.greenColor colorWithAlphaComponent:0.3]
                                             maxWidth:200];
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state{
    if (state == KJPlayerStateBuffering) {
        [self.basePlayerView.loadingLayer kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay) {
        [self.basePlayerView.loadingLayer kj_stopAnimation];
    }else if (state == KJPlayerStatePlaying) {
        [self.basePlayerView.loadingLayer kj_stopAnimation];
    }else if (state == KJPlayerStatePlayFinished) {
        [player kj_replay];
    }else if (state == KJPlayerStatePausing) {
        [self.basePlayerView.loadingLayer kj_startAnimation];
        [self.basePlayerView.hintTextLayer kj_displayHintText:@"暂停ing"
                                                         time:5
                                                     position:KJPlayerHintPositionLeftBottom];
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

#pragma mark - KJPlayerSkipDelegate

- (NSTimeInterval)kj_skipHeadTimeWithPlayer:(__kindof KJBasePlayer *)player{
    return 18;
}

- (void)kj_skipTimeWithPlayer:(__kindof KJBasePlayer *)player
                  currentTime:(NSTimeInterval)currentTime
                    totalTime:(NSTimeInterval)totalTime
                    skipState:(KJPlayerVideoSkipState)skipState{
    if (skipState == KJPlayerVideoSkipStateHead) {
        [self.basePlayerView.hintTextLayer kj_displayHintText:@"跳过片头，自动播放"
                                                         time:5
                                                     position:KJPlayerHintPositionLeftBottom];
    }
}

@end

#endif
