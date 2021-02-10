//
//  KJPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayer.h"
#import "KJResourceLoader.h"
@interface KJPlayer(){
    dispatch_group_t group;
}
@property (nonatomic,strong) NSObject *timeObserver;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVURLAsset *asset;
@property (nonatomic,strong) KJResourceLoader *connection;
@property (nonatomic,assign) KJPlayerErrorCode errorCode;
@property (nonatomic,assign) KJPlayerVideoFromat fromat;
@property (nonatomic,assign) NSTimeInterval currentTime,totalTime;
@property (nonatomic,assign) NSTimeInterval tryTime;
@property (nonatomic,copy,readwrite) void(^tryTimeBlock)(bool end);
@property (nonatomic,assign) BOOL localityData;
@property (nonatomic,assign) BOOL tryLooked;
@property (nonatomic,assign) BOOL buffered;
@property (nonatomic,assign) BOOL m3u8;
@property (nonatomic,assign) KJPlayerState state;
@property (nonatomic,assign) KJPlayerLoadState loadState;
@property (nonatomic,assign) float progress;
@end
@implementation KJPlayer
PLAYER_COMMON_PROPERTY
static NSString * const kStatus = @"status";
static NSString * const kLoadedTimeRanges = @"loadedTimeRanges";
static NSString * const kPresentationSize = @"presentationSize";
static NSString * const kPlaybackBufferEmpty = @"playbackBufferEmpty";
static NSString * const kPlaybackLikelyToKeepUp = @"playbackLikelyToKeepUp";
- (instancetype)init{
    if (self == [super init]) {
        _cacheTime = 5.;
        _speed = 1.;
        _autoPlay = YES;
        _videoGravity = KJPlayerVideoGravityResizeAspect;
        _background = UIColor.blackColor.CGColor;
        _timeSpace = 1.;
        group = dispatch_group_create();
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
    if ([keyPath isEqualToString:kStatus]) {
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            if (self.seekTime) {
                if (self.autoPlay && self.userPause == NO) {
                    self.kVideoAdvanceAndReverse(self.seekTime,nil);
                }
            }else{
                [self kj_autoPlay];
            }
        }else if (playerItem.status == AVPlayerItemStatusFailed || playerItem.status == AVPlayerItemStatusUnknown) {
            self.errorCode = KJPlayerErrorCodeOtherSituations;
            self.state = KJPlayerStateFailed;
        }
    }else if ([keyPath isEqualToString:kLoadedTimeRanges]) {
        [self kj_kvoLoadedTimeRanges:playerItem];
    }else if ([keyPath isEqualToString:kPresentationSize]) {
        if (!CGSizeEqualToSize(playerItem.presentationSize, tempSize)) {
            tempSize = playerItem.presentationSize;
            if (self.kVideoSize) self.kVideoSize(tempSize);
        }
    }else if ([keyPath isEqualToString:kPlaybackBufferEmpty]) {
        if (playerItem.playbackBufferEmpty) {
            [self kj_autoPlay];
        }
    }else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp]) {
        if (playerItem.playbackLikelyToKeepUp) {
            self.buffered = YES;
            if (self.totalTime <= 0) {
                self.totalTime = CMTimeGetSeconds(playerItem.duration);
                if (self.kVideoTotalTime) self.kVideoTotalTime(self.totalTime);
            }
            self.state = KJPlayerStatePreparePlay;
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
//监听播放器缓冲进度
- (void)kj_kvoLoadedTimeRanges:(AVPlayerItem*)playerItem{
    if ((self.localityData || self.useCacheFunction) && self.m3u8 == NO) return;
    CMTimeRange ranges = [[playerItem loadedTimeRanges].firstObject CMTimeRangeValue];
    CGFloat start = CMTimeGetSeconds(ranges.start);
    CGFloat duration = CMTimeGetSeconds(ranges.duration);
    self.progress = MIN((start + duration) / self.totalTime, 1);
    if ((start + duration - self.cacheTime) >= self.currentTime ||
        (self.totalTime - self.currentTime) <= self.cacheTime) {
        [self kj_autoPlay];
    }else{
        [self.player pause];
        self.state = KJPlayerStateBuffering;
    }
}
//自动播放
- (void)kj_autoPlay{
    if (self.autoPlay && self.userPause == NO) {
        [self kj_playerPlay];
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
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(_timeSpace, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSTimeInterval sec = CMTimeGetSeconds(time);
        if (isnan(sec) || sec < 0) sec = 0;
        weakself.currentTime = sec;
        if (weakself.totalTime <= 0) return;
        if (weakself.currentTime >= weakself.totalTime) {
            [weakself.player pause];
            weakself.state = KJPlayerStatePlayFinished;
            if ([weakself.delegate respondsToSelector:@selector(kj_player:currentTime:totalTime:)]) {
                [weakself.delegate kj_player:weakself currentTime:weakself.totalTime totalTime:weakself.totalTime];
            }
            weakself.currentTime = 0;
        }else if (weakself.userPause == NO && weakself.buffered) {
            weakself.state = KJPlayerStatePlaying;
            if ([weakself.delegate respondsToSelector:@selector(kj_player:currentTime:totalTime:)]) {
                [weakself.delegate kj_player:weakself currentTime:weakself.currentTime totalTime:weakself.totalTime];
            }
        }
        if (weakself.currentTime > weakself.tryTime && weakself.tryTime) {
            if (!weakself.tryLooked) {
                weakself.tryLooked = YES;
                if (weakself.tryTimeBlock) weakself.tryTimeBlock(true);
            }
            [weakself kj_playerPause];
        }else{
            weakself.tryLooked = NO;
        }
    }];
}
#pragma mark - public method
/* 准备播放 */
- (void)kj_playerPlay{
    if (self.player == nil || self.tryLooked) return;
    [self.player play];
    self.player.muted = self.muted;
    self.player.rate = self.speed;
    self.userPause = NO;
}
/* 重播 */
- (void)kj_playerReplay{
    PLAYER_WEAKSELF;
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) [weakself kj_playerPlay];
    }];
}
/* 继续 */
- (void)kj_playerResume{
    [self kj_playerPlay];
}
/* 暂停 */
- (void)kj_playerPause{
    if (self.player == nil) return;
    [self.player pause];
    self.state = KJPlayerStatePausing;
    self.userPause = YES;
}
/* 停止 */
- (void)kj_playerStop{
    [self kj_destroyPlayer];
    self.state = KJPlayerStateStopped;
}
/* 快进或快退 */
- (void (^)(NSTimeInterval,void (^_Nullable)(bool)))kVideoAdvanceAndReverse{
    PLAYER_WEAKSELF;
    return ^(NSTimeInterval seconds,void (^xxblock)(bool)){
        if (weakself.player) {
            [weakself.player pause];
            [weakself.player.currentItem cancelPendingSeeks];
        }
        dispatch_group_notify(self->group, dispatch_get_main_queue(), ^{
            CMTime seekTime;
            if (weakself.useCacheFunction && !weakself.localityData) {
                seekTime = CMTimeMakeWithSeconds(weakself.currentTime, NSEC_PER_SEC);;
            }else{
                seekTime = CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC);
            }
            [weakself.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                if (finished) [weakself kj_playerPlay];
                if (xxblock) xxblock(finished);
            }];
        });
    };
}

