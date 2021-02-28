//
//  KJPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayer.h"
#import "KJPlayer+KJCache.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface KJPlayer()
@property (nonatomic,copy,readwrite) void(^tryTimeBlock)(void);
@property (nonatomic,copy,readwrite) void(^recordTimeBlock)(NSTimeInterval time);
@property (nonatomic,copy,readwrite) void(^skipTimeBlock)(KJPlayerVideoSkipState skipState);
@property (nonatomic,strong) NSObject *timeObserver;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItemVideoOutput *playerOutput;
@property (nonatomic,assign) NSTimeInterval currentTime,totalTime;
@property (nonatomic,assign) NSTimeInterval tryTime;
@property (nonatomic,assign) NSTimeInterval skipHeadTime;
@property (nonatomic,assign) KJPlayerState state;
@property (nonatomic,retain) dispatch_group_t group;
@property (nonatomic,assign) float progress;
@property (nonatomic,assign) BOOL cache;
@property (nonatomic,assign) BOOL userPause;
@property (nonatomic,assign) BOOL tryLooked;
@property (nonatomic,assign) BOOL buffered;
@property (nonatomic,assign) BOOL recordLastTime;
@property (nonatomic,strong) NSURL *originalURL;
@end
@implementation KJPlayer
PLAYER_COMMON_PROPERTY PLAYER_COMMON_UI_PROPERTY
static NSString * const kStatus = @"status";
static NSString * const kLoadedTimeRanges = @"loadedTimeRanges";
static NSString * const kPresentationSize = @"presentationSize";
static NSString * const kPlaybackLikelyToKeepUp = @"playbackLikelyToKeepUp";
static NSString * const kPlaybackBufferEmpty = @"playbackBufferEmpty";
static NSString * const kTimeControlStatus = @"timeControlStatus";
- (instancetype)init{
    if (self = [super init]) {
        _speed = 1.;
        _timeSpace = 1.;
        _autoPlay = YES;
        _videoGravity = KJPlayerVideoGravityResizeAspect;
        _background = UIColor.blackColor.CGColor;
        self.group = dispatch_group_create();
    }
    return self;
}
- (void)dealloc {
    [self kj_destroyPlayer];
    if (_playerView) [self.playerLayer removeFromSuperlayer];
}

#pragma mark - kvo
static CGSize tempSize;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:kStatus]) {//监听播放器状态
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            if (self.totalTime <= 0) {
                NSTimeInterval sec = CMTimeGetSeconds(playerItem.duration);
                if (isnan(sec) || sec < 0) sec = 0;
                self.totalTime = sec;
                if (self.kVideoTotalTime) self.kVideoTotalTime(self.totalTime);
            }
            self.state = KJPlayerStatePreparePlay;
        }else if (playerItem.status == AVPlayerItemStatusFailed) {
            self.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeAVPlayerItemStatusFailed];
            self.state = KJPlayerStateFailed;
        }else if (playerItem.status == AVPlayerItemStatusUnknown) {
            self.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeAVPlayerItemStatusUnknown];
            self.state = KJPlayerStateFailed;
        }
    }else if ([keyPath isEqualToString:kLoadedTimeRanges]) {//监听播放器缓冲进度
        if ((self.locality || self.cache) && self.progress != 0) return;
        CMTimeRange ranges = [[playerItem loadedTimeRanges].firstObject CMTimeRangeValue];
        CGFloat start = CMTimeGetSeconds(ranges.start);
        CGFloat duration = CMTimeGetSeconds(ranges.duration);
        CGFloat totalDuration = CMTimeGetSeconds(playerItem.duration);
        self.progress = MIN((start + duration) / totalDuration, 1);
        if (self.cacheTime == 0) {
            if (self.userPause == NO && self.isPlaying == NO) {
                [self kj_autoPlay];
            }
            return;
        }
        if ((start + duration - self.cacheTime) >= self.currentTime ||
            (totalDuration - self.currentTime) <= self.cacheTime) {
            [self kj_autoPlay];
        }else{
            [self.player pause];
            self.state = KJPlayerStateBuffering;
        }
    }else if ([keyPath isEqualToString:kPresentationSize]) {//监听视频尺寸
        if (self.playerLayer.contents) {
            self.playerLayer.contents = nil;
        }
        if (!CGSizeEqualToSize(playerItem.presentationSize, tempSize)) {
            tempSize = playerItem.presentationSize;
            if (self.kVideoSize) self.kVideoSize(tempSize);
        }
    }else if ([keyPath isEqualToString:kPlaybackBufferEmpty]) {//监听缓存不够的情况
        if (playerItem.playbackBufferEmpty) {
            self.buffered = NO;
            [self.player pause];
            self.state = KJPlayerStateBuffering;
        }
    }else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp]) {////监听缓存足够
        if (playerItem.playbackLikelyToKeepUp) {
            self.buffered = YES;
            [self kj_autoPlay];
        }
    }else if ([keyPath isEqualToString:kTimeControlStatus]) {
        NSLog(@"kTimeControlStatus:%@",object);
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
//自动播放
- (void)kj_autoPlay{
    if (self.autoPlay && self.userPause == NO) {
        [self kj_play];
    }
}
#pragma mark - 定时器
//监听时间变化
- (void)kj_addTimeObserver{
    if (self.player == nil) return;
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        _timeObserver = nil;
    }
    PLAYER_WEAKSELF;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(_timeSpace, NSEC_PER_SEC) queue:dispatch_queue_create("kj.player.time.queue", NULL) usingBlock:^(CMTime time) {
        NSTimeInterval sec = CMTimeGetSeconds(time);
        if (isnan(sec) || sec < 0) sec = 0;
        if (weakself.totalTime <= 0) return;
        if ((NSInteger)sec >= (NSInteger)weakself.totalTime) {
            [weakself.player pause];
            weakself.state = KJPlayerStatePlayFinished;
            weakself.currentTime = 0;
        }else if (weakself.userPause == NO && weakself.buffered) {
            weakself.state = KJPlayerStatePlaying;
            weakself.currentTime = sec;
        }
        if (sec > weakself.tryTime && weakself.tryTime) {
            [weakself kj_pause];
            if (!weakself.tryLooked) {
                weakself.tryLooked = YES;
                kGCD_player_main(^{
                    if (weakself.tryTimeBlock) weakself.tryTimeBlock();
                });
            }
        }else{
            weakself.tryLooked = NO;
        }
    }];
}

