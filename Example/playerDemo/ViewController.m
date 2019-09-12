//
//  ViewController.m
//  playerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "ViewController.h"
#import <KJPlayer.h>
#import "PlayViewController.h"

@interface ViewController ()<KJPlayerDelegate>
@property(nonatomic,strong) KJPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(0, 0, 120, 30);
    button.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [button setTitle:@"自带展示区控制器" forState:(UIControlStateNormal)];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.backgroundColor = UIColor.greenColor;
    [self.view addSubview:button];
    [button addTarget:self action:@selector(butAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16)];
//    view.backgroundColor = UIColor.cyanColor;
//    [self.view addSubview:view];
//
//    NSURL *url = [NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"];
//
//    KJPlayer *player = [KJPlayer sharedInstance];
//    player.delegate = self;
//    AVPlayerLayer *playerLayer = [player kj_playerPlayWithURL:url];
//    [player kj_playerSeekToTime:0];
//    playerLayer.frame = view.bounds;
//    [view.layer addSublayer:playerLayer];
//
//    self.player = player;
}

#pragma mark - KJPlayerDelegate
- (void)kj_player:(nonnull KJPlayer *)player LoadedProgress:(CGFloat)loadedProgress LoadComplete:(BOOL)complete SaveSuccess:(BOOL)saveSuccess {
    //    NSLog(@"Load:%.2f==%d==%d",loadedProgress,complete,saveSuccess);
}

- (void)kj_player:(nonnull KJPlayer *)player Progress:(CGFloat)progress CurrentTime:(CGFloat)currentTime DurationTime:(CGFloat)durationTime {
    //    NSLog(@"Time:%.2f==%.2f==%.2f",progress,currentTime,durationTime);
}

- (void)kj_player:(nonnull KJPlayer *)player State:(KJPlayerState)state ErrorCode:(KJPlayerErrorCode)errorCode {
    NSLog(@"State:%ld==%ld",state,errorCode);
}

- (void)butAction:(UIButton*)sender{
    PlayViewController *vc = [PlayViewController new];
    vc.view.backgroundColor = UIColor.whiteColor;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    nav.navigationBar.hidden = YES;
    [self presentViewController:nav animated:YES completion:^{
//        [self.player kj_playerStop];
    }];
}


@end
