//
//  KJAVPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJAVPlayer.h"
#import "KJPlayerView.h"

@interface KJAVPlayer ()
PLAYER_COMMON_EXTENSION_PROPERTY
@property (nonatomic,strong) NSObject *timeObserver;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItemVideoOutput *playerOutput;
@property (nonatomic,strong) AVAssetImageGenerator *imageGenerator;

@end

@implementation KJAVPlayer
PLAYER_COMMON_FUNCTION_PROPERTY
PLAYER_COMMON_UI_PROPERTY
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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if (object != _playerItem) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
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
            } else {
                self.isLiveStreaming = YES;
            }
            if (self.totalTime <= 0) {
                self.totalTime = sec;
                if ([self.delegate respondsToSelector:@selector(kj_player:videoTime:)]) {
                    [self.delegate kj_player:self videoTime:self.totalTime];
                }
            }
            self.state = KJPlayerStatePreparePlay;
        }else if (playerItem.status == AVPlayerItemStatusFailed) {
            PLAYER_NOTIFICATION_CODE(self, @(KJPlayerCustomCodeAVPlayerItemStatusFailed));
            self.state = KJPlayerStateFailed;
        }else if (playerItem.status == AVPlayerItemStatusUnknown) {
            PLAYER_NOTIFICATION_CODE(self, @(KJPlayerCustomCodeAVPlayerItemStatusUnknown));
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
            } else {
                [self kj_autoPlay];
            }
            return;
        }
        // 开启缓存资源? 本地资源?
        if (([self.bridge kj_readStatus:520] || [self.bridge kj_readStatus:521]) && self.progress != 0) {
            return;
        }
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
        } else {
            [self.player pause];
            self.state = KJPlayerStateBuffering;
        }
    }else if ([keyPath isEqualToString:kPresentationSize]) {//监听视频尺寸
        if (!CGSizeEqualToSize(playerItem.presentationSize, self.tempSize)) {
            self.tempSize = playerItem.presentationSize;
            if ([self.delegate respondsToSelector:@selector(kj_player:videoSize:)]) {
                [self.delegate kj_player:self videoSize:self.tempSize];
            }
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
    } else {
        
    }
}

#pragma mark - Notification
/// 监控播放完成通知 
- (void)kj_playbackFinished:(NSNotification*)notification{
    self.state = KJPlayerStatePlayFinished;
    self.currentTime = 0;
}

#pragma mark - timer
/// 监听时间变化
- (void)kj_addTimeObserver{
    if (self.player == nil) return;
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        _timeObserver = nil;
    }
    PLAYER_WEAKSELF;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(_timeSpace, NSEC_PER_SEC)
                                                                  queue:dispatch_queue_create("kj.player.time.queue", NULL)
                                                             usingBlock:^(CMTime time) {
        if (weakself.isLiveStreaming) return;
        NSTimeInterval sec = CMTimeGetSeconds(time);
        if (isnan(sec) || sec < 0) sec = 0;
        if (weakself.userPause == NO && weakself.buffered) {
            weakself.state = KJPlayerStatePlaying;
        }
        if ([weakself.bridge kj_playingFunction:sec]) {
            [weakself kj_pause];
        } else {
            weakself.currentTime = sec;
        }
    }];
}

#pragma mark - public method

/// 准备播放 
- (void)kj_play{
    if (self.player == nil || self.tryLooked) return;
    [super kj_play];
    [self.player play];
    self.player.muted = self.muted;
    self.player.rate = self.speed;
    self.userPause = NO;
}
/// 重播 
- (void)kj_replay{
    [super kj_replay];
    [self.player seekToTime:CMTimeMakeWithSeconds(self.skipHeadTime, NSEC_PER_SEC)
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero
          completionHandler:^(BOOL finished) {
        if (finished) [self kj_play];
    }];
}
/// 继续 
- (void)kj_resume{
    [super kj_resume];
    [self kj_play];
}
/// 暂停 
- (void)kj_pause{
    [super kj_pause];
    if (self.player == nil) return;
    [self.player pause];
    self.state = KJPlayerStatePausing;
    self.userPause = YES;
}
/// 停止 
- (void)kj_stop{
    [super kj_stop];
    [self kj_destroyPlayer];
    self.state = KJPlayerStateStopped;
}

#pragma mark - private method

