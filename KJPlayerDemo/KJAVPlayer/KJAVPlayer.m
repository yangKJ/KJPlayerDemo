//
//  KJAVPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJAVPlayer.h"
//#import "KJAVPlayer+KJCache.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface KJAVPlayer()
PLAYER_COMMON_EXTENSION_PROPERTY
@property (nonatomic,strong) NSObject *timeObserver;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItemVideoOutput *playerOutput;
@property (nonatomic,strong) AVAssetImageGenerator *imageGenerator;
@end
@implementation KJAVPlayer
PLAYER_COMMON_FUNCTION_PROPERTY PLAYER_COMMON_UI_PROPERTY
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
    [self kj_changeSourceCleanJobs];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:kStatus]) {//监听播放器状态
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            if (self.playerLayer.contents) {
                self.playerLayer.contents = nil;
            }
            NSTimeInterval sec = CMTimeGetSeconds(playerItem.duration);
            if (isnan(sec) || sec < 0) sec = 0;
            if (sec) {
                self.isLiveStreaming = NO;
            }else{
                self.isLiveStreaming = YES;
            }
            if (self.totalTime <= 0) {
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
        if (self.isLiveStreaming) {//直播流媒体
            CMTimeRange ranges = [[playerItem loadedTimeRanges].firstObject CMTimeRangeValue];
            CGFloat start = CMTimeGetSeconds(ranges.start);
            CGFloat duration = CMTimeGetSeconds(ranges.duration);
            if (isnan(duration) || duration < 0) duration = 0;
            if (isnan(start) || start < 0) start = 0;
            if (duration <= self.cacheTime || start == 0) {
                [self.player pause];
                self.state = KJPlayerStateBuffering;
            }else{
                [self kj_autoPlay];
            }
            return;
        }
        if ((self.locality || self.cache) && self.progress != 0) return;
        CMTimeRange ranges = [[playerItem loadedTimeRanges].firstObject CMTimeRangeValue];
        CGFloat start = CMTimeGetSeconds(ranges.start);
        CGFloat duration = CMTimeGetSeconds(ranges.duration);
        self.progress = MIN((start + duration) / self.totalTime, 1);
        if (self.cacheTime == 0) {
            if (self.userPause == NO && self.isPlaying == NO) {
                [self kj_autoPlay];
            }
            return;
        }
        if ((start + duration - self.cacheTime) >= self.currentTime ||
            (self.totalTime - self.currentTime) <= self.cacheTime) {
            [self kj_autoPlay];
        }else{
            [self.player pause];
            self.state = KJPlayerStateBuffering;
        }
    }else if ([keyPath isEqualToString:kPresentationSize]) {//监听视频尺寸
        if (!CGSizeEqualToSize(playerItem.presentationSize, self.tempSize)) {
            self.tempSize = playerItem.presentationSize;
            if (self.kVideoSize) self.kVideoSize(self.tempSize);
        }
    }else if ([keyPath isEqualToString:kPlaybackBufferEmpty]) {//监听缓存不够的情况
        if (playerItem.playbackBufferEmpty) {
            self.buffered = NO;
            [self.player pause];
            self.state = KJPlayerStateBuffering;
        }
    }else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp]) {//监听缓存足够
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

#pragma mark - Notification
/* 监控播放完成通知 */
- (void)kj_playbackFinished:(NSNotification*)notification{
    self.state = KJPlayerStatePlayFinished;
    self.currentTime = 0;
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
        if (weakself.isLiveStreaming) return;
        NSTimeInterval sec = CMTimeGetSeconds(time);
        if (isnan(sec) || sec < 0) sec = 0;
        if (weakself.userPause == NO && weakself.buffered) {
            weakself.state = KJPlayerStatePlaying;
        }
        if ([weakself kj_tryLook:sec]) {
            [weakself kj_pause];
        }else{
            weakself.currentTime = sec;
        }
    }];
}
- (void)updateEvent{
    //解决ijkplayer内核切换时刻找不到方法崩溃
}

#pragma mark - public method
/* 准备播放 */
- (void)kj_play{
    if (self.player == nil || self.tryLooked) return;
    [super kj_play];
    [self.player play];
    self.player.muted = self.muted;
    self.player.rate = self.speed;
    self.userPause = NO;
}
/* 重播 */
- (void)kj_replay{
    [super kj_replay];
    [self.player seekToTime:CMTimeMakeWithSeconds(self.skipHeadTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) [self kj_play];
    }];
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
    [self kj_destroyPlayer];
    self.state = KJPlayerStateStopped;
}
/* 判断是否为本地缓存视频，如果是则修改为指定链接地址 */
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

