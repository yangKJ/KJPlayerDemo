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

@interface KJIJKPlayer ()
PLAYER_COMMON_EXTENSION_PROPERTY
@property (nonatomic,strong) IJKFFMoviePlayerController *player;
@property (nonatomic,strong) IJKFFOptions *options;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) BOOL initNotificationObservers;
@property (nonatomic,assign) BOOL buffered;

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
        self.group = dispatch_group_create();
//        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
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
    /// 视频的尺寸变化了
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
        if (self.player.currentPlaybackTime > 0) {
            self.buffered = YES;
        }
    }else if ((loadState & IJKMPMovieLoadStatePlaythroughOK)) {//加载完成，即将播放
        self.state = KJPlayerStatePreparePlay;
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
    [self.timer fire];
}
//播放时刻的状态
- (void)moviePlayBackStateDidChange:(NSNotification*)notification{
    switch (self.player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)self.player.playbackState);
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
    self.tempSize = self.player.naturalSize;
    if (self.kVideoSize) self.kVideoSize(self.tempSize);
}

#pragma mark - 定时器
- (void)updateEvent{
    if ([self.player isPlaying]) {
        CGFloat total = self.player.duration;
        if (total) {
            CGFloat able = self.player.playableDuration;
            self.progress = able / total;
        }else{
            self.progress = 0.f;
        }
    }
}

#pragma mark - super method
- (void)kj_basePlayerViewChange:(NSNotification*)notification{
    [super kj_basePlayerViewChange:notification];
    CGRect rect = [notification.userInfo[kPlayerBaseViewChangeKey] CGRectValue];
    self.player.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    if (self.player.view.superview == nil) {
        [self.playerView addSubview:self.player.view];
    }
}

#pragma mark - private method
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
// 切换内核时的清理工作（名字不能改，动态继承时有使用）
- (void)kj_changeSourceCleanJobs{
    [self.player stop];
    [self.player shutdown];
    [self kj_destroyPlayer];
    if (self.player.view.superview) {
        [self.player.view removeFromSuperview];
    }
}
//自动播放
- (void)kj_autoPlay{
    if (self.autoPlay && self.userPause == NO) {
        [self kj_play];
    }
}
/// 销毁播放（名字不能乱改，KJCache当中有使用）
- (void)kj_destroyPlayer{
    if (self.player) {
        [self.player pause];
        [self removeMovieNotificationObservers];
    }
    _player = nil;
    if (self.kPlayerDynamicChangeSource()) {
        _timer = nil;
    }
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
/// 播放准备（名字不能乱改，KJCache当中有使用）
- (void)kj_initPreparePlayer{
    [self kj_initializeBeginPlayConfiguration];
    kGCD_player_main(^{
        self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self->_videoURL withOptions:self.options];
    });
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.player.scalingMode = kPlayerVideoGravity(self->_videoGravity);
    self.player.shouldAutoplay = self.autoPlay;//是否自动播放，需在`prepareToPlay`之前设置
    [self.player prepareToPlay];
    [self installMovieNotificationObservers];
    kGCD_player_main(^{
        self.player.view.frame = self.playerView.bounds;
        self.player.view.userInteractionEnabled = NO;
        self.player.view.layer.zPosition = KJBasePlayerViewLayerZPositionPlayer;
        [self.playerView addSubview:self.player.view];
    });
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
    if (self.kPlayerDynamicChangeSource()) {
        _timer = nil;
    }
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
#pragma mark - public method
/* 准备播放 */
- (void)kj_play{
    if (self.player == nil || self.tryLooked) return;
    self.userPause = NO;
    [self.player play];
    if (self.muted) { }
    self.player.playbackRate = self.speed;
}
/* 重播 */
- (void)kj_replay{
    self.kVideoAdvanceAndReverse(self.skipHeadTime, ^(BOOL finished) {
        if (finished) [self kj_play];
    });
}
/* 继续 */
- (void)kj_resume{
    [self kj_play];
}
/* 暂停 */
- (void)kj_pause{
    if (self.player == nil) return;
    self.state = KJPlayerStatePausing;
    self.userPause = YES;
    [self.player pause];
}
/* 停止 */
- (void)kj_stop{
    [self.player stop];
    [self.player shutdown];
    [self kj_destroyPlayer];
    self.state = KJPlayerStateStopped;
}
/* 判断当前资源文件是否有缓存，修改为指定链接地址 */
- (void)kj_judgeHaveCacheWithVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL{
    self.locality = NO;
    KJCacheManager.kJudgeHaveCacheURL(^(BOOL locality) {
        self.locality = locality;
        if (locality) {
            self.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeCachedComplete];
        }
    }, videoURL);
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
    kGCD_player_main(^{
        self.state = KJPlayerStateBuffering;
        if (self.player.view.superview) {
            [self.player.view removeFromSuperview];
        }
        if (self.player.view.superview == nil && self.playerView) {
            self.player.view.frame = self.playerView.bounds;
            [self.playerView addSubview:self.player.view];
        }
        /// 封面图
        if (self.placeholder) {
//            self.player.view.layer.contents = (id)self.placeholder.CGImage;
//            self.player.view.layer.contentsGravity = kPlayerContentsGravity(self.videoGravity);
        }
    });
}
- (void)setVideoURL:(NSURL *)videoURL{
    self.originalURL = videoURL;
    self.cache = NO;
    if (kPlayerVideoAesstType(videoURL) == KJPlayerAssetTypeNONE) {
        _videoURL = videoURL;
        self.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeVideoURLUnknownFormat];
        if (self.player) [self kj_stop];
        return;
    }
    PLAYER_WEAKSELF;
    __block NSURL *tempURL = videoURL;
