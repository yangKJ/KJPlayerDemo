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
    self.player.videoURL = [NSURL URLWithString:@"http://appit.winpow.com/attached/media/MP4/1567585643618.mp4"];
    self.player.kVideoTryLookTime(^{
        NSLog(@"试看时间已到");
        [self.player kj_startAnimation];
        [self.player kj_displayHintText:@"试看时间已到，请缴费～" time:0 position:KJPlayerHintPositionBottom];
    }, 98);
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBaseCommonPlayer*)player state:(KJPlayerState)state{
    NSLog(@"---当前播放器状态:%@",KJPlayerStateStringMap[state]);
    if (state == KJPlayerStateBuffering) {
        [player kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
        [player kj_stopAnimation];
    }
}
/* 播放进度 */
- (void)kj_player:(KJBaseCommonPlayer*)player currentTime:(NSTimeInterval)time{
    self.slider.value = time;
    self.label.text = kPlayerConvertTime(time);
}
/* 缓存进度 */
- (void)kj_player:(KJBaseCommonPlayer*)player loadProgress:(CGFloat)progress{
    NSLog(@"---缓存进度:%f",progress);
    [self.progressView setProgress:progress animated:YES];
}
/* 播放错误 */
- (void)kj_player:(KJBaseCommonPlayer*)player playFailed:(NSError*)failed{
    
}

@end
