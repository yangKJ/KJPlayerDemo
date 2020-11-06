//
//  ViewController.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "ViewController.h"
#import "KJPlayerView.h"

@interface ViewController ()<KJPlayerViewDelegate>
@property(nonatomic,strong) KJPlayerView *playerView;
@end

@implementation ViewController

/// 电池状态栏管理
- (BOOL)prefersStatusBarHidden{
    if (self.playerView) {
        return _playerView.configuration.fullScreen;
    }else{
        return NO;
    }
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
        configuration.haveFristImage = YES;
//        configuration.useCacheFunction = YES;
        configuration.playType = KJPlayerPlayTypeOrder;
        KJPlayerView *view = [[KJPlayerView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16) Configuration:configuration];
        _playerView = view;
        view.backgroundColor = UIColor.blackColor;
        view.delegate = self;
        
        NSArray *temp = @[@"https://apps.winpow.com/attached/media/mp4/1559550527183.mp4",
                          @"http://appit.winpow.com/attached/media/MP4/1567585643618.mp4",
                          @"https://devstreaming-cdn",
                          @"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8",
                          @"https://mp4.vjshi.com/2018-08-31/3ba67e58deb45fefe7f7d3d16dbf2b16.mp4",
                          @"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4",
                          @"https://mp4.vjshi.com/2017-07-02/0cbbf21c6003f7936f4086dd10e7ebf5.mp4",
                          ];
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger i=0; i<2; i++) {
            KJPlayerViewModel *model = [KJPlayerViewModel new];
            if (i==0) {
                model.sd = temp[0];
                model.cif = temp[5];
                model.hd = temp[2];
            }else if (i==1) {
                model.hd = temp[5];
            }else{
                model.sd = temp[3];
                model.hd = temp[4];
            }
            [array addObject:model];
        }
        view.videoIndex = 0;
        view.videoModelTemps = array;
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
/// Bottom按钮事件  tag:520收藏、521下载、522清晰度
- (void)kj_PlayerView:(KJPlayerView*)playerView BottomButton:(UIButton*)sender{
    
}

@end
