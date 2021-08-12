//
//  KJIJKPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/3/7.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJIJKPlayerVC.h"

@interface KJIJKPlayerVC () <KJPlayerDelegate,KJPlayerBaseViewDelegate>

@property(nonatomic,strong)KJIJKPlayer *player;
@property(nonatomic,strong)KJBasePlayerView *basePlayerView;
@property(nonatomic,strong)NSArray *temps;
@property(nonatomic,strong)UISlider *slider;
@property(nonatomic,strong)UILabel *label;
@property(nonatomic,strong)UILabel *label3;
@property(nonatomic,strong)UIProgressView *progressView;

@end

@implementation KJIJKPlayerVC
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_player) {
        [self.player kj_stop];
        _player = nil;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PLAYER_UIColorFromHEXA(0xf5f5f5, 1);
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView = progressView;
    progressView.frame = CGRectMake(10, self.view.bounds.size.height-35-PLAYER_BOTTOM_SPACE_HEIGHT, self.view.bounds.size.width-20, 30);
    progressView.progressTintColor = [UIColor.redColor colorWithAlphaComponent:0.8];
    [progressView setProgress:0.0 animated:NO];
    [self.view addSubview:progressView];
    
    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(7, 0, self.view.bounds.size.width-14, 30)];
    self.slider = slider;
    slider.backgroundColor = UIColor.clearColor;
    slider.center = _progressView.center;
    slider.minimumValue = 0.0;
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(sliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-25-PLAYER_BOTTOM_SPACE_HEIGHT, self.view.bounds.size.width-10, 20)];
    label1.textAlignment = 2;
    label1.font = [UIFont systemFontOfSize:14];
    label1.textColor = [UIColor.blueColor colorWithAlphaComponent:0.7];
    [self.view addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, self.view.bounds.size.height-69-PLAYER_BOTTOM_SPACE_HEIGHT, self.view.bounds.size.width-10, 20)];
    self.label = label2;
    label2.textAlignment = 0;
    label2.font = [UIFont systemFontOfSize:14];
    label2.textColor = [UIColor.redColor colorWithAlphaComponent:0.7];
    [self.view addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-69-PLAYER_BOTTOM_SPACE_HEIGHT, self.view.bounds.size.width-10, 20)];
    self.label3 = label3;
    label3.textAlignment = 2;
    label3.font = [UIFont systemFontOfSize:14];
    label3.textColor = [UIColor.redColor colorWithAlphaComponent:0.7];
    [self.view addSubview:label3];
    
    KJBasePlayerView *backview = [[KJBasePlayerView alloc]initWithFrame:CGRectMake(0, PLAYER_STATUSBAR_NAVIGATION_HEIGHT, self.view.frame.size.width, self.view.frame.size.width*9/16.)];
    self.basePlayerView = backview;
    [self.view addSubview:backview];
    backview.delegate = self;
    backview.gestureType = KJPlayerGestureTypeAll;
    
    KJIJKPlayer *player = [[KJIJKPlayer alloc]init];
    self.player = player;
    player.placeholder = [UIImage imageNamed:@"Nini"];
    player.playerView = backview;
    player.cacheTime = 5;
    player.delegate = self;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.basePlayerView.frame)+30, self.view.bounds.size.width-40, 20)];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor.blueColor colorWithAlphaComponent:0.8];
    label.text = @"直播流媒体测试，仅供测试参考!!!";
    [self.view addSubview:label];
    
    self.temps = @[
        @"http://hls.cntv.myalicdn.com/asp/hls/450/0303000a/3/default/bca293257d954934afadfaa96d865172/450.m3u8",
        @"http://hls.cntv.myalicdn.com/asp/hls/850/0303000a/3/default/bca293257d954934afadfaa96d865172/850.m3u8",
        @"http://hls.cntv.myalicdn.com/asp/hls/1200/0303000a/3/default/bca293257d954934afadfaa96d865172/1200.m3u8",
        @"http://hls.cntv.myalicdn.com/asp/hls/2000/0303000a/3/default/bca293257d954934afadfaa96d865172/2000.m3u8"
    ];
    NSArray *names = @[@"流畅",@"高清",@"超清",@"蓝光"];
    CGFloat w = (self.view.frame.size.width-80)/3;
    CGFloat h = w/2.5;
    CGFloat y = CGRectGetMaxY(label.frame)+20;
    for (int i = 0; i<self.temps.count; i++) {
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake(20+(i%3)*(w+20), y+(i/3)*(h+20), w, h);
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitle:names[i] forState:(UIControlStateNormal)];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.tag = 520 + i;
        [self.view addSubview:button];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    
    self.player.videoURL = [NSURL URLWithString:self.temps[3]];
}
- (void)buttonAction:(UIButton*)sender{
    self.player.videoURL = [NSURL URLWithString:self.temps[sender.tag-520]];
}
///进度条的拖拽事件 监听UISlider拖动状态
- (void)sliderValueChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch *touchEvent = [[event allTouches]anyObject];
    switch(touchEvent.phase) {
        case UITouchPhaseBegan:
            [self.player kj_pause];
            break;
        case UITouchPhaseMoved:
            break;
        case UITouchPhaseEnded:{
            CGFloat second = slider.value;
            [slider setValue:second animated:YES];
            self.player.kVideoAdvanceAndReverse(second,nil);
        }
            break;
        default:
            break;
    }
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
    
}
/* 缓存进度 */
- (void)kj_player:(KJBasePlayer*)player loadProgress:(CGFloat)progress{
    
}
/* 播放错误 */
- (void)kj_player:(KJBasePlayer*)player playFailed:(NSError*)failed{
    
}
/// 视频总时长
/// @param player 播放器内核
/// @param time 总时间
- (void)kj_player:(__kindof KJBasePlayer *)player videoTime:(NSTimeInterval)time{
    self.slider.maximumValue = time;
    self.label3.text = kPlayerConvertTime(time);
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
            [self.basePlayerView.loadingLayer kj_startAnimation];
        }else{
            [self.player kj_resume];
            [self.basePlayerView.loadingLayer kj_stopAnimation];
        }
    }
}
/* 长按手势反馈 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view longPress:(UILongPressGestureRecognizer*)longPress{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            self.player.speed = 2.;
            [self.basePlayerView.hintTextLayer kj_displayHintText:@"长按快进播放中..." time:0 position:KJPlayerHintPositionTop];
        }
            break;
        case UIGestureRecognizerStateChanged: {
        }
            break;
        case UIGestureRecognizerStateEnded: {
            self.player.speed = 1.0;
            [self.basePlayerView.hintTextLayer kj_hideHintText];
        }
        default:
            break;
    }
}
/* 进度手势反馈，是否替换自带UI，范围-1 ～ 1 */
- (KJPlayerTime*)kj_basePlayerView:(KJBasePlayerView*)view progress:(float)progress end:(BOOL)end{
    if (end) {
        NSTimeInterval time = self.player.currentTime + progress * self.player.totalTime;
        NSLog(@"---time:%.2f",time);
        self.player.kVideoAdvanceAndReverse(time, nil);
    }
    KJPlayerTime * ptime = [[KJPlayerTime alloc] init];
    ptime.currentTime = self.player.currentTime;
    ptime.totalTime = self.player.totalTime;
    return ptime;
}
/* 音量手势反馈，是否替换自带UI，范围0 ～ 1 */
- (BOOL)kj_basePlayerView:(KJBasePlayerView*)view volumeValue:(float)value{
    self.player.volume = value;
    return NO;
}
/* 亮度手势反馈，是否替换自带UI，范围0 ～ 1 */
- (BOOL)kj_basePlayerView:(KJBasePlayerView*)view brightnessValue:(float)value{
    NSLog(@"---lightValue:%.2f",value);
    return NO;
}
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view clickBack:(BOOL)clickBack{
    if (view.isFullScreen) {
        view.isFullScreen = NO;
    }else{
        [self.player kj_stop];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view screenState:(KJPlayerVideoScreenState)screenState{
    if (screenState == KJPlayerVideoScreenStateFullScreen) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

@end
