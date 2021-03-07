//
//  KJDetailPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJDetailPlayerVC.h"

@interface KJDetailPlayerVC ()<KJPlayerBaseViewDelegate>
@property(nonatomic,strong)KJBasePlayerView *playerView;

@end

@implementation KJDetailPlayerVC
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.kBackBlock) {
        self.kBackBlock();
    }
}
- (void)backItemClick{
    if (self.kBackBlock) {
        self.kBackBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    KJBasePlayerView *backview = [[KJBasePlayerView alloc]initWithFrame:CGRectMake(0, PLAYER_STATUSBAR_NAVIGATION_HEIGHT, self.view.frame.size.width, self.view.frame.size.width)];
    backview.image = [UIImage imageNamed:@"20ea53a47eb0447883ed186d9f11e410"];
    [self.view addSubview:backview];
    self.playerView = backview;
    backview.delegate = self;
    backview.gestureType = KJPlayerGestureTypeAll;
    PLAYER_WEAKSELF;
    backview.kVideoClickButtonBack = ^(KJBasePlayerView *view){
        if (view.isFullScreen) {
            view.isFullScreen = NO;
        }else{
            [weakself backItemClick];
        }
    };
    backview.kVideoChangeScreenState = ^(KJPlayerVideoScreenState state) {
        if (state == KJPlayerVideoScreenStateFullScreen) {
            [weakself.navigationController setNavigationBarHidden:YES animated:YES];
        }else{
            [weakself.navigationController setNavigationBarHidden:NO animated:YES];
        }
    };
    
    self.layer.frame = backview.bounds;
    [backview.layer addSublayer:self.layer];
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake((self.view.frame.size.width-100)/2, self.view.frame.size.height - 150, 100, 50);
    button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
    [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [button setTitle:@"全屏" forState:(UIControlStateNormal)];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:(UIControlEventTouchUpInside)];
}
- (void)buttonAction{
    self.playerView.isFullScreen = YES;
}

#pragma mark - KJPlayerBaseViewDelegate
/* 单双击手势反馈 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view isSingleTap:(BOOL)tap{
    if (tap) {
        if (view.displayOperation) {
            [view kj_hiddenOperationView];
        }else{
            [view kj_displayOperationView];
        }
    }else{
        if ([self.player isPlaying]) {
            [self.player kj_pause];
            [self.player kj_startAnimation];
        }else{
            [self.player kj_resume];
            [self.player kj_stopAnimation];
        }
    }
}
/* 长按手势反馈 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view longPress:(UILongPressGestureRecognizer*)longPress{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            self.player.speed = 2.;
            [self.player kj_displayHintText:@"长按快进播放中..." time:0 position:KJPlayerHintPositionTop];
        }
            break;
        case UIGestureRecognizerStateChanged: {
        }
            break;
        case UIGestureRecognizerStateEnded: {
            self.player.speed = 1.0;
            [self.player kj_hideHintText];
        }
        default:
            break;
    }
}
/* 进度手势反馈，是否替换自带UI，范围-1 ～ 1 */
- (NSArray*)kj_basePlayerView:(KJBasePlayerView*)view progress:(float)progress end:(BOOL)end{
    if (end) {
        NSTimeInterval time = self.player.currentTime + progress * self.player.totalTime;
        NSLog(@"---time:%.2f",time);
        self.player.kVideoAdvanceAndReverse(time, nil);
    }
    return @[@(self.player.currentTime),@(self.player.totalTime)];
}
/* 音量手势反馈，是否替换自带UI，范围0 ～ 1 */
- (BOOL)kj_basePlayerView:(KJBasePlayerView*)view volumeValue:(float)value{
    NSLog(@"---voiceValue:%.2f",value);
    return NO;
}
/* 亮度手势反馈，是否替换自带UI，范围0 ～ 1 */
- (BOOL)kj_basePlayerView:(KJBasePlayerView*)view brightnessValue:(float)value{
    NSLog(@"---lightValue:%.2f",value);
    return NO;
}
- (void)kj_basePlayerView:(KJBasePlayerView *)view{
    
}

@end
