//
//  KJChangeSourceVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/3/3.
//  Copyright © 2021 杨科军. All rights reserved.
//

#import "KJChangeSourceVC.h"

@interface KJChangeSourceVC ()<KJPlayerDelegate>
@property(nonatomic,strong)UILabel *sourceLabel;
@end

@implementation KJChangeSourceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.basePlayerView.frame = CGRectMake(0, PLAYER_STATUSBAR_NAVIGATION_HEIGHT+20, self.view.frame.size.width, self.view.frame.size.width*9/16.);
    self.player.delegate = self;
    self.player.videoURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2017-11-21/7c2b143eeb27d9f2bf98c4ab03360cfe.mp4"];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.basePlayerView.frame)+30, self.view.bounds.size.width-40, 20)];
    self.sourceLabel = label;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = [UIColor.blueColor colorWithAlphaComponent:0.7];
    label.text = [@"当前播放器内核 -- " stringByAppendingFormat:@"%@",kPlayerCurrentSourceName(self.player)];
    [self.view addSubview:label];
    {
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake((self.view.frame.size.width-100)/2, self.view.frame.size.height-180, 100, 50);
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitle:@"切换内核" forState:(UIControlStateNormal)];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }{
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake((self.view.frame.size.width-100)/2, self.view.frame.size.height-250, 100, 50);
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitle:@"切换视频" forState:(UIControlStateNormal)];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(buttonAction2:) forControlEvents:(UIControlEventTouchUpInside)];
    }
}
- (void)buttonAction:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player kj_dynamicChangeSourcePlayer:[KJIJKPlayer class]];
    }else{
        [self.player kj_dynamicChangeSourcePlayer:[KJAVPlayer class]];
    }
    self.sourceLabel.text = [@"当前播放器内核 -- " stringByAppendingFormat:@"%@",kPlayerCurrentSourceName(self.player)];
    NSString *string = [NSString stringWithFormat:@"当前内核%@",NSStringFromClass([self.player class])];
    NSLog(@"---xx---%@",string);
    [self.player kj_displayHintText:string time:5 position:KJPlayerHintPositionTop];
    self.player.videoURL = kPlayerURLCharacters(@"https://mp4.vjshi.com/2016-10-31/a553917787e52c0a077e3fb8548fae69.mp4?测试中文转义abc");
}
- (void)buttonAction2:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.player.videoURL = [NSURL URLWithString:@"http://hls.cntv.myalicdn.com/asp/hls/2000/0303000a/3/default/bca293257d954934afadfaa96d865172/2000.m3u8"];
    }else{
        self.player.videoURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"];
    }
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state{
    NSLog(@"---当前播放器状态:%@",KJPlayerStateStringMap[state]);
    if (state == KJPlayerStateBuffering || state == KJPlayerStatePausing) {
        [player kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
        [player kj_stopAnimation];
        [player kj_hideHintText];
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
    NSLog(@"---缓存进度:%f",progress);
    [self.progressView setProgress:progress animated:YES];
}
/* 播放错误 */
- (void)kj_player:(KJBasePlayer*)player playFailed:(NSError*)failed{
    
}

@end
