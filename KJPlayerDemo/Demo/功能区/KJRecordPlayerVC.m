//
//  KJRecordPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJRecordPlayerVC.h"

@interface KJRecordPlayerVC ()<KJPlayerDelegate>

@end

@implementation KJRecordPlayerVC
- (void)backItemClick{
    [self.player kj_saveRecordLastTime];
    [super backItemClick];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.basePlayerView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width*9/16.);
    self.player.delegate = self;
    self.player.kVideoRecordLastTime(^(NSTimeInterval time) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setValue:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];
        [attributes setValue:UIColor.redColor forKey:NSForegroundColorAttributeName];
        NSString *timeString = [NSString stringWithFormat:@"从上次观看时间 %@ 开始播放",kPlayerConvertTime(time)];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:timeString attributes:attributes];
        NSMutableDictionary *attributes2 = [NSMutableDictionary dictionary];
        [attributes2 setValue:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];
        [attributes2 setValue:UIColor.whiteColor forKey:NSForegroundColorAttributeName];
        [string setAttributes:attributes2 range:NSMakeRange(0, 7)];
        [string setAttributes:attributes2 range:NSMakeRange(timeString.length-4, 4)];
        [self.player kj_displayHintText:string time:10 position:KJPlayerHintPositionCenter];
    }, YES);
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