#pragma mark - private method
/// 切换内核时的清理工作（名字不能改，动态切换时有使用）
- (void)kj_changeSourceCleanJobs{
    [self kj_destroyPlayer];
    if (_playerView) [self.playerLayer removeFromSuperlayer];
    _playerLayer = nil;
    _playerItem = nil;
    _playerOutput = nil;
    if (_imageGenerator) _imageGenerator = nil;
}
//加载视屏流视图（名字不能乱改，父类有调用）
- (void)kj_displayPictureWithSize:(CGSize)size{
    if (_playerView == nil) return;
    if (_playerLayer.superlayer == nil) {
        [self.playerView.layer addSublayer:self.playerLayer];
    }
    if (CGSizeEqualToSize(size, self.playerLayer.frame.size)) {
        return;
    }
    self.playerLayer.frame = CGRectMake(0, 0, size.width, size.height);
}
/// 销毁播放（名字不能乱改，KJCache当中有使用）
- (void)kj_destroyPlayer{
    if (self.player) [self.player pause];
    [self kj_removePlayerItem];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player removeTimeObserver:self.timeObserver];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    _timeObserver = nil;
    _player = nil;
    _asset = nil;
    _playerLayer = nil;
    kPlayerPerformSel(self, @"kj_closePingTimer");
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
    if (sec == 0) {
        self.isLiveStreaming = YES;
        [self kj_autoPlay];
        return;
    }
    if (self.totalTime && self.kVideoTotalTime) {
        kGCD_player_main(^{
            self.kVideoTotalTime(self.totalTime);
        });
    }
#pragma mark - 记录播放/跳过片头
    if (self.recordLastTime) {
        NSTimeInterval time = [DBPlayerDataInfo kj_getLastTimeDbid:kPlayerIntactName(self.originalURL)];
        if (self.recordTimeBlock) {
            kGCD_player_main(^{
                self.recordTimeBlock(time);
            });
        }
        self.kVideoAdvanceAndReverse(time,nil);
    }else if (self.skipHeadTime) {
        if (self.skipTimeBlock) {
            kGCD_player_main(^{
                self.skipTimeBlock(KJPlayerVideoSkipStateHead);
            });
        }
        self.kVideoAdvanceAndReverse(self.skipHeadTime,nil);
    }else{
        [self kj_autoPlay];
    }
}
//初始化开始播放时配置信息
- (void)kj_initializeBeginPlayConfiguration{
    if (self.player) [self.player pause];
    self.tempSize = CGSizeZero;
    self.currentTime = self.totalTime = 0.0;
    self.userPause = NO;
    self.tryLooked = NO;
    self.buffered = NO;
}
//自动播放
- (void)kj_autoPlay{
    if (self.autoPlay && self.userPause == NO) {
        [self kj_play];
    }
}
//试看处理
- (BOOL)kj_tryLook:(NSTimeInterval)time{
    if (!self.totalTime) {
        self.currentTime = 0;
        self.tryLooked = NO;
        return NO;
    }
    if (time >= self.tryTime && self.tryTime) {
        self.currentTime = self.tryTime;
        if (self.tryLooked == NO) {
            self.tryLooked = YES;
            kGCD_player_main(^{
                if (self.tryTimeBlock) self.tryTimeBlock();
            });
        }
    }else{
        self.currentTime = time;
        self.tryLooked = NO;
    }
    return self.tryLooked;
}
//判断是否含有视频轨道
BOOL kPlayerHaveTracks(NSURL *videoURL, void(^assetblock)(AVURLAsset *), NSDictionary *requestHeader){
    if (videoURL == nil) return NO;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:requestHeader];
    if (assetblock) assetblock(asset);
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    return [tracks count] > 0;
}

