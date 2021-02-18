//
//  BaseViewController.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "BaseViewController.h"

@interface BaseViewController ()

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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PLAYER_UIColorFromHEXA(0xf5f5f5, 1);
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 40)];
    [backButton setImage:[UIImage imageNamed:@"Arrow"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
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
    backview.image = [UIImage imageNamed:@"20ea53a47eb0447883ed186d9f11e410"];
    self.basePlayerView = backview;
    [self.view addSubview:backview];
    backview.userInteractionEnabled = YES;
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
    
    KJPlayer *player = [[KJPlayer alloc]init];
    self.player = player;
    player.placeholder = backview.image;
    player.playerView = backview;
    [player kj_startAnimation];
    player.roregroundResume = YES;
    player.kVideoTotalTime = ^(NSTimeInterval time) {
        slider.maximumValue = time;
        label3.text = kPlayerConvertTime(time);
    };
    player.kVideoURLFromat = ^(KJPlayerVideoFromat fromat) {
        NSLog(@"fromat:%@",KJPlayerVideoFromatStringMap[fromat]);
    };
    player.kVideoSize = ^(CGSize size) {
        NSLog(@"%.2f,%.2f",size.width,size.height);
    };
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

@end