#pragma mark - private method
// 判断是否含有视频轨道
NS_INLINE bool kPlayerHaveTracks(NSURL *videURL, void(^assetblock)(AVURLAsset *), NSDictionary *requestHeader){
    if (videURL == nil) return false;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videURL options:requestHeader];
    if (assetblock) assetblock(asset);
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    return [tracks count] > 0;
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
//初始化配置信息
- (void)kj_playerConfig{
    if (self.player && [self isPlaying]) [self.player pause];
    self.currentTime = self.totalTime = 0;
    self.localityData = self.userPause = NO;
    if (!_connection) _connection = nil;
    _progress = 0.0;
    tempSize = CGSizeZero;
    self.tryLooked = NO;
    self.buffered = NO;
}
- (void)kj_removePlayerItem{
    if (_playerItem == nil) return;
    [self.playerItem removeObserver:self forKeyPath:kStatus];
    [self.playerItem removeObserver:self forKeyPath:kLoadedTimeRanges];
    [self.playerItem removeObserver:self forKeyPath:kPresentationSize];
    [self.playerItem removeObserver:self forKeyPath:kPlaybackBufferEmpty];
    [self.playerItem removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
    _playerItem = nil;
}
//销毁播放
- (void)kj_destroyPlayer{
    [self kj_playerConfig];
    [self kj_removePlayerItem];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player removeTimeObserver:self.timeObserver];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    _timeObserver = nil;
    _player = nil;
}
//播放准备
- (void)kj_initPreparePlayer{
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
    PLAYER_WEAKSELF;
    kGCD_player_main(^{
        weakself.playerLayer.player = weakself.player;
    });
}
//数据处理
- (BOOL)kj_dealVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL{
    [self kj_playerConfig];
    if (self.useCacheFunction) {
        NSString *dbid = kPlayerIntactName(*videoURL);
        NSArray<DBPlayerData*>*temps = [DBPlayerDataInfo kj_checkData:dbid];
        if (temps.count) {
            NSString * path = kPlayerIntactSandboxPath(temps.firstObject.sandboxPath);
            self.localityData = [[NSFileManager defaultManager] fileExistsAtPath:path];
            if (self.localityData) {
                kGCD_player_main(^{ self.progress = 1.0;});
                *videoURL = [NSURL fileURLWithPath:path];
            }else{
                [DBPlayerDataInfo kj_deleteData:dbid];
            }
        }else{
            self.state = KJPlayerStateBuffering;
        }
    }else{
        self.state = KJPlayerStateBuffering;
    }
    PLAYER_WEAKSELF;
    if (!kPlayerHaveTracks(*videoURL, ^(AVURLAsset * asset) {
        weakself.totalTime = ceil(asset.duration.value/asset.duration.timescale);
        kGCD_player_main(^{
            if (weakself.kVideoTotalTime) weakself.kVideoTotalTime(weakself.totalTime);
        });
        if (weakself.useCacheFunction && !weakself.localityData) {
            weakself.state = KJPlayerStateBuffering;
            weakself.loadState = KJPlayerLoadStateNone;
            NSURL * tempURL = weakself.connection.kj_createSchemeURL(*videoURL);
            weakself.asset = [AVURLAsset URLAssetWithURL:tempURL options:weakself.requestHeader];
            [weakself.asset.resourceLoader setDelegate:weakself.connection queue:dispatch_get_main_queue()];
        }else{
            weakself.asset = asset;
        }
    }, self.requestHeader)) {
        self.errorCode = KJPlayerErrorCodeVideoURLFault;
        self.state = KJPlayerStateFailed;
        [self kj_destroyPlayer];
        return NO;
    }
    return YES;
}

