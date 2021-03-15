//
//  KJAVPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/31.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJAVPlayerVC.h"
#import "KJAVPlayer.h"

@interface KJAVPlayerVC ()<KJPlayerDelegate>
@property(nonatomic,strong)KJAVPlayer *player;
@property(nonatomic,strong)UISlider *slider;
@property(nonatomic,strong)UILabel *label;
@property(nonatomic,strong)UIProgressView *progressView;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)NSArray *temps;
@end

@implementation KJAVPlayerVC
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
    
    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(7, 0, self.view.bounds.size.width-14, 30)];
    self.slider = slider;
    slider.backgroundColor = UIColor.clearColor;
    slider.center = _progressView.center;
    slider.minimumValue = 0.0;
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(sliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    
    KJBasePlayerView *backview = [[KJBasePlayerView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-138)];
    [self.view addSubview:backview];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlayerViewAction:)];
    [backview addGestureRecognizer:tap];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-25, self.view.bounds.size.width-10, 20)];
    label.textAlignment = 2;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor.blueColor colorWithAlphaComponent:0.7];
    [self.view addSubview:label];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, self.view.bounds.size.height-69, self.view.bounds.size.width-10, 20)];
    self.label = label2;
    label2.textAlignment = 0;
    label2.font = [UIFont systemFontOfSize:14];
    label2.textColor = [UIColor.redColor colorWithAlphaComponent:0.7];
    [self.view addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-69, self.view.bounds.size.width-10, 20)];
    label3.textAlignment = 2;
    label3.font = [UIFont systemFontOfSize:14];
    label3.textColor = [UIColor.redColor colorWithAlphaComponent:0.7];
    [self.view addSubview:label3];
    
    self.temps = @[@"https://mp4.vjshi.com/2017-11-21/7c2b143eeb27d9f2bf98c4ab03360cfe.mp4",
                   @"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4",
                   @"https://mp4.vjshi.com/2020-07-02/c411973c6c8628e94c40cb4e2689e56b.mp4",
                   @"http://appit.winpow.com/attached/media/MP4/1567585643618.mp4",
    ];
    
    KJAVPlayer *player = [[KJAVPlayer alloc]init];
    self.player = player;
    player.playerView = backview;
    [player kj_startAnimation];
    player.delegate = self;
    player.roregroundResume = YES;
    player.kVideoTotalTime = ^(NSTimeInterval time) {
        slider.maximumValue = time;
        label3.text = kPlayerConvertTime(time);
    };
    player.videoURL = [NSURL URLWithString:self.temps[self.index]];
}
- (void)tapPlayerViewAction:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.player isPlaying]) {
            [self.player kj_pause];
        }else{
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
    if (state == KJPlayerStateBuffering) {
        [player kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
        [player kj_stopAnimation];
        [player kj_displayHintText:KJPlayerStateStringMap[state]];
    }else{
        [player kj_displayHintText:KJPlayerStateStringMap[state] position:KJPlayerHintPositionLeftBottom];
    }
    if (state == KJPlayerStatePlayFinished) {
        self.index++;
        if (self.index >= self.temps.count) {
            self.index = 0;
        }
        NSURL *video = [NSURL URLWithString:self.temps[self.index]];
        if (self.index == 0) {
            player.timeSpace = 2.5;
            player.speed = 1.25;
            player.videoURL = video;
        }else if (self.index == 1) {
            player.timeSpace = 1.;
            player.speed = 1.;
            player.openAdvanceCache = YES;
            player.videoURL = video;
            player.videoGravity = KJPlayerVideoGravityResizeAspect;
        }else{
            player.openAdvanceCache = NO;
            player.videoURL = video;
            player.kVideoTryLookTime(^{
                NSLog(@"试看时间已到");
                [player kj_startAnimation];
            }, 150);
        }
    }
}
/* 播放进度 */
- (void)kj_player:(KJBasePlayer*)player currentTime:(NSTimeInterval)time{
//    NSLog(@"---播放进度:%.2f",time);
    self.slider.value = time;
    self.label.text = kPlayerConvertTime(time);
}
/* 缓存进度 */
- (void)kj_player:(KJBasePlayer*)player loadProgress:(CGFloat)progress{
    [self.progressView setProgress:progress animated:YES];
}
/* 播放错误 */
- (void)kj_player:(KJBasePlayer*)player playFailed:(NSError*)failed{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setValue:[UIFont systemFontOfSize:18] forKey:NSFontAttributeName];
    [attributes setValue:UIColor.whiteColor forKey:NSForegroundColorAttributeName];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[@"出错咯~" stringByAppendingString:failed.domain] attributes:attributes];
    NSMutableDictionary *attributes2 = [NSMutableDictionary dictionary];
    [attributes2 setValue:[UIFont systemFontOfSize:18] forKey:NSFontAttributeName];
    [attributes2 setValue:UIColor.redColor forKey:NSForegroundColorAttributeName];
    [string setAttributes:attributes2 range:NSMakeRange(0, 4)];
    [player kj_displayHintText:string position:KJPlayerHintPositionBottom];
    if (failed.code == KJPlayerCustomCodeCachedComplete) {
        NSLog(@"缓存完成，成功存入数据库");
    }
}

@end