/// 切换内核时的清理工作（名字不能改，动态切换时有使用）
- (void)kj_changeSourceCleanJobs{
    [self kj_destroyPlayer];
}
/// 加载视屏流视图（名字不能乱改，父类有调用）
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
/// 销毁播放
- (void)kj_destroyPlayer{
    if (self.player) [self.player pause];
    [self kj_removePlayerItem];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player removeTimeObserver:self.timeObserver];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    if (_playerLayer) {
        [self.playerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
    _timeObserver = nil;
    _player = nil;
    _asset = nil;
    _playerItem = nil;
    _playerOutput = nil;
    _imageGenerator = nil;
}
/// 播放准备
- (void)kj_initPreparePlayer{
    [self kj_removePlayerItem];
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    } else {
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
    // 读取当前资源是否为本地资源
    self.progress = [self.bridge kj_readStatus:521] ? 1.0 : 0.0;
    if (sec == 0) {
        self.isLiveStreaming = YES;
        [self kj_autoPlay];
        return;
    }
    if (self.totalTime) {
        kGCD_player_main(^{
            if ([self.delegate respondsToSelector:@selector(kj_player:videoTime:)]) {
                [self.delegate kj_player:self videoTime:self.totalTime];
            }
        });
    }
    if (![self.bridge kj_beginFunction]) {
        [self kj_autoPlay];
    }
}
/// 初始化开始播放时配置信息
- (void)kj_initializeBeginPlayConfiguration{
    if (self.player) [self.player pause];
    self.tempSize = CGSizeZero;
    self.currentTime = self.totalTime = 0.0;
    self.userPause = NO;
    self.tryLooked = NO;
    self.buffered = NO;
    self.asset = nil;
    self.isLiveStreaming = NO;
}
/// 自动播放
- (void)kj_autoPlay{
    if (self.autoPlay && self.userPause == NO) {
        [self kj_play];
    }
}
/// 判断是否含有视频轨道
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
    PLAYER_WEAKSELF;
    weakself.originalURL = [videoURL copy];
    dispatch_group_async(self.group, dispatch_get_global_queue(0, 0), ^{
        [weakself kj_initializeBeginPlayConfiguration];
        KJPlayerAssetType assetType = kPlayerVideoAesstType(videoURL);
        if (assetType == KJPlayerAssetTypeNONE) {
            PLAYER_NOTIFICATION_CODE(weakself, @(KJPlayerCustomCodeVideoURLUnknownFormat));
            if (weakself.player) [weakself kj_stop];
            self->_videoURL = videoURL;
            return;
        }
        // 获取本地缓存视频地址，
        // 如果存在`anyObject`会更改为缓存地址
        // 不存在则还是原先的视频地址
        weakself.bridge.anyObject = videoURL;
        [weakself.bridge kj_verifyCacheVideoURL];
        
        // 边播边下边存？
        bool cache = [weakself.bridge kj_readStatus:520];
        if (assetType == KJPlayerAssetTypeHLS && cache) {
            if (!kPlayerHaveTracks(videoURL, ^(AVURLAsset * asset) {
                weakself.asset = asset;
            }, weakself.requestHeader)) {
                PLAYER_NOTIFICATION_CODE(weakself, @(KJPlayerCustomCodeVideoURLFault));
                weakself.state = KJPlayerStateFailed;
                [weakself kj_destroyPlayer];
                return;
            }
        }
        // 本地资源？
        bool local = [weakself.bridge kj_readStatus:521];
        if (assetType == KJPlayerAssetTypeFILE) {
            if (!kPlayerHaveTracks(videoURL, ^(AVURLAsset * asset) {
                if (cache && local == false) {
                    SEL sel = NSSelectorFromString(@"kj_cachePlayVideoURL:");
                    if ([self respondsToSelector:sel]) {
                        IMP imp = [self methodForSelector:sel];
                        void (* tempFunc)(id, SEL, NSURL *) = (void *)imp;
                        tempFunc(self, sel, videoURL);
                    }
                } else {
                    weakself.asset = asset;
                }
            }, weakself.requestHeader)) {
                PLAYER_NOTIFICATION_CODE(weakself, @(KJPlayerCustomCodeVideoURLFault));
                weakself.state = KJPlayerStateFailed;
                [weakself kj_destroyPlayer];
                return;
            }
        }
        self->_videoURL = weakself.bridge.anyObject;
        [weakself kj_initPreparePlayer];
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
- (void)setPlayerView:(KJPlayerView *)playerView{
    if (playerView == nil) return;
    _playerView = playerView;
    [self kj_displayPictureWithSize:playerView.frame.size];
}

#pragma mark - getter

- (BOOL)isPlaying{
    if (@available(iOS 10.0, *)) {
        return self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
    } else {
        return self.player.currentItem.status == AVPlayerStatusReadyToPlay;
    }
}
/// 指定时间播放，快进或快退功能
- (void)kj_appointTime:(NSTimeInterval)time completionHandler:(void(^_Nullable)(BOOL))completionHandler{
    if (self.isLiveStreaming) return;
    PLAYER_WEAKSELF;
    dispatch_group_notify(self.group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (weakself.player) {
            [weakself.player pause];
            [weakself.player.currentItem cancelPendingSeeks];
        } else {
            if (completionHandler) completionHandler(NO);
        }
        NSTimeInterval seconds = time;
        // 本地资源？
        if ([weakself.bridge kj_readStatus:521] == false && weakself.openAdvanceCache) {
            if (weakself.totalTime) {
                NSTimeInterval _time = weakself.progress * weakself.totalTime;
                if (seconds + weakself.cacheTime >= _time) seconds = _time - weakself.cacheTime;
            } else {
                seconds = weakself.currentTime;
            }
        }
        if ([weakself.bridge kj_playingFunction:seconds]) {
            [weakself.player seekToTime:CMTimeMakeWithSeconds(weakself.tryTime, NSEC_PER_SEC)
                        toleranceBefore:kCMTimeZero
                         toleranceAfter:kCMTimeZero
                      completionHandler:^(BOOL finished) {
                PLAYER_STRONGSELF;
                [strongself kj_pause];
            }];
            return;
        } else {
            weakself.currentTime = seconds;
        }
        [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC)
                toleranceBefore:kCMTimeZero
                 toleranceAfter:kCMTimeZero
              completionHandler:^(BOOL finished) {
            if (finished) {
                [weakself kj_play];
            }
            if (completionHandler) completionHandler(finished);
        }];
    });
}

/// 获取当前时间截屏
/// @param screenshots 截屏回调
- (void)kj_currentTimeScreenshots:(void(^)(UIImage * image))screenshots{
    self.bridge.anyObject = self.playerOutput;
    self.bridge.anyOtherObject = self.imageGenerator;
    [self.bridge kj_anyArgumentsIndex:520 withBlock:^(UIImage * image){
        screenshots ? screenshots(image) : nil;
    }];
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
        } else {
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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(kj_playbackFinished:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:_playerItem];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:_playerItem];
    _playerItem = nil;
}

@end