#pragma mark - setter
- (void)setVideoURL:(NSURL *)videoURL{
    self.fromat = kPlayerFromat(videoURL);
    if (self.kVideoURLFromat) {
        self.kVideoURLFromat(self.fromat);
    }
    PLAYER_WEAKSELF;
    if (self.fromat == KJPlayerVideoFromat_none) {
        _videoURL = videoURL;
        self.errorCode = KJPlayerErrorCodeVideoURLFault;
        if (self.player) [self kj_playerStop];
        return;
    }else if (self.fromat == KJPlayerVideoFromat_m3u8) {
        self.progress = 0;
        self.m3u8 = YES;
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (![videoURL.absoluteString isEqualToString:self->_videoURL.absoluteString]) {
                self->_videoURL = videoURL;
                [weakself kj_initPreparePlayer];
            }else{
                [weakself kj_playerReplay];
            }
        });
        return;
    }
    self.m3u8 = NO;
    __block NSURL *tempURL = videoURL;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([weakself kj_dealVideoURL:&tempURL]) {
            if (![tempURL.absoluteString isEqualToString:self->_videoURL.absoluteString]) {
                self->_videoURL = tempURL;
                [weakself kj_initPreparePlayer];
            }else{
                [weakself kj_playerReplay];
            }
        }
    });
}
- (void)setVolume:(float)volume{
    _volume = MIN(MAX(0, volume), 1);
    if (self.player) self.player.volume = volume;
}
- (void)setMuted:(BOOL)muted{
    _muted = muted;
    if (self.player) self.player.muted = muted;
}
- (void)setSpeed:(float)speed{
    _speed = speed;
    if (self.player && fabsf(_player.rate) > 0.00001f) {
        self.player.rate = speed;
    }
}
- (void)setVideoGravity:(KJPlayerVideoGravity)videoGravity{
    _videoGravity = videoGravity;
    if (_playerLayer) _playerLayer.videoGravity = kPlayerVideoGravity(videoGravity);
}
- (void)setBackground:(CGColorRef)background{
    _background = background;
    if (_playerLayer) _playerLayer.backgroundColor = background;
}
- (void)setTimeSpace:(NSTimeInterval)timeSpace{
    _timeSpace = timeSpace;
    [self kj_addTimeObserver];
}
- (void)setPlayerView:(UIView *)playerView{
    _playerView = playerView;
    self.playerLayer.frame = playerView.bounds;
    [playerView.layer addSublayer:_playerLayer];
}
- (void)setState:(KJPlayerState)state{
    if (_state == state) return;
    _state = state;
    if ([self.delegate respondsToSelector:@selector(kj_player:state:)]) {
        [self.delegate kj_player:self state:state];
    }
}
- (void)setLoadState:(KJPlayerLoadState)loadState{
    if (_loadState == loadState) return;
    _loadState = loadState;
    if ([self.delegate respondsToSelector:@selector(kj_player:loadstate:)]) {
        [self.delegate kj_player:self loadstate:loadState];
    }
}
- (void)setProgress:(float)progress{
    if (_progress == progress) return;
    _progress = progress;
    if ([self.delegate respondsToSelector:@selector(kj_player:loadProgress:)]) {
        [self.delegate kj_player:self loadProgress:progress];
    }
}

