//
//  KJCachePlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJCachePlayerVC.h"

@interface KJCachePlayerVC ()<KJPlayerDelegate>

@end

@implementation KJCachePlayerVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.player.delegate = self;
    self.player.kVideoCanCacheURL([NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"], YES);
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state{
    NSLog(@"---当前播放器状态:%@",KJPlayerStateStringMap[state]);
    if (state == KJPlayerStateBuffering || state == KJPlayerStatePausing) {
        [player kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
        [player kj_stopAnimation];
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
    NSLog(@"---缓存进度:%f",progress);
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
        [player kj_displayHintText:string time:5 position:KJPlayerHintPositionBottom];
    }else if (failed.code == KJPlayerCustomCodeCachedComplete) {
        [player kj_displayHintText:@"本地数据!!!" time:10 position:KJPlayerHintPositionBottom];
    }else if (failed.code == KJPlayerCustomCodeCacheNone) {
        [player kj_displayHintText:@"本地暂无数据" time:2 position:KJPlayerHintPositionCenter];
    }
}

@end
