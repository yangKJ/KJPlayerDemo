//
//  KJLoadingPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJLoadingPlayerVC.h"

@interface KJLoadingPlayerVC ()<KJPlayerDelegate>{
    int index;
}

@end

@implementation KJLoadingPlayerVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.basePlayerView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width*9/16.);
    self.player.delegate = self;
    
    self.player.kVideoHintTextProperty(110, [UIColor.greenColor colorWithAlphaComponent:0.3], UIColor.greenColor, [UIFont systemFontOfSize:15]);
    [self.player kj_displayHintText:@"顺便测试一下文本提示框打很长很长的文字提供九种位置选择" time:0 position:KJPlayerHintPositionLeftCenter];
    {
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake(30, 350, 100, 50);
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateSelected)];
        [button setTitle:@"取消加载" forState:(UIControlStateNormal)];
        [button setTitle:@"开始加载" forState:(UIControlStateSelected)];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }{
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake(self.view.frame.size.width-100-30, 350, 100, 50);
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitle:@"切换位置" forState:(UIControlStateNormal)];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(buttonAction2:) forControlEvents:(UIControlEventTouchUpInside)];
    }
}
- (void)buttonAction:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player kj_stopAnimation];
    }else{
        [self.player kj_startAnimation];
    }
}
- (void)buttonAction2:(UIButton*)sender{
    NSArray *temps = @[KJPlayerHintPositionCenter,
                       KJPlayerHintPositionBottom,
                       KJPlayerHintPositionLeftBottom,
                       KJPlayerHintPositionRightBottom,
                       KJPlayerHintPositionLeftTop,
                       KJPlayerHintPositionRightTop,
                       KJPlayerHintPositionTop,
                       KJPlayerHintPositionLeftCenter,
                       KJPlayerHintPositionRightCenter
    ];
    index++;
    if (index>=temps.count) {
        index = 0;
    }
    [self.player kj_displayHintText:@"两秒后消失!!" time:2 position:temps[index]];
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