#pragma mark - super method
- (void)kj_basePlayerViewChange:(NSNotification*)notification{
    [super kj_basePlayerViewChange:notification];
    CGRect rect = [notification.userInfo[kPlayerBaseViewChangeKey] CGRectValue];
    self.playerLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    if (self.playerLayer.superlayer == nil) {
        [self.playerView.layer addSublayer:self.playerLayer];
    }
}

#pragma mark - public method
/* 准备播放 */
- (void)kj_play{
    if (self.player == nil || self.tryLooked) return;
    [self.player play];
    self.player.muted = self.muted;
    self.player.rate = self.speed;
    self.userPause = NO;
}
/* 重播 */
- (void)kj_replay{
    [self.player seekToTime:CMTimeMakeWithSeconds(self.skipHeadTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) [self kj_play];
    }];
}
/* 继续 */
- (void)kj_resume{
    [self kj_play];
}
/* 暂停 */
- (void)kj_pause{
    if (self.player == nil) return;
    [self.player pause];
    self.state = KJPlayerStatePausing;
    self.userPause = YES;
}
/* 停止 */
- (void)kj_stop{
    [self kj_destroyPlayer];
    self.state = KJPlayerStateStopped;
}
/* 圆圈加载动画 */
- (void)kj_startAnimation{
    [super kj_startAnimation];
}
/* 停止动画 */
- (void)kj_stopAnimation{
    [super kj_stopAnimation];
}

