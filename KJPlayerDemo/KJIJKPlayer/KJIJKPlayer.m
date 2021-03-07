//
//  KJIJKPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/3/1.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJIJKPlayer.h"

#if __has_include(<IJKMediaFramework/IJKMediaFramework.h>)

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface KJIJKPlayer (){
    float lastVolume;
}
PLAYER_COMMON_EXTENSION_PROPERTY
@property (nonatomic,strong) IJKFFMoviePlayerController *player;
@property (nonatomic,strong) IJKFFOptions *options;
@property (nonatomic,strong) UIView *tempView;
@property (nonatomic,assign) BOOL initNotificationObservers;
@end

@implementation KJIJKPlayer
PLAYER_COMMON_FUNCTION_PROPERTY PLAYER_COMMON_UI_PROPERTY
- (instancetype)init{
    if (self = [super init]) {
        _speed = 1.;
        _timeSpace = 1.;
        _autoPlay = YES;
        _videoGravity = KJPlayerVideoGravityResizeAspect;
        _background = UIColor.blackColor.CGColor;
        [self setValue:@(YES) forKey:@"openPing"];
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    }
    return self;
}
- (void)dealloc{
    [self kj_changeSourceCleanJobs];
}

- (void)installMovieNotificationObservers{
    if (self.initNotificationObservers) return;
    self.initNotificationObservers = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sizeAvailableChange:)
                                                 name:IJKMPMovieNaturalSizeAvailableNotification
                                               object:self.player];
}

- (void)removeMovieNotificationObservers{
    self.initNotificationObservers = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMovieNaturalSizeAvailableNotification
                                                  object:self.player];
}
#pragma mark - notification
//加载状态改变
- (void)loadStateDidChange:(NSNotification*)notification{
    IJKMPMovieLoadState loadState = self.player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlayable)) {//加载状态变成了缓存数据足够开始播放
//        NSLog(@"---xxx---%.2f,%.2f",self.player.currentPlaybackTime,self.player.playableDuration);
        if (self.player.currentPlaybackTime > 0) {
            self.buffered = YES;
        }
    }else if ((loadState & IJKMPMovieLoadStatePlaythroughOK)) {//加载完成，即将播放
        if (self.buffered) {
            self.state = KJPlayerStatePreparePlay;
            [self kj_autoPlay];
        }else{
            [self.player pause];
        }
    }else if ((loadState & IJKMPMovieLoadStateStalled)) {//可能由于网速不好等因素导致暂停
        self.state = KJPlayerStateBuffering;
    }else{
    
    }
}
//播放状态改变
- (void)moviePlayBackFinish:(NSNotification*)notification{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: 播放完毕: %d\n", reason);
            break;
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: 用户退出播放: %d\n", reason);
            break;
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: 播放出现错误: %d\n", reason);
            break;
    }
}
//准备开始播放
- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification{
    self.totalTime = self.player.duration;
    [self kj_haveTotalTimeAfter];
    self.playerView.image = nil;
}
//播放时刻的状态
- (void)moviePlayBackStateDidChange:(NSNotification*)notification{
    switch (self.player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:
            [self kj_stop];
            break;
        case IJKMPMoviePlaybackStatePlaying:{
            self.state = KJPlayerStatePlaying;
            CGFloat sec = self.player.currentPlaybackTime;
            if (self.userPause == NO) {
                self.currentTime = sec;
            }
            if (sec > self.tryTime && self.tryTime) {
                [self kj_pause];
                if (!self.tryLooked) {
                    self.tryLooked = YES;
                    kGCD_player_main(^{
                        if (self.tryTimeBlock) self.tryTimeBlock();
                    });
                }
            }else{
                self.tryLooked = NO;
            }
        }
            break;
        case IJKMPMoviePlaybackStatePaused:
            self.state = KJPlayerStatePausing;
            break;
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)self.player.playbackState);
            break;
        case IJKMPMoviePlaybackStateSeekingForward:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)self.player.playbackState);
            break;
        case IJKMPMoviePlaybackStateSeekingBackward:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)self.player.playbackState);
            break;
    }
}
//视频的尺寸变化了
- (void)sizeAvailableChange:(NSNotification *)notify {
    if (!CGSizeEqualToSize(self.player.naturalSize, self.tempSize)) {    
        self.tempSize = self.player.naturalSize;
        if (self.kVideoSize) self.kVideoSize(self.tempSize);
    }
}

#pragma mark - 定时器
//销毁定时器
- (void)kj_cleanTimer{
    kPlayerPerformSel(self, @"kj_closePingTimer");
}
- (void)updateEvent{
    if (self.totalTime) {
        self.progress = self.player.playableDuration / self.totalTime;
    }else{
        self.progress = 0.f;
    }
}

