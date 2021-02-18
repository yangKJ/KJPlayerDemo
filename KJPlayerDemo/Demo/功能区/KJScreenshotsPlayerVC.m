//
//  KJScreenshotsPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJScreenshotsPlayerVC.h"

@interface KJScreenshotsPlayerVC ()<KJPlayerDelegate>
@property(nonatomic,strong)UIImageView *imageView;
@end

@implementation KJScreenshotsPlayerVC
- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-80-self.view.frame.size.width*9/16, self.view.frame.size.width, self.view.frame.size.width*9/16)];
    self.imageView = imageView;
    [self.view addSubview:imageView];
    imageView.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
    
    {
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake(30, self.view.frame.size.height/2-25, 100, 50);
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitle:@"截取图片" forState:(UIControlStateNormal)];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }{
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake(self.view.frame.size.width-30-100, self.view.frame.size.height/2-25, 100, 50);
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateSelected)];
        [button setTitle:@"切换mp4" forState:(UIControlStateNormal)];
        [button setTitle:@"切换m3u8" forState:(UIControlStateSelected)];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(buttonAction2:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    
    self.basePlayerView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width*9/16);
    self.player.delegate = self;
    self.player.videoURL = [NSURL URLWithString:@"http://hls.cntv.myalicdn.com/asp/hls/2000/0303000a/3/default/bca293257d954934afadfaa96d865172/2000.m3u8"];
}
- (void)buttonAction:(UIButton*)sender{
    self.player.kVideoTimeScreenshots(^(UIImage *image) {
        self.imageView.image = image;
    });
}
- (void)buttonAction2:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.player.videoURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"];
    }else{
        self.player.videoURL = [NSURL URLWithString:@"http://hls.cntv.myalicdn.com/asp/hls/2000/0303000a/3/default/bca293257d954934afadfaa96d865172/2000.m3u8"];
    }
}
#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBaseCommonPlayer*)player state:(KJPlayerState)state{
    NSLog(@"---当前播放器状态:%@",KJPlayerStateStringMap[state]);
    if (state == KJPlayerStateBuffering) {
        [player kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay) {
        [player kj_stopAnimation];
    }else if (state == KJPlayerStatePlaying) {
        [player kj_stopAnimation];
    }else if (state == KJPlayerStatePlayFinished) {
        [player kj_replay];
    }
}
/* 播放进度 */
- (void)kj_player:(KJBaseCommonPlayer*)player currentTime:(NSTimeInterval)time{
    self.slider.value = time;
    self.label.text = kPlayerConvertTime(time);
}
/* 缓存进度 */
- (void)kj_player:(KJBaseCommonPlayer*)player loadProgress:(CGFloat)progress{
    NSLog(@"---缓存进度:%f",progress);
    [self.progressView setProgress:progress animated:YES];
}
/* 播放错误 */
- (void)kj_player:(KJBaseCommonPlayer*)player playFailed:(NSError*)failed{
    
}

@end
