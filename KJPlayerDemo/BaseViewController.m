//
//  BaseViewController.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "BaseViewController.h"

@interface BaseViewController ()<KJPlayerBaseViewDelegate>

@end

@implementation BaseViewController
- (void)dealloc{
    // 只要控制器执行此方法，代表VC以及其控件全部已安全从内存中撤出。
    // ARC除去了手动管理内存，但不代表能控制循环引用，虽然去除了内存销毁概念，但引入了新的概念--对象被持有。
    // 框架在使用后能完全从内存中销毁才是最好的优化
    // 不明白ARC和内存泄漏的请自行谷歌，此示例已加入内存检测功能，如果有内存泄漏会alent进行提示
    NSLog(@"\n控制器%@已销毁",self);
}
- (void)backItemClick{
    [self.player kj_stop];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PLAYER_UIColorFromHEXA(0xf5f5f5, 1);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"ㄑ" style:(UIBarButtonItemStyleDone) target:self action:@selector(backItemClick)];
    
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
    
    KJBasePlayerView *backview = [[KJBasePlayerView alloc]initWithFrame:CGRectMake(0, PLAYER_STATUSBAR_NAVIGATION_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height-PLAYER_STATUSBAR_NAVIGATION_HEIGHT-PLAYER_BOTTOM_SPACE_HEIGHT-74)];
    backview.image = [UIImage imageNamed:@"20ea53a47eb0447883ed186d9f11e410"];
    self.basePlayerView = backview;
    [self.view addSubview:backview];
    backview.delegate = self;
    backview.gestureType = KJPlayerGestureTypeAll;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-25-PLAYER_BOTTOM_SPACE_HEIGHT, self.view.bounds.size.width-10, 20)];
    label.textAlignment = 2;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor.blueColor colorWithAlphaComponent:0.7];
    [self.view addSubview:label];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, self.view.bounds.size.height-69-PLAYER_BOTTOM_SPACE_HEIGHT, self.view.bounds.size.width-10, 20)];
    self.label = label2;
    label2.textAlignment = 0;
    label2.font = [UIFont systemFontOfSize:14];
    label2.textColor = [UIColor.redColor colorWithAlphaComponent:0.7];
    [self.view addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-69-PLAYER_BOTTOM_SPACE_HEIGHT, self.view.bounds.size.width-10, 20)];
    label3.textAlignment = 2;
    label3.font = [UIFont systemFontOfSize:14];
    label3.textColor = [UIColor.redColor colorWithAlphaComponent:0.7];
    [self.view addSubview:label3];
    
    KJAVPlayer *player = [[KJAVPlayer alloc]init];
    self.player = player;
    player.placeholder = backview.image;
    player.playerView = backview;
    [player kj_startAnimation];
    player.roregroundResume = YES;
    player.kVideoTotalTime = ^(NSTimeInterval time) {
        slider.maximumValue = time;
        label3.text = kPlayerConvertTime(time);
    };
    player.kVideoSize = ^(CGSize size) {
        NSLog(@"%.2f,%.2f",size.width,size.height);
    };
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

#pragma mark - KJPlayerBaseViewDelegate
/* 单双击手势反馈 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view isSingleTap:(BOOL)tap{
    if (tap) {
        
    }else{
        if ([self.player isPlaying]) {
            [self.player kj_pause];
        }else{
            [self.player kj_resume];
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

@end