//    dispatch_group_async(self.group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if (kPlayerVideoAesstType(videoURL) == KJPlayerAssetTypeFILE) {
//            if (!kPlayerHaveTracks(videoURL, ^(AVURLAsset * asset) {
//                weakself.asset = asset;
//            }, weakself.requestHeader)) {
//                weakself.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeVideoURLFault];
//                weakself.state = KJPlayerStateFailed;
//                [weakself kj_destroyPlayer];
//                return;
//            }
//        }
//        [weakself kj_judgeHaveCacheWithVideoURL:&tempURL];
        if (weakself.kPlayerDynamicChangeSource()) {
            self->_videoURL = tempURL;
            [weakself kj_initPreparePlayer];
        }else if (![tempURL.absoluteString isEqualToString:self->_videoURL.absoluteString]) {
            self->_videoURL = tempURL;
            [weakself kj_initPreparePlayer];
        }else{
            [weakself kj_replay];
        }
//    });
}
static float lastVolume = 0.f;
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
        self.player.scalingMode = kPlayerVideoGravity(videoGravity);
    }
    _videoGravity = videoGravity;
}
// 获取视频显示模式
NS_INLINE IJKMPMovieScalingMode kPlayerVideoGravity(KJPlayerVideoGravity videoGravity){
    switch (videoGravity) {
        case KJPlayerVideoGravityResizeAspect:return IJKMPMovieScalingModeAspectFit;
        case KJPlayerVideoGravityResizeAspectFill:return IJKMPMovieScalingModeAspectFill;
        case KJPlayerVideoGravityResizeOriginal:return IJKMPMovieScalingModeFill;
        default:break;
    }
}
- (void)setBackground:(CGColorRef)background{
    if (self.player.view && _background != background) {
        self.player.view.backgroundColor = [UIColor colorWithCGColor:background];
    }
    _background = background;
}
- (void)setTimeSpace:(NSTimeInterval)timeSpace{
    if (_timeSpace != timeSpace) {
        _timeSpace = timeSpace;
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        if (self.timer) { }
    }
}
- (void)setPlayerView:(KJBasePlayerView *)playerView{
    if (playerView == nil) return;
    _playerView = playerView;
    self.player.view.frame = playerView.bounds;
    if (self.player.view.superview == nil) {
        [playerView addSubview:self.player.view];
    }
}

#pragma mark - getter
- (BOOL)isPlaying{
    if (self.player == nil) return NO;
    return self.player.isPlaying;
}
/* 快进或快退 */
- (void (^)(NSTimeInterval,void (^_Nullable)(BOOL)))kVideoAdvanceAndReverse{
    PLAYER_WEAKSELF;
    return ^(NSTimeInterval seconds, void (^xxblock)(BOOL)){
        if (weakself.player) [weakself.player pause];
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
            if (weakself.totalTime) {
                weakself.currentTime = time;
            }
            if (self.player.duration > 0) {
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
            KJPlayerAssetType type = kPlayerVideoAesstType(self.originalURL);
        });
    };
}
- (void (^)(void(^)(UIImage *image),NSURL *,NSTimeInterval))kVideoPlaceholderImage{
    return ^(void(^xxblock)(UIImage*),NSURL *videoURL,NSTimeInterval time){
        kGCD_player_async(^{
            UIImage *image = [KJCacheManager kj_getVideoCoverImageWithURL:videoURL];
            if (image) {
                kGCD_player_main(^{
                    if (xxblock) xxblock(image);
                });
                return;
            }
        });
    };
}

#pragma mark - lazy loading
- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:_timeSpace target:self selector:@selector(updateEvent) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}
- (IJKFFOptions *)options{
    if (!_options) {
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame" ofCategory:kIJKFFOptionCategoryCodec];
        [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter" ofCategory:kIJKFFOptionCategoryCodec];
        [options setOptionIntValue:1 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
        [options setOptionIntValue:60 forKey:@"max-fps" ofCategory:kIJKFFOptionCategoryPlayer];
        [options setOptionIntValue:1 forKey:@"dns_cache_clear" ofCategory:kIJKFFOptionCategoryFormat];
        [options setPlayerOptionIntValue:256 forKey:@"vol"];
        [options setPlayerOptionIntValue:1 forKey:@"enable-accurate-seek"];
        
        //rtmp秒开处理
//        [options setOptionIntValue:100 forKey:@"analyzemaxduration" ofCategory:kIJKFFOptionCategoryFormat];
//        [options setOptionIntValue:10240 forKey:@"probesize" ofCategory:kIJKFFOptionCategoryFormat];
//        [options setOptionIntValue:1 forKey:@"flush_packets" ofCategory:kIJKFFOptionCategoryFormat];
//        [options setOptionIntValue:0 forKey:@"packet-buffering" ofCategory:kIJKFFOptionCategoryPlayer];
//        [options setOptionIntValue:1 forKey:@"framedrop" ofCategory:kIJKFFOptionCategoryPlayer];
        
        _options = options;
    }
    return _options;
}

@end

#pragma clang diagnostic pop
#endif
