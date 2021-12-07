//
//  KJCachePlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJCachePlayerVC.h"

#import "KJBasePlayer+KJCache.h"

@interface KJCachePlayerVC () <KJPlayerDelegate, KJPlayerCacheDelegate>

@end

@implementation KJCachePlayerVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.player.delegate = self;
    self.player.cacheDelegate = self;
    self.player.videoURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2017-11-21/7c2b143eeb27d9f2bf98c4ab03360cfe.mp4"];
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state{
    if (state == KJPlayerStateBuffering || state == KJPlayerStatePausing) {
        [self.basePlayerView.loadingLayer kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
        [self.basePlayerView.loadingLayer kj_stopAnimation];
    }else if (state == KJPlayerStatePlayFinished) {
        [player kj_replay];
    }
}
/* 播放进度 */
- (void)kj_player:(KJBasePlayer*)player currentTime:(NSTimeInterval)time{
    self.slider.value = time;
    self.label.text = kPlayerConvertTime(time);
}
/* 缓存进度 */
- (void)kj_player:(KJBasePlayer*)player loadProgress:(CGFloat)progress{
    [self.progressView setProgress:progress animated:YES];
}
/* 播放错误 */
- (void)kj_player:(KJBasePlayer*)player playFailed:(NSError*)failed{
    if (failed.code == KJPlayerCustomCodeSaveDatabase) {
        NSLog(@"缓存完成，成功存入数据库");
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setValue:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];
        [attributes setValue:UIColor.whiteColor forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"缓存完成，成功存入数据库" attributes:attributes];
        NSMutableDictionary *attributes2 = [NSMutableDictionary dictionary];
        [attributes2 setValue:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];
        [attributes2 setValue:UIColor.yellowColor forKey:NSForegroundColorAttributeName];
        [string setAttributes:attributes2 range:NSMakeRange(0, 5)];
        [self.basePlayerView.hintTextLayer kj_displayHintText:string time:5 position:KJPlayerHintPositionBottom];
    }else if (failed.code == KJPlayerCustomCodeCachedComplete) {
        [self.basePlayerView.hintTextLayer kj_displayHintText:@"本地数据!!!" time:10 position:KJPlayerHintPositionBottom];
    }else if (failed.code == KJPlayerCustomCodeCacheNone) {
        [self.basePlayerView.hintTextLayer kj_displayHintText:@"本地暂无数据" time:2 position:KJPlayerHintPositionCenter];
    }
}

#pragma mark - KJPlayerCacheDelegate

/// 获取是否需要开启缓存功能
/// @param player 播放器内核
- (BOOL)kj_cacheWithPlayer:(__kindof KJBasePlayer *)player{
    return YES;
}

/// 当前播放视频是否拥有缓存
/// @param player 播放器内核
/// @param haveCache 是否拥有缓存
/// @param cacheVideoURL 缓存视频链接地址
- (void)kj_cacheWithPlayer:(__kindof KJBasePlayer *)player
                 haveCache:(BOOL)haveCache
             cacheVideoURL:(NSURL *)cacheVideoURL{
    
}

@end