#pragma mark - setter
- (void)setOriginalURL:(NSURL *)originalURL{
    _originalURL = originalURL;
    self.state = KJPlayerStateBuffering;
    if (_playerLayer.superlayer) {
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
    [self kj_displayPictureWithSize:self.playerView.frame.size];
    if (self.placeholder) {
        self.playerLayer.contents = (id)self.placeholder.CGImage;
        switch (self.videoGravity) {
            case KJPlayerVideoGravityResizeAspect:
                self.playerLayer.contentsGravity = @"resizeAspect";
                break;
            case KJPlayerVideoGravityResizeAspectFill:
                self.playerLayer.contentsGravity = @"resizeAspectFill";
                break;
            case KJPlayerVideoGravityResizeOriginal:
                self.playerLayer.contentsGravity = @"resize";
                break;
            default:break;
        }
    }
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
        if (weakself.kPlayerDynamicChangeSource()) {
            self->_videoURL = tempURL;
            [weakself kj_initPreparePlayer];
        }else if (![tempURL.absoluteString isEqualToString:self->_videoURL.absoluteString]) {
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
        switch (videoGravity) {
            case KJPlayerVideoGravityResizeAspect:
                _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                break;
            case KJPlayerVideoGravityResizeAspectFill:
                _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                break;
            case KJPlayerVideoGravityResizeOriginal:
                _playerLayer.videoGravity = AVLayerVideoGravityResize;
                break;
            default:break;
        }
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
    [self kj_displayPictureWithSize:playerView.frame.size];
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
    return ^(NSTimeInterval seconds, void (^xxblock)(BOOL)){
        if (self.isLiveStreaming) return;
        if (self.player) {
            [self.player pause];
            [self.player.currentItem cancelPendingSeeks];
        }else{
            if (xxblock) xxblock(NO);
        }
        PLAYER_WEAKSELF;
        __block NSTimeInterval time = seconds;
        dispatch_group_notify(self.group, dispatch_get_main_queue(), ^{
            if (weakself.openAdvanceCache && weakself.locality == NO) {
                if (weakself.totalTime) {
                    NSTimeInterval _time = weakself.progress * weakself.totalTime;
                    if (time + weakself.cacheTime >= _time) time = _time - weakself.cacheTime;
                }else{
                    time = weakself.currentTime;
                }
            }
            if ([weakself kj_tryLook:time]) {
                [weakself.player seekToTime:CMTimeMakeWithSeconds(weakself.tryTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                    [weakself kj_pause];
                }];
                return;
            }else{
                weakself.currentTime = time;
            }
            [weakself.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
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
            KJPlayerAssetType type = kPlayerVideoAesstType(self.originalURL);
            if (type == KJPlayerAssetTypeNONE) {
                kGCD_player_main(^{
                    if (xxblock) xxblock(nil);
                });
            }else if (type == KJPlayerAssetTypeHLS) {
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
                CGImageRef imageRef = [self.imageGenerator copyCGImageAtTime:self.player.currentTime actualTime:NULL error:NULL];
                UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef];
                kGCD_player_main(^{
                    if (xxblock) xxblock(newImage);
                });
                CGImageRelease(imageRef);
            }
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
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:self.requestHeader];
            if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
                kGCD_player_main(^{
                    if (xxblock) xxblock(nil);
                });
            }
            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            generator.appliesPreferredTrackTransform = YES;
            generator.requestedTimeToleranceAfter = kCMTimeZero;
            generator.requestedTimeToleranceBefore = kCMTimeZero;
            CGImageRef cgimage = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) actualTime:nil error:nil];
            UIImage *videoImage = [[UIImage alloc] initWithCGImage:cgimage];
            kGCD_player_main(^{
                if (xxblock) xxblock(videoImage);
            });
            [KJCacheManager kj_saveVideoCoverImage:videoImage VideoURL:videoURL];
            CGImageRelease(cgimage);
        });
    };
}

#pragma mark - lazy loading
- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.backgroundColor = _background;
        _playerLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _playerLayer.zPosition = KJBasePlayerViewLayerZPositionPlayer;
        [self setVideoGravity:_videoGravity];
    }
    return _playerLayer;
}
- (AVPlayerItem *)playerItem{
    if (!_playerItem) {
        if (self.asset) {
            _playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
        }else{
            _playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
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
        //监控播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kj_playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        if (@available(iOS 9.0, *)) {
            _playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
        }
        if (@available(iOS 10.0, *)) {
            _playerItem.preferredForwardBufferDuration = 5;
        }
        _playerOutput = [[AVPlayerItemVideoOutput alloc] init];
        [_playerItem addOutput:_playerOutput];
        
        if (self.asset) {
            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
            generator.appliesPreferredTrackTransform = YES;
            generator.requestedTimeToleranceAfter = kCMTimeZero;
            generator.requestedTimeToleranceBefore = kCMTimeZero;
            self.imageGenerator = generator;
        }
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    _playerItem = nil;
}

@end

#pragma clang diagnostic pop
