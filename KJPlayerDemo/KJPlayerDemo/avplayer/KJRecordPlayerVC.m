//
//  KJRecordPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJRecordPlayerVC.h"
#import <KJPlayer/KJBasePlayer+KJRecordTime.h>

@interface KJRecordPlayerVC () <KJPlayerDelegate, KJPlayerRecordDelegate>

@end

@implementation KJRecordPlayerVC
- (void)backItemClick{
    [self.player kj_saveRecordLastTime];
    [super backItemClick];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.basePlayerView.frame = CGRectMake(0, PLAYER_STATUSBAR_NAVIGATION_HEIGHT, self.view.frame.size.width, self.view.frame.size.width);
    self.player.delegate = self;
    self.player.recordDelegate = self;
    self.player.videoURL = kPlayerURLCharacters(@"https://mp4.vjshi.com/2016-10-31/a553917787e52c0a077e3fb8548fae69.mp4?测试中文转义abc");
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state{
    if (state == KJPlayerStateBuffering || state == KJPlayerStatePausing) {
        [self.basePlayerView.loadingLayer kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
        [self.basePlayerView.loadingLayer kj_stopAnimation];
    }else if (state == KJPlayerStatePlayFinished) {
        [player kj_replay];
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

#pragma mark - KJPlayerRecordDelegate

- (BOOL)kj_recordTimeWithPlayer:(__kindof KJBasePlayer *)player{
    return YES;
}

- (void)kj_recordTimeWithPlayer:(__kindof KJBasePlayer *)player totalTime:(NSTimeInterval)totalTime lastTime:(NSTimeInterval)lastTime{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setValue:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];
    [attributes setValue:UIColor.redColor forKey:NSForegroundColorAttributeName];
    NSString *timeString = [NSString stringWithFormat:@"从上次观看时间 %@ 开始播放",kPlayerConvertTime(lastTime)];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:timeString attributes:attributes];
    NSMutableDictionary *attributes2 = [NSMutableDictionary dictionary];
    [attributes2 setValue:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];
    [attributes2 setValue:UIColor.whiteColor forKey:NSForegroundColorAttributeName];
    [string setAttributes:attributes2 range:NSMakeRange(0, 7)];
    [string setAttributes:attributes2 range:NSMakeRange(timeString.length-4, 4)];
    [self.basePlayerView.hintTextLayer kj_displayHintText:string time:5 position:KJPlayerHintPositionCenter];
}

@end
