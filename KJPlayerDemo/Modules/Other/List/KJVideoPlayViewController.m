//
//  KJVideoPlayViewController.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJVideoPlayViewController.h"

@interface KJVideoPlayViewController () <KJPlayerDelegate>

@property(nonatomic,strong)KJAVPlayer *player;
@property(nonatomic,strong)UISlider *slider;
@property(nonatomic,strong)UIProgressView *progressView;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)UIActivityIndicatorView *loadingView;

@end

@implementation KJVideoPlayViewController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)willMoveToParentViewController:(UIViewController*)parent{
    [super willMoveToParentViewController:parent];
}
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    //侧滑返回监听
    if(parent == nil){
        [self.player kj_stop];
        _player = nil;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView = progressView;
    progressView.frame = CGRectMake(10, self.view.bounds.size.height-35, self.view.bounds.size.width-20, 30);
    progressView.progressTintColor = [UIColor.redColor colorWithAlphaComponent:0.8];
    [progressView setProgress:0.0 animated:NO];
    [self.view addSubview:progressView];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(7, 0, self.view.bounds.size.width-14, 30)];
    self.slider = slider;
    slider.backgroundColor = UIColor.clearColor;
    slider.center = _progressView.center;
    slider.minimumValue = 0.0;
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(sliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    
    KJBasePlayerView *backview = [[KJBasePlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-128)];
    backview.center = self.view.center;
    [self.view addSubview:backview];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlayerViewAction:)];
    [backview addGestureRecognizer:tap];
    
    if (@available(iOS 13.0, *)) {
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    } else {
        // Fallback on earlier versions
    }
    _loadingView.center = self.view.center;
    CGAffineTransform transform = CGAffineTransformMakeScale(2.2, 2.2);
    _loadingView.transform = transform;
    [_loadingView startAnimating];
    [self.view addSubview:self.loadingView];
    
    KJAVPlayer *player = [[KJAVPlayer alloc] init];
    self.player = player;
    player.playerView = backview;
    player.delegate = self;
    player.videoURL = self.url;
}
- (void)tapPlayerViewAction:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.player isPlaying]) {
            [self.player kj_pause];
        } else {
            [self.player kj_resume];
        }
    }
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
            [self.player kj_appointTime:second];
        } break;
        default:
            break;
    }
}

#pragma mark - KJPlayerDelegate

/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state{
    if (state == KJPlayerStateBuffering) {
        [self.loadingView startAnimating];
    } else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
        [self.loadingView stopAnimating];
    } else if (state == KJPlayerStatePlayFinished) {
        [player kj_replay];
    }
}
/* 播放进度 */
- (void)kj_player:(KJBasePlayer*)player currentTime:(CGFloat)time{
    self.slider.value = time;
}
/* 缓存进度 */
- (void)kj_player:(KJBasePlayer*)player loadProgress:(CGFloat)progress{
    [self.progressView setProgress:progress animated:YES];
}
/// 视频总时长
/// @param player 播放器内核
/// @param time 总时间
- (void)kj_player:(__kindof KJBasePlayer *)player videoTime:(NSTimeInterval)time{
    self.slider.maximumValue = time;
}

@end
