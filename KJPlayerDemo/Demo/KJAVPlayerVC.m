//
//  KJAVPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/31.
//  Copyright © 2021 杨科军. All rights reserved.
//

#import "KJAVPlayerVC.h"
#import "KJPlayer.h"
@interface KJAVPlayerVC ()<KJPlayerDelegate>
@property(nonatomic,strong)UISlider *slider;
@end

@implementation KJAVPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(10, self.view.bounds.size.height-46, self.view.bounds.size.width-20, 30)];
    self.slider = slider;
    slider.minimumValue = 0;
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(sliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    
    UIView *backview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-128)];
    backview.center = self.view.center;
    [self.view addSubview:backview];
    
    KJPlayer.shared.playerView = backview;
    KJPlayer.shared.delegate = self;
    KJPlayer.shared.useCacheFunction = YES;
//    KJPlayer.shared.speed = 1.25;
    KJPlayer.shared.kVideoTotalTime = ^(NSTimeInterval time) {
        slider.maximumValue = time;
    };
//    KJPlayer.shared.videoURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"];
    KJPlayer.shared.videoURL = [NSURL URLWithString:@"http://appit.winpow.com/attached/media/MP4/1567585643618.mp4"];
//    KJPlayer.shared.autoPlay = NO;
    [KJPlayer.shared kj_playerSeekTime:100 completionHandler:^(BOOL finished) {
        NSLog(@"xxxxxxxxx");
    }];
//    UIImage *image = KJPlayer.shared.kPlayerTimeImage(0);
    KJPlayer.shared.kVideoSize = ^(CGSize size) {
        NSLog(@"%.2f,%.2f",size.width,size.height);
    };
}
- (void)dealloc{
    [KJPlayer kj_attempDealloc];
}

///进度条的拖拽事件 监听UISlider拖动状态
- (void)sliderValueChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch *touchEvent = [[event allTouches]anyObject];
    switch(touchEvent.phase) {
        case UITouchPhaseBegan:
            [KJPlayer.shared kj_playerPause];
            break;
        case UITouchPhaseMoved:
            break;
        case UITouchPhaseEnded:{
            CGFloat second = slider.value;
            [KJPlayer.shared kj_playerSeekTime:second completionHandler:^(BOOL finished) {
                [slider setValue:second animated:YES];
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(id<KJBasePlayer>)player state:(KJPlayerState)state{
    NSLog(@"---当前播放器状态:%@",KJPlayerStateStringMap[state]);
    if (state == KJPlayerStatePlayEnd) {
        player.useCacheFunction = YES;
        player.videoURL = [NSURL URLWithString:@"http://appit.winpow.com/attached/media/MP4/1567585643618.mp4"];
//        [player kj_playerSeekTime:10 completionHandler:nil];
        player.timeSpace = 2.5;
        player.speed = 1.;
        player.videoGravity = KJPlayerVideoGravityResizeAspect;
    }
}
/* 播放进度 */
- (void)kj_player:(id<KJBasePlayer>)player currentTime:(CGFloat)time totalTime:(CGFloat)total{
//    NSLog(@"---播放进度:%.2f,%.2f",time,total);
    self.slider.value = time;
}
/* 缓存状态 */
- (void)kj_player:(id<KJBasePlayer>)player loadstate:(KJPlayerLoadState)state{
    NSLog(@"-----缓存状态:%@",KJPlayerLoadStateStringMap[state]);
}
/* 缓存进度 */
- (void)kj_player:(id<KJBasePlayer>)player loadProgress:(CGFloat)progress{
    NSLog(@"---缓存进度:%.2f",progress);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
