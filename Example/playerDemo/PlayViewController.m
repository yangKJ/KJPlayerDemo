//
//  PlayViewController.m
//  playerDemo
//
//  Created by 杨科军 on 2019/7/25.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "PlayViewController.h"
#import <KJPlayerView.h>
@interface PlayViewController ()<KJPlayerViewDelegate>
@property(nonatomic,strong) KJPlayerView *playerView;
@end

@implementation PlayViewController

/// 电池状态栏管理
- (BOOL)prefersStatusBarHidden{
    if (self.playerView) {
        return _playerView.configuration.fullScreen;
    }else{
        return NO;
    }
}

- (void)dealloc{
    self.playerView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.view addSubview:self.playerView];
}

- (KJPlayerView*)playerView{
    if (!_playerView) {
        KJPlayerViewConfiguration *configuration = [[KJPlayerViewConfiguration alloc]init];
        configuration.autoHideTime = 0.0;
        configuration.playType = KJPlayerPlayTypeOrder;
        KJPlayerView *view = [[KJPlayerView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16) Configuration:configuration];
        _playerView = view;
        view.backgroundColor = UIColor.blackColor;
        
        view.delegate = self;
        
        NSString *url = @"https://mp4.vjshi.com/2017-07-02/0cbbf21c6003f7936f4086dd10e7ebf5.mp4";
        [view kj_setPlayWithURL:url StartTime:0];
        NSArray *temp = @[@"https://mp4.vjshi.com/2018-08-31/3ba67e58deb45fefe7f7d3d16dbf2b16.mp4",
                          @"https://mp4.vjshi.com/2017-07-02/0cbbf21c6003f7936f4086dd10e7ebf5.mp4",
                          [NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"],
                          ];
        view.videoUrlTemps = temp;
        view.videoIndex = 2;
    }
    return _playerView;
}

#pragma mark - KJPlayerViewDelegate
- (BOOL)kj_PlayerView:(KJPlayerView *)playerView DeviceDirection:(KJPlayerDeviceDirection)direction{
    /// 重置电池状态
    [self setNeedsStatusBarAppearanceUpdate];
    //    switch (direction) {
    //        case KJPlayerDeviceDirectionTop:
    //            playerView.layer.transform = CATransform3DIdentity;
    //            break;
    //        case KJPlayerDeviceDirectionBottom:
    //            playerView.layer.transform = CATransform3DIdentity;
    //            break;
    //        case KJPlayerDeviceDirectionLeft:
    //            playerView.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0, 0, 1);
    //            playerView.layer.frame = CGRectMake(0, 0, PLAYER_SCREEN_WIDTH, PLAYER_SCREEN_HEIGHT);
    //            playerView.playerLayer.frame = playerView.bounds;
    //            break;
    //        case KJPlayerDeviceDirectionRight:
    //            playerView.layer.transform = CATransform3DMakeRotation(M_PI/2, 0, 0, 1);
    //            playerView.layer.frame = CGRectMake(0, 0, PLAYER_SCREEN_WIDTH, PLAYER_SCREEN_HEIGHT);
    //            break;
    //        default:
    //            break;
    //    }
    return NO;
}
- (void)kj_PlayerView:(KJPlayerView *)playerView PlayerState:(KJPlayerState)state{
    [self dismissViewControllerAnimated:YES completion:^{
       
    }];
}
@end