#pragma mark - private method
// 切换内核时的清理工作（名字不能改，动态切换时有使用）
- (void)kj_changeSourceCleanJobs{
    [self.player stop];
    [self.player shutdown];
    [self kj_destroyPlayer];
    if (self.tempView.superview) {
        [self.tempView removeFromSuperview];
    }
    _options = nil;
    _tempView = nil;
}
//加载视屏流视图（名字不能乱改，父类有调用）
- (void)kj_displayPictureWithSize:(CGSize)size{
    if (_playerView == nil) return;
    if (self.tempView.superview == nil) {
        [_playerView addSubview:_tempView];
    }else{
        self.tempView.hidden = NO;
    }
    self.tempView.frame = CGRectMake(0, 0, size.width, size.height);
}
/// 销毁播放（名字不能乱改，KJCache当中有使用）
- (void)kj_destroyPlayer{
    if (self.player) {
        [self.player pause];
        [self removeMovieNotificationObservers];
        _player = nil;
    }
    [self kj_cleanTimer];
}
/// 播放准备（名字不能乱改，KJCache当中有使用）
- (void)kj_initPreparePlayer{
    [self kj_initializeBeginPlayConfiguration];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:_videoURL withOptions:self.options];
    [self setVideoGravity:_videoGravity];
    self.player.shouldAutoplay = self.autoPlay;//是否自动播放，需在 prepareToPlay 之前设置
    [self.player prepareToPlay];
    [self installMovieNotificationObservers];
    self.tempView = self.player.view;
    [self kj_displayPictureWithSize:self.playerView.frame.size];
    self.progress = self.locality ? 1.0 : 0.0;
}
//初始化开始播放时配置信息
- (void)kj_initializeBeginPlayConfiguration{
    if (self.player) {
        [self.player pause];
        [self removeMovieNotificationObservers];
    }
    self.tempSize = CGSizeZero;
    self.currentTime = self.totalTime = 0.0;
    self.userPause = NO;
    self.tryLooked = NO;
    self.buffered = NO;
    [self kj_cleanTimer];
}
//自动播放
- (void)kj_autoPlay{
    if (self.autoPlay && self.userPause == NO) {
        [self kj_play];
    }
}
//获取到总时间之后的处理操作
- (void)kj_haveTotalTimeAfter{
    if (self.kVideoTotalTime) {
        self.kVideoTotalTime(self.totalTime);
    }
    if (self.totalTime == 0) {//直播流媒体
        self.isLiveStreaming = YES;
        [self kj_autoPlay];
        return;
    }
    self.isLiveStreaming = NO;
    /// 功能操作
    if (self.recordLastTime) {
        NSString *dbid = kPlayerIntactName(self.originalURL);
        NSTimeInterval time = [DBPlayerDataInfo kj_getLastTimeDbid:dbid];
        kGCD_player_main(^{
            if (self.totalTime) self.currentTime = time;
        });
        self.kVideoAdvanceAndReverse(time,nil);
        if (self.recordTimeBlock) {
            kGCD_player_main(^{
                self.recordTimeBlock(time);
            });
        }
    }else if (self.skipHeadTime) {
        self.kVideoAdvanceAndReverse(self.skipHeadTime,nil);
        if (self.skipTimeBlock) {
            kGCD_player_main(^{
                self.skipTimeBlock(KJPlayerVideoSkipStateHead);
            });
        }
    }else{
        [self kj_autoPlay];
    }
}

#pragma mark - public method
/* 准备播放 */
- (void)kj_play{
    if (self.player == nil || self.tryLooked) return;
    [super kj_play];
    [self.player play];
    if (self.muted) { }
    self.player.playbackRate = self.speed;
    self.userPause = NO;
}
/* 重播 */
- (void)kj_replay{
    [super kj_replay];
    self.kVideoAdvanceAndReverse(self.skipHeadTime, ^(BOOL finished) {
        if (finished) [self kj_play];
    });
}
/* 继续 */
- (void)kj_resume{
    [super kj_resume];
    [self kj_play];
}
/* 暂停 */
- (void)kj_pause{
    if (self.player == nil) return;
    [super kj_pause];
    [self.player pause];
    self.state = KJPlayerStatePausing;
    self.userPause = YES;
}
/* 停止 */
- (void)kj_stop{
    [super kj_stop];
    [self kj_cleanTimer];
    [self.player stop];
    [self.player shutdown];
    [self kj_destroyPlayer];
    self.state = KJPlayerStateStopped;
}
/* 判断当前资源文件是否有缓存，修改为指定链接地址 */
- (BOOL)kj_judgeHaveCacheWithVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL{
    self.locality = [super kj_judgeHaveCacheWithVideoURL:videoURL];
    return self.locality;
}
/* 圆圈加载动画 */
- (void)kj_startAnimation{
    [super kj_startAnimation];
}
/* 停止动画 */
- (void)kj_stopAnimation{
    [super kj_stopAnimation];
}