#pragma mark - private method
/// 销毁播放（名字不能乱改，KJCache当中有使用）
- (void)kj_destroyPlayer{
    if (self.player) {
        [self.player pause];
    }
    [self kj_removePlayerItem];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player removeTimeObserver:self.timeObserver];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    _timeObserver = nil;
    _player = nil;
    self.asset = nil;
}
/// 播放准备（名字不能乱改，KJCache当中有使用）
- (void)kj_initPreparePlayer{
    [self kj_initializeBeginPlayConfiguration];
    [self kj_removePlayerItem];
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    }else{
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        if (@available(iOS 10.0, *)) {
            if ([self.player respondsToSelector:@selector(automaticallyWaitsToMinimizeStalling)]) {
                self.player.automaticallyWaitsToMinimizeStalling = NO;
            }
        }
        self.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    }
    [self kj_addTimeObserver];
    kGCD_player_main(^{
        self.playerLayer.player = self.player;
    });
    NSTimeInterval sec = 0.0;
    if (self.asset) {
        sec = ceil(self.asset.duration.value/self.asset.duration.timescale);
    }else if (self.playerItem) {
        sec = CMTimeGetSeconds(self.playerItem.duration);
    }
    if (isnan(sec) || sec < 0) sec = 0;
    self.totalTime = sec;
    self.progress = self.locality ? 1.0 : 0.0;
    if (self.totalTime && self.kVideoTotalTime) {
        kGCD_player_main(^{
            self.kVideoTotalTime(self.totalTime);
        });
    }
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
//初始化开始播放时配置信息
- (void)kj_initializeBeginPlayConfiguration{
    if (self.player) {
        [self.player pause];
    }
    tempSize = CGSizeZero;
    self.currentTime = self.totalTime = 0.0;
    self.userPause = NO;
    self.tryLooked = NO;
    self.buffered = NO;
}
// 获取视频显示模式
NS_INLINE NSString * kPlayerVideoGravity(KJPlayerVideoGravity videoGravity){
    switch (videoGravity) {
        case KJPlayerVideoGravityResizeAspect:return AVLayerVideoGravityResizeAspect;
        case KJPlayerVideoGravityResizeAspectFill:return AVLayerVideoGravityResizeAspectFill;
        case KJPlayerVideoGravityResizeOriginal:return AVLayerVideoGravityResize;
        default:break;
    }
}
// 获取图片显示模式
NS_INLINE NSString * kPlayerContentsGravity(KJPlayerVideoGravity videoGravity){
    switch (videoGravity) {
        case KJPlayerVideoGravityResizeAspect:return @"resizeAspect";
        case KJPlayerVideoGravityResizeAspectFill:return @"resizeAspectFill";
        case KJPlayerVideoGravityResizeOriginal:return @"resize";
        default:break;
    }
}
#pragma mark - setter
- (void)setOriginalURL:(NSURL *)originalURL{
    _originalURL = originalURL;
    kGCD_player_main(^{
        self.state = KJPlayerStateBuffering;
        if (self->_playerLayer.superlayer) {
            [self.playerLayer removeFromSuperlayer];
            self->_playerLayer = nil;
        }
        if (self.playerLayer.superlayer == nil && self.playerView) {
            self.playerLayer.frame = self.playerView.bounds;
            [self.playerView.layer addSublayer:self.playerLayer];
        }
        /// 封面图
        if (self.placeholder) {
            self.playerLayer.contents = (id)self.placeholder.CGImage;
            self.playerLayer.contentsGravity = kPlayerContentsGravity(self.videoGravity);
        }
    });
}
- (void)setVideoURL:(NSURL *)videoURL{
    self.originalURL = videoURL;
    self.cache = NO;
    self.asset = nil;
    if (kPlayerVideoAesstType(videoURL) == KJPlayerAssetTypeNONE) {
        _videoURL = videoURL;
        self.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeVideoURLUnknownFormat];
        if (self.player) [self kj_stop];
        return;
    }
    PLAYER_WEAKSELF;
    __block NSURL *tempURL = videoURL;
    dispatch_group_async(self.group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (kPlayerVideoAesstType(videoURL) == KJPlayerAssetTypeFILE) {
            if (!kPlayerHaveTracks(videoURL, ^(AVURLAsset * asset) {
                weakself.asset = asset;
            }, weakself.requestHeader)) {
                weakself.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeVideoURLFault];
                weakself.state = KJPlayerStateFailed;
                [weakself kj_destroyPlayer];
                return;
            }
        }
        [weakself kj_judgeHaveCacheWithVideoURL:&tempURL];
        if (![tempURL.absoluteString isEqualToString:self->_videoURL.absoluteString]) {
            self->_videoURL = tempURL;
            [weakself kj_initPreparePlayer];
        }else{
            [weakself kj_replay];
        }
    });
}
- (void)setVolume:(float)volume{
    _volume = MIN(MAX(0, volume), 1);
    if (self.player) self.player.volume = volume;
}
- (void)setMuted:(BOOL)muted{
    if (self.player && _muted != muted) {
        self.player.muted = muted;
    }
    _muted = muted;
}
- (void)setSpeed:(float)speed{
    if (self.player && fabsf(_player.rate) > 0.00001f && _speed != speed) {
        if (speed <= 0) {
            speed = 0.1;
        }else if (speed >= 2){
            speed = 2;
        }
        self.player.rate = speed;
    }
    _speed = speed;
}
- (void)setVideoGravity:(KJPlayerVideoGravity)videoGravity{
    if (_playerLayer && _videoGravity != videoGravity) {
        _playerLayer.videoGravity = kPlayerVideoGravity(videoGravity);
    }
    _videoGravity = videoGravity;
}
- (void)setBackground:(CGColorRef)background{
    if (_playerLayer && _background != background) {
        _playerLayer.backgroundColor = background;
    }
    _background = background;
}
- (void)setTimeSpace:(NSTimeInterval)timeSpace{
    if (_timeSpace != timeSpace) {
        _timeSpace = timeSpace;
        [self kj_addTimeObserver];
    }
}
- (void)setPlayerView:(KJBasePlayerView *)playerView{
    if (playerView == nil) return;
    _playerView = playerView;
    self.playerLayer.frame = playerView.bounds;
    if (self.playerLayer.superlayer == nil) {
        [playerView.layer addSublayer:self.playerLayer];
    }
}

