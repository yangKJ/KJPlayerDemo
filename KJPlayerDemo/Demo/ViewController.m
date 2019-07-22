//
//  ViewController.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "ViewController.h"
#import "KJPlayer.h"

@interface ViewController ()<KJPlayerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16)];
    view.backgroundColor = UIColor.cyanColor;
    [self.view addSubview:view];
    
    NSURL *url = [NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"];
    
    KJPlayer *player = [KJPlayer sharedInstance];
    player.playerDelegate = self;
    AVPlayerLayer *playerLayer = [player kj_playWithUrl:url];
    [player kj_seekToTime:player.videoTotalTime - 10];
    playerLayer.frame = view.bounds;
    [view.layer addSublayer:playerLayer];
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

@end