#pragma mark - setter
- (void)setOriginalURL:(NSURL *)originalURL{
    _originalURL = originalURL;
    self.state = KJPlayerStateBuffering;
    if (self.placeholder) {
        self.playerView.backgroundColor = [UIColor colorWithCGColor:_background];
        self.playerView.image = self.placeholder;
        switch (_videoGravity) {
            case KJPlayerVideoGravityResizeAspect:
                self.playerView.contentMode = UIViewContentModeScaleAspectFit;
                break;
            case KJPlayerVideoGravityResizeOriginal:
                self.playerView.contentMode = UIViewContentModeScaleToFill;
                break;
            case KJPlayerVideoGravityResizeAspectFill:
                self.playerView.contentMode = UIViewContentModeScaleAspectFill;
                break;
            default:
                break;
        }
    }
    if (self.tempView.superview) {
        self.tempView.hidden = YES;
    }
}
- (void)setVideoURL:(NSURL *)videoURL{
    self.originalURL = videoURL;
    self.cache = NO;
    if (self.kPlayerDynamicChangeSource()) {
        _videoURL = videoURL;
        [self kj_initPreparePlayer];
    }else if (![videoURL.absoluteString isEqualToString:_videoURL.absoluteString]) {
        _videoURL = videoURL;
        [self kj_initPreparePlayer];
    }else{
        [self kj_replay];
    }
}
- (void)setVolume:(float)volume{
    _volume = MIN(MAX(0, volume), 1);
    lastVolume = _volume;
    if (self.player) self.player.playbackVolume = volume;
}
- (void)setMuted:(BOOL)muted{
    if (self.player && _muted != muted) {
        if (muted) {
            self.player.playbackVolume = 0.f;
        }else if (lastVolume) {
            self.player.playbackVolume = lastVolume;
        }else{
            lastVolume = self.player.playbackVolume;
        }
    }
    _muted = muted;
}
- (void)setSpeed:(float)speed{
    if (self.player && fabsf(_player.playbackRate) > 0.00001f && _speed != speed) {
        if (speed <= 0) {
            speed = 0.1;
        }else if (speed >= 2){
            speed = 2;
        }
        self.player.playbackRate = speed;
    }
    _speed = speed;
}
- (void)setVideoGravity:(KJPlayerVideoGravity)videoGravity{
    if (self.player && _videoGravity != videoGravity) {
        switch (videoGravity) {
            case KJPlayerVideoGravityResizeAspect:
                self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
                break;
            case KJPlayerVideoGravityResizeAspectFill:
                self.player.scalingMode = IJKMPMovieScalingModeAspectFill;
                break;
            case KJPlayerVideoGravityResizeOriginal:
                self.player.scalingMode = IJKMPMovieScalingModeFill;
                break;
            default:break;
        }
    }
    _videoGravity = videoGravity;
}
- (void)setBackground:(CGColorRef)background{
    if (self.tempView && _background != background) {
        self.tempView.backgroundColor = [UIColor colorWithCGColor:background];
    }
    _background = background;
}
- (void)setPlayerView:(KJBasePlayerView *)playerView{
    if (playerView == nil) return;
    _playerView = playerView;
    [self kj_displayPictureWithSize:playerView.frame.size];
}

#pragma mark - getter
- (BOOL)isPlaying{
    if (self.player == nil) return NO;
    return self.player.isPlaying;
}
/* 快进或快退 */
- (void (^)(NSTimeInterval,void (^_Nullable)(BOOL)))kVideoAdvanceAndReverse{
    return ^(NSTimeInterval seconds, void (^xxblock)(BOOL)){
        if (self.isLiveStreaming) return;
        if (self.player) {
            [self.player pause];
        }else{
            if (xxblock) xxblock(NO);
        }
        PLAYER_WEAKSELF;
        __block NSTimeInterval time = seconds;
//        dispatch_group_notify(weakself.group, dispatch_get_main_queue(), ^{
            if (weakself.openAdvanceCache && weakself.locality == NO) {
                if (weakself.totalTime) {
                    NSTimeInterval _time = weakself.progress * weakself.totalTime;
                    if (time + weakself.cacheTime >= _time) time = _time - weakself.cacheTime;
                }else{
                    time = weakself.currentTime;
                }
            }
            if (self.totalTime > 0) {
                self.currentTime = time;
                self.player.currentPlaybackTime = time;
                if (xxblock) xxblock(YES);
            }
//        });
    };
}
- (void (^)(void (^ _Nullable)(void), NSTimeInterval))kVideoTryLookTime{
    return ^(void (^xxblock)(void), NSTimeInterval time){
        self.tryTime = time;
        self.tryTimeBlock = xxblock;
    };
}
- (void (^)(void (^ _Nonnull)(NSTimeInterval), BOOL))kVideoRecordLastTime{
    return ^(void(^xxblock)(NSTimeInterval), BOOL record){
        self.recordLastTime = record;
        self.recordTimeBlock = xxblock;
    };
}
- (void (^)(void (^ _Nonnull)(KJPlayerVideoSkipState), NSTimeInterval, NSTimeInterval))kVideoSkipTime{
    return ^(void(^xxblock)(KJPlayerVideoSkipState), NSTimeInterval headTime, NSTimeInterval footTime){
        self.skipHeadTime = headTime;
        self.skipTimeBlock = xxblock;
    };
}
- (void (^)(void (^)(UIImage *)))kVideoTimeScreenshots{
    return ^(void (^xxblock)(UIImage *)){
        kGCD_player_async(^{
            if (xxblock) {
                if (self.player) {
                    xxblock([self.player thumbnailImageAtCurrentTime]);
                }else{
                    xxblock(nil);
                }
            }
        });
    };
}

