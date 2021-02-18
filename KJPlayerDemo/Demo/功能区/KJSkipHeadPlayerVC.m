//
//  KJSkipHeadPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJSkipHeadPlayerVC.h"

@interface KJSkipHeadPlayerVC ()<KJPlayerDelegate>

@end

@implementation KJSkipHeadPlayerVC
- (void)viewDidLoad {
    [super viewDidLoad];

    self.basePlayerView.frame = CGRectMake(0, (self.view.frame.size.height-self.view.frame.size.width)/2-32, self.view.frame.size.width, self.view.frame.size.width);
    self.player.delegate = self;
    self.player.kVideoSkipTime(^(KJPlayerVideoSkipState skipState) {
        if (skipState == KJPlayerVideoSkipStateHead) {
            [self.player kj_displayHintText:@"跳过片头，自动播放" time:5 position:KJPlayerHintPositionLeftBottom];
        }
    }, 34, 0);
    self.player.videoURL = [NSURL URLWithString:@"http://hls.cntv.myalicdn.com/asp/hls/2000/0303000a/3/default/bca293257d954934afadfaa96d865172/2000.m3u8"];
//    self.player.kVideoCanCacheURL([NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"], YES);
    self.player.kVideoHintTextProperty(200, [UIColor.greenColor colorWithAlphaComponent:0.3], UIColor.greenColor, [UIFont systemFontOfSize:15]);
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBaseCommonPlayer*)player state:(KJPlayerState)state{
    NSLog(@"---当前播放器状态:%@",KJPlayerStateStringMap[state]);
    if (state == KJPlayerStateBuffering) {
        [player kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay) {
        [player kj_stopAnimation];
    }else if (state == KJPlayerStatePlaying) {
        [player kj_stopAnimation];
    }else if (state == KJPlayerStatePlayFinished) {
        [player kj_replay];
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
