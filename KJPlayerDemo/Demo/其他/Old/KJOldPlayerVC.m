//
//  KJOldPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/31.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJOldPlayerVC.h"
#import "KJOldPlayerView.h"
@interface KJOldPlayerVC ()<KJPlayerViewDelegate>
@property(nonatomic,strong) KJOldPlayerView *playerView;
@end

@implementation KJOldPlayerVC

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
    self.view.backgroundColor = UIColor.whiteColor;
    // Do any additional setup after loading the view.
    [self.view addSubview:self.playerView];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self deal];
}
- (void)deal{
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"video"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:document];
    NSString *imageName;
    while((imageName = [enumerator nextObject]) != nil) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",document,imageName] error:NULL];
    }
}

- (KJOldPlayerView*)playerView{
    if (!_playerView) {
        KJPlayerViewConfiguration *configuration = [[KJPlayerViewConfiguration alloc]init];
        configuration.autoHideTime = 0.0;
        configuration.haveFristImage = YES;
        configuration.speed = 3;
        configuration.playType = KJPlayerPlayTypeOrder;
        KJOldPlayerView *view = [[KJOldPlayerView alloc] initWithFrame:CGRectMake(0, 20, PLAYER_SCREEN_WIDTH, PLAYER_SCREEN_WIDTH*9/16) Configuration:configuration];
        _playerView = view;
        view.backgroundColor = UIColor.blackColor;
        view.delegate = self;
        
        NSArray *temp = @[@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4",
                          @"http://appit.winpow.com/attached/media/MP4/1567585643618.mp4",
                          @"https://devstreaming-cdn",
                          @"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8",
                          @"https://mp4.vjshi.com/2018-08-31/3ba67e58deb45fefe7f7d3d16dbf2b16.mp4",
                          @"https://mp4.vjshi.com/2021-01-13/d37b7bea25b063b4f9d4bdd98bc611e3.mp4",
                          @"https://mp4.vjshi.com/2017-07-02/0cbbf21c6003f7936f4086dd10e7ebf5.mp4",
                          ];
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger i=0; i<2; i++) {
            KJPlayerViewModel *model = [KJPlayerViewModel new];
            if (i==0) {
                model.sd = temp[0];
                model.cif= temp[5];
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
- (BOOL)kj_PlayerView:(KJOldPlayerView *)playerView DeviceDirection:(KJPlayerDeviceDirection)direction{
    /// 重置电池状态
    [self setNeedsStatusBarAppearanceUpdate];
    if (direction == KJPlayerDeviceDirectionTop || direction == KJPlayerDeviceDirectionBottom) {
        
    }else{
        
    }
    return NO;
}
/// Bottom按钮事件  tag:520收藏、521下载、522清晰度
- (void)kj_PlayerView:(KJOldPlayerView*)playerView BottomButton:(UIButton*)sender{
    
}
- (void)kj_PlayerView:(KJOldPlayerView*)playerView PlayerState:(KJPlayerState)state TopButton:(UIButton*)sender{
    if (sender.tag == 200) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [playerView.player kj_playerStop];
    }
}

@end