#pragma mark - lazy loading
- (UIView *)tempView{
    if (!_tempView) {
        _tempView = [UIView new];
        _tempView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tempView.userInteractionEnabled = NO;
        _tempView.layer.zPosition = KJBasePlayerViewLayerZPositionPlayer;
    }
    return _tempView;
}
- (IJKFFOptions *)options{
    if (!_options) {
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame" ofCategory:kIJKFFOptionCategoryCodec];
        [options setOptionIntValue:IJK_AVDISCARD_ALL forKey:@"skip_loop_filter" ofCategory:kIJKFFOptionCategoryCodec];
        [options setOptionIntValue:1 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
        [options setOptionIntValue:30 forKey:@"max-fps" ofCategory:kIJKFFOptionCategoryPlayer];
        [options setOptionIntValue:256 forKey:@"vol" ofCategory:kIJKFFOptionCategoryPlayer];
        [options setOptionIntValue:1 forKey:@"dns_cache_clear" ofCategory:kIJKFFOptionCategoryFormat];
        [options setOptionIntValue:1024 forKey:@"probesize" ofCategory:kIJKFFOptionCategoryFormat];
        
        _options = options;
    }
    return _options;
}

//丢帧处理
- (void)kj_loseFrameOptions:(IJKFFOptions *)options{
    [options setPlayerOptionIntValue:0 forKey:@"opensles"];
    
    [options setFormatOptionIntValue:1 forKey:@"dns_cache_clear"];
    [options setCodecOptionIntValue:IJK_AVDISCARD_ALL forKey:@"skip_loop_filter"];
}

- (void)kj_xxxOptions:(IJKFFOptions *)options{
    //最大fps
    [options setPlayerOptionIntValue:60 forKey:@"max-fps"];
    //设置音量大小，256为标准音量
    [options setPlayerOptionIntValue:256 forKey:@"vol"];
    //解决http播放不了
    [options setFormatOptionIntValue:1 forKey:@"dns_cache_clear"];
    [options setPlayerOptionIntValue:1 forKey:@"enable-accurate-seek"];
    //播放前的探测Size，默认是1M, 改小一点会出画面更快
    [options setFormatOptionIntValue:1024 forKey:@"probesize"];
    //播放前的探测时间
    [options setFormatOptionIntValue:50000 forKey:@"analyzeduration"];
    //默认好像是硬解开启软解
    [options setPlayerOptionIntValue:0 forKey:@"videotoolbox"];
    //解码参数，画面更清晰
    [options setCodecOptionIntValue:IJK_AVDISCARD_ALL forKey:@"skip_loop_filter"];
    //这个目前理解应该是丢帧数设置
    [options setCodecOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame"];
    //最大缓存大小是3秒，可以依据自己的需求修改
    [options setPlayerOptionIntValue:3000 forKey:@"max_cached_duration"];
    //无限读
    [options setPlayerOptionIntValue:1 forKey:@"infbuf"];
    //关闭播放器缓冲
    [options setPlayerOptionIntValue:0 forKey:@"packet-buffering"];
    // 跳帧开关，如果cpu解码能力不足，可以设置成5，否则
    // 会引起音视频不同步，也可以通过设置它来跳帧达到倍速播放
    [options setPlayerOptionIntValue:0 forKey:@"framedrop"];
    // 指定最大宽度
    [options setPlayerOptionIntValue:960 forKey:@"videotoolbox-max-frame-width"];
    // 自动转屏开关
    [options setFormatOptionIntValue:0 forKey:@"auto_convert"];
    // 重连次数
    [options setFormatOptionIntValue:1 forKey:@"reconnect"];

}

@end

#pragma clang diagnostic pop
#endif
