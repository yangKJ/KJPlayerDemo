//
//  KJM3u8PlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJM3u8PlayerVC.h"

@interface KJM3u8PlayerVC ()<KJPlayerDelegate>

@end

@implementation KJM3u8PlayerVC
- (void)viewDidLoad {
    [super viewDidLoad];

//@"http://hls.cntv.myalicdn.com/asp/hls/450/0303000a/3/default/bca293257d954934afadfaa96d865172/450.m3u8"
//@"http://hls.cntv.myalicdn.com/asp/hls/850/0303000a/3/default/bca293257d954934afadfaa96d865172/850.m3u8"
//@"http://hls.cntv.myalicdn.com/asp/hls/1200/0303000a/3/default/bca293257d954934afadfaa96d865172/1200.m3u8"
    
    self.basePlayerView.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width*9/16.);
    self.player.delegate = self;
    self.player.videoURL = [NSURL URLWithString:@"http://hls.cntv.myalicdn.com/asp/hls/2000/0303000a/3/default/bca293257d954934afadfaa96d865172/2000.m3u8"];
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBaseCommonPlayer*)player state:(KJPlayerState)state{
    NSLog(@"---当前播放器状态:%@",KJPlayerStateStringMap[state]);
    if (state == KJPlayerStateBuffering) {
        [player kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
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
