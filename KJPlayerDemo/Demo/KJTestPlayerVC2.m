//
//  KJTestPlayerVC2.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/31.
//  Copyright © 2021 杨科军. All rights reserved.
//

#import "KJTestPlayerVC2.h"
#import "KJPlayer.h"
@interface KJTestPlayerVC2 ()<KJPlayerDelegate>
@end

@implementation KJTestPlayerVC2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    KJPlayer *player = [KJPlayer kj_sharedInstance];
    player.playerView = self.view;
    player.delegate = self;
    player.assetURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"];
    player.speed = 1.;
//    [player kj_playerPlay];
    [player kj_playerSeekTime:200 completionHandler:^(BOOL finished) {
        NSLog(@"xxxxxxxxx");
    }];
//    UIImage *image = player.kPlayerTimeImage(0);
}
- (void)dealloc{
    [KJPlayer kj_attempDealloc];
}
#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(id<KJPlayerPlayHandle>)player state:(KJPlayerState)state{
    NSLog(@"---当前播放器状态:%@",KJPlayerStateStringMap[state]);
    if (state == KJPlayerStatePlayEnd) {
        player.useCacheFunction = YES;
        player.assetURL = [NSURL URLWithString:@"http://appit.winpow.com/attached/media/MP4/1567585643618.mp4"];
//        [player kj_playerSeekTime:20 completionHandler:nil];
        [player kj_playerPlay];
        player.timeSpace = 2.0;
        player.speed = 1.0;
        player.videoGravity = KJPlayerVideoGravityResizeAspect;
    }
}
/* 播放进度 */
- (void)kj_player:(id<KJPlayerPlayHandle>)player currentTime:(CGFloat)time totalTime:(CGFloat)total{
//    NSLog(@"---播放进度:%.2f,%.2f",time,total);
}
/* 缓存状态 */
- (void)kj_player:(id<KJPlayerPlayHandle>)player loadstate:(KJPlayerLoadState)state{
    NSLog(@"-----缓存状态:%@",KJPlayerLoadStateStringMap[state]);
}
/* 缓存进度 */
- (void)kj_player:(id<KJPlayerPlayHandle>)player loadProgress:(CGFloat)progress{
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