#pragma mark - getter
- (BOOL)isPlaying{
    return self.player.currentItem.status == AVPlayerStatusReadyToPlay;
}
- (UIImage * _Nonnull (^)(NSTimeInterval))kPlayerTimeImage{
    return ^(NSTimeInterval time) {
        if (self.asset == nil) return self.placeholder;
        AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
        assetGen.appliesPreferredTrackTransform = YES;
        CMTime actualTime;
        CGImageRef cgimage = [assetGen copyCGImageAtTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) actualTime:&actualTime error:nil];
        UIImage *videoImage = [[UIImage alloc] initWithCGImage:cgimage];
        CGImageRelease(cgimage);
        assetGen = nil;
        return videoImage?:self.placeholder;
    };
}
- (void (^)(void (^ _Nonnull)(bool), NSTimeInterval))kVideoTryLookTime{
    return ^(void (^xxblock)(bool), NSTimeInterval time){
        self.tryTime = time;
        self.tryTimeBlock = xxblock;
    };
}

#pragma mark - lazy loading
- (AVPlayerItem *)playerItem{
    if (!_playerItem) {
        if (self.m3u8) {
            _playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
            self.asset = [_playerItem.asset copy];
        }else{
            _playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
        }
        [_playerItem addObserver:self forKeyPath:kStatus options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:kLoadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:kPresentationSize options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:kPlaybackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:kPlaybackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
        if (@available(iOS 9.0, *)) {
            _playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
        }
        if (@available(iOS 10.0, *)) {
            _playerItem.preferredForwardBufferDuration = 5;
        }
    }
    return _playerItem;
}
- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = kPlayerVideoGravity(_videoGravity);
        _playerLayer.backgroundColor = _background;
        _playerLayer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    return _playerLayer;
}
- (KJResourceLoader *)connection{
    if (!_connection) {
        _connection = [[KJResourceLoader alloc] init];
        _connection.maxCacheRange = 300 * 1024;
        _connection.videoFromat = self.fromat;
        PLAYER_WEAKSELF;
        _connection.kURLConnectionDidReceiveDataBlcok = ^(NSData * data, NSUInteger downOffect, NSUInteger totalOffect) {
            if (weakself.useCacheFunction) {
                weakself.progress = (float)downOffect/totalOffect;
            }
        };
        _connection.kURLConnectionDidFinishLoadingAndSaveFileBlcok = ^(BOOL saveSuccess) {
            if (saveSuccess) {
                weakself.loadState = KJPlayerLoadStateComplete;
            }else{
                weakself.loadState = KJPlayerLoadStateError;
            }
            weakself.localityData = saveSuccess;
        };
        _connection.kURLConnectiondidFailWithErrorCodeBlcok = ^(NSInteger code) {
            switch (code) {
                case -1001:weakself.errorCode = KJPlayerErrorCodeNetworkOvertime;break;
                case -1003:weakself.errorCode = KJPlayerErrorCodeServerNotFound;break;
                case -1004:weakself.errorCode = KJPlayerErrorCodeServerInternalError;break;
                case -1005:weakself.errorCode = KJPlayerErrorCodeNetworkInterruption;break;
                case -1009:weakself.errorCode = KJPlayerErrorCodeNetworkNoConnection;break;
                default:   weakself.errorCode = KJPlayerErrorCodeOtherSituations;break;
            }
            weakself.state = KJPlayerStateFailed;
        };
    }
    return _connection;
}

@end
