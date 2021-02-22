//
//  KJTryLookPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJTryLookPlayerVC.h"

@interface KJTryLookPlayerVC ()<KJPlayerDelegate>

@end

@implementation KJTryLookPlayerVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.player.delegate = self;
    self.player.videoURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2017-11-21/7c2b143eeb27d9f2bf98c4ab03360cfe.mp4"];
    PLAYER_WEAKSELF;
    self.player.kVideoTryLookTime(^{
        NSLog(@"试看时间已到");
        [weakself.player kj_startAnimation];
        [weakself.player kj_displayHintText:@"试看时间已到，请缴费～" time:0 position:KJPlayerHintPositionBottom];
    }, 28);
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state{
    NSLog(@"---当前播放器状态:%@",KJPlayerStateStringMap[state]);
    if (state == KJPlayerStateBuffering) {
        [player kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
        [player kj_stopAnimation];
        [player kj_hideHintText];
    }
}
/* 播放进度 */
- (void)kj_player:(KJBasePlayer*)player currentTime:(NSTimeInterval)time{
    self.slider.value = time;
    self.label.text = kPlayerConvertTime(time);
}
/* 缓存进度 */
- (void)kj_player:(KJBasePlayer*)player loadProgress:(CGFloat)progress{
    NSLog(@"---缓存进度:%f",progress);
    [self.progressView setProgress:progress animated:YES];
}
/* 播放错误 */
- (void)kj_player:(KJBasePlayer*)player playFailed:(NSError*)failed{
    
}

@end
