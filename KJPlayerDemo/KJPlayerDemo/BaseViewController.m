//
//  BaseViewController.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "BaseViewController.h"

#if __has_include(<KJPlayer/KJBasePlayer+KJBackgroundMonitoring.h>)
#import <KJPlayer/KJBasePlayer+KJBackgroundMonitoring.h>
#endif

@interface BaseViewController () <KJPlayerDelegate, KJPlayerBaseViewDelegate>

@property (nonatomic, strong) UILabel *label3;

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"🔙" style:(UIBarButtonItemStyleDone) target:self action:@selector(backItemClick)];
    
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
    
    KJBasePlayerView *backview = [[KJBasePlayerView alloc]initWithFrame:CGRectMake(0, PLAYER_STATUSBAR_NAVIGATION_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height-PLAYER_STATUSBAR_NAVIGATION_HEIGHT-PLAYER_BOTTOM_SPACE_HEIGHT-74)];
    backview.image = [UIImage imageNamed:@"Nini"];
    self.basePlayerView = backview;
    [self.view addSubview:backview];
    backview.delegate = self;
    backview.gestureType = KJPlayerGestureTypeAll;
    backview.autoRotate = NO;
    
    KJAVPlayer *player = [[KJAVPlayer alloc]init];
    self.player = player;
    player.delegate = self;
#if __has_include(<KJPlayer/KJBasePlayer+KJBackgroundMonitoring.h>)
    player.roregroundResume = YES;
#endif
    player.placeholder = backview.image;
    player.playerView = backview;
    [backview.loadingLayer kj_startAnimation];
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
        default:break;
    }
}

/// 视频总时长
/// @param player 播放器内核
/// @param time 总时间
- (void)kj_player:(__kindof KJBasePlayer *)player videoTime:(NSTimeInterval)time{
    NSLog(@"🎷🎷🎷 视频总时长 time = %.2f",time);
    self.slider.maximumValue = time;
    self.label3.text = kPlayerConvertTime(time);
}

/// 获取视频尺寸大小
/// @param player 播放器内核
/// @param size 视频尺寸
- (void)kj_player:(__kindof KJBasePlayer *)player videoSize:(CGSize)size{
    NSLog(@"🎷🎷🎷 视频大小尺寸 width = %.2f, height = %.2f",size.width,size.height);
}


#pragma mark - KJPlayerBaseViewDelegate

/// 单双击手势反馈
/// @param view 播放器控件载体
/// @param tap 是否为单击
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view isSingleTap:(BOOL)tap{
    if (tap == NO) {
        if ([self.player isPlaying]) {
            [self.player kj_pause];
        } else {
            [self.player kj_resume];
        }
    }
}

/// 长按手势反馈
/// @param view 播放器控件载体
/// @param longPress 长按手势
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view longPress:(UILongPressGestureRecognizer *)longPress{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:{
            self.player.speed = 2.;
            [self.basePlayerView.hintTextLayer kj_displayHintText:@"长按快进播放中..."
                                                                time:0
                                                            position:KJPlayerHintPositionTop];
        } break;
        case UIGestureRecognizerStateChanged:{
            
        } break;
        case UIGestureRecognizerStateEnded:{
            self.player.speed = 1.0;
            [self.basePlayerView.hintTextLayer kj_hideHintText];
        } break;
        default:break;
    }
}

/// 进度手势反馈
/// @param view 播放器控件载体
/// @param progress 进度范围，-1 到 1
/// @param end 是否结束
/// @return 不替换UI请返回当前时间和总时间
- (nullable KJPlayerTime *)kj_basePlayerView:(__kindof KJBasePlayerView *)view
                                progress:(float)progress
                                    end:(BOOL)end{
    if (end) {
        NSTimeInterval time = self.player.currentTime + progress * self.player.totalTime;
        [self.player kj_appointTime:time];
    }
    return [KJPlayerTime createWithCurrentTime:self.player.currentTime totalTime:self.player.totalTime];
}

/// 音量手势反馈
/// @param view 播放器控件载体
/// @param value 音量范围，-1 到 1
/// @return 是否替换自带UI
- (BOOL)kj_basePlayerView:(__kindof KJBasePlayerView *)view volumeValue:(float)value{
    self.player.volume = value;
    return NO;
}

/// 亮度手势反馈
/// @param view 播放器控件载体
/// @param value 亮度范围，0 到 1
/// @return 是否替换自带UI
- (BOOL)kj_basePlayerView:(__kindof KJBasePlayerView *)view brightnessValue:(float)value{
    return NO;
}

/// 按钮事件响应
/// @param view 播放器控件载体
/// @param buttonType 按钮类型，KJPlayerButtonType类型
/// @param button 当前响应按钮
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view
               buttonType:(NSUInteger)buttonType
             playerButton:(__kindof KJPlayerButton *)button{
    
}

/// 是否锁屏
/// @param view 播放器控件载体
/// @param locked 是否锁屏
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view locked:(BOOL)locked{
    
}

/// 返回按钮响应
/// @param view 播放器控件载体
/// @param clickBack 点击返回
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view clickBack:(BOOL)clickBack{
    
}

/// 当前屏幕状态发生改变
/// @param view 播放器控件载体
/// @param screenState 当前屏幕状态
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view screenState:(KJPlayerVideoScreenState)screenState{
    
}

@end