#pragma mark - getter
- (BOOL)isPlaying{
    if (@available(iOS 10.0, *)) {
        return self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
    }else{
        return self.player.currentItem.status == AVPlayerStatusReadyToPlay;
    }
}
/* 快进或快退 */
- (void (^)(NSTimeInterval,void (^_Nullable)(BOOL)))kVideoAdvanceAndReverse{
    PLAYER_WEAKSELF;
    return ^(NSTimeInterval seconds, void (^xxblock)(BOOL)){
        if (weakself.player) {
            [weakself.player pause];
            [weakself.player.currentItem cancelPendingSeeks];
        }
        __block NSTimeInterval time = seconds;
        dispatch_group_notify(weakself.group, dispatch_get_main_queue(), ^{
            CMTime seekTime;
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
            seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
            [weakself.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                if (finished) [weakself kj_play];
                if (xxblock) xxblock(finished);
            }];
        });
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
            if (kPlayerVideoAesstType(self.originalURL) == KJPlayerAssetTypeNONE) {
                kGCD_player_main(^{
                    if (xxblock) xxblock(nil);
                });
            }else if (kPlayerVideoAesstType(self.originalURL) == KJPlayerAssetTypeHLS) {
                CVPixelBufferRef pixelBuffer = [self.playerOutput copyPixelBufferForItemTime:self.player.currentTime itemTimeForDisplay:nil];
                CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
                CIContext *temporaryContext = [CIContext contextWithOptions:nil];
                CGImageRef imageRef = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
                UIImage *newImage = [UIImage imageWithCGImage:imageRef];
                kGCD_player_main(^{
                    if (xxblock) xxblock(newImage);
                });
                CGImageRelease(imageRef);
                CVBufferRelease(pixelBuffer);
            }else{
                AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:self.player.currentItem.asset];
                generator.appliesPreferredTrackTransform = YES;
                generator.requestedTimeToleranceAfter = kCMTimeZero;
                generator.requestedTimeToleranceBefore = kCMTimeZero;
                CGImageRef imageRef = [generator copyCGImageAtTime:self.player.currentTime actualTime:NULL error:NULL];
                UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef];
                kGCD_player_main(^{
                    if (xxblock) xxblock(newImage);
                });
                CGImageRelease(imageRef);
            }
        });
    };
}

#pragma mark - lazy loading
- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = kPlayerVideoGravity(_videoGravity);
        _playerLayer.backgroundColor = _background;
        _playerLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _playerLayer.zPosition = KJBasePlayerViewLayerZPositionPlayer;
    }
    return _playerLayer;
}
- (AVPlayerItemVideoOutput *)playerOutput{
    if (!_playerOutput) {
        _playerOutput = [[AVPlayerItemVideoOutput alloc] init];
    }
    return _playerOutput;
}
- (AVPlayerItem *)playerItem{
    if (!_playerItem) {
        if (self.asset) {
            _playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
        }else{
            _playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
            self.asset = [_playerItem.asset copy];
        }
        [_playerItem addObserver:self forKeyPath:kStatus
                         options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:kLoadedTimeRanges
                         options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:kPresentationSize
                         options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:kPlaybackBufferEmpty
                         options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:kPlaybackLikelyToKeepUp
                         options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:kTimeControlStatus
                         options:NSKeyValueObservingOptionNew context:nil];
        if (@available(iOS 9.0, *)) {
            _playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
        }
        if (@available(iOS 10.0, *)) {
            _playerItem.preferredForwardBufferDuration = 5;
        }
        if ([_playerItem respondsToSelector:@selector(setCanUseNetworkResourcesForLiveStreamingWhilePaused:)]) {
            _playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;
        }
        [_playerItem addOutput:self.playerOutput];
    }
    return _playerItem;
}
- (void)kj_removePlayerItem{
    if (_playerItem == nil) return;
    [self.playerItem removeObserver:self forKeyPath:kStatus];
    [self.playerItem removeObserver:self forKeyPath:kLoadedTimeRanges];
    [self.playerItem removeObserver:self forKeyPath:kPresentationSize];
    [self.playerItem removeObserver:self forKeyPath:kPlaybackBufferEmpty];
    [self.playerItem removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
    [self.playerItem removeObserver:self forKeyPath:kTimeControlStatus];
    _playerItem = nil;
}

@end

#pragma clang diagnostic pop
