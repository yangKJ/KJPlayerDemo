//
//  KJPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayer.h"
#import "KJURLConnection.h"
@interface KJPlayer()
@property (nonatomic,strong) NSObject *timeObserver;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVURLAsset *asset;
@property (nonatomic,strong) KJURLConnection *connection;
@property (nonatomic,assign) KJPlayerState state;
@property (nonatomic,assign) KJPlayerErrorCode errorCode;
@property (nonatomic,assign) KJPlayerLoadState loadState;
@property (nonatomic,assign) NSTimeInterval currentTime,totalTime;
@property (nonatomic,assign) NSTimeInterval cacheDuration;
@property (nonatomic,assign) float progress;
@property (nonatomic,assign) BOOL localityData;
@property (nonatomic,assign) BOOL userPause;
@property (nonatomic,assign) CGSize videoSize;
@end
@implementation KJPlayer
PLAYER_COMMON_PROPERTY PLAYER_SHARED
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kj_playerAppWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kj_playerAppBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}
- (void)dealloc {
    [self kj_destroyPlayer];
//    if (_playerView) [self.playerLayer removeFromSuperlayer];
}

#pragma mark - NSNotification
- (void)kj_playerAppWillResignActive:(NSNotification *)notification{
    if (self.backgroundPause) [self kj_playerPause];
}
- (void)kj_playerAppBecomeActive:(NSNotification *)notification{
    if (self.roregroundResume && self.userPause == NO) [self kj_playerResume];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:kStatus]) {
        if (playerItem.status == AVPlayerStatusReadyToPlay){
            if (self.localityData && self.autoPlay) {
                [self kj_playerPlay];
            }
        }else if (playerItem.status == AVPlayerItemStatusFailed || playerItem.status == AVPlayerItemStatusUnknown){
            self.errorCode = KJPlayerErrorCodeOtherSituations;
            self.state = KJPlayerStateError;
        }
    }else if ([keyPath isEqualToString:kLoadedTimeRanges]) {
        [self kj_kvoLoadedTimeRanges:playerItem];
    }else if ([keyPath isEqualToString:kPresentationSize]) {
        if (!CGSizeEqualToSize(playerItem.presentationSize, self.videoSize)) {
            self.videoSize = playerItem.presentationSize;
            if (self.kVideoSize) self.kVideoSize(self.videoSize);
        }
    }else if ([keyPath isEqualToString:kPlaybackBufferEmpty]) {
        
    }else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp]) {
        
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
//监听播放器的加载进度
- (void)kj_kvoLoadedTimeRanges:(AVPlayerItem*)playerItem{
    if (self.localityData) return;
    CMTimeRange ranges = [[playerItem loadedTimeRanges].firstObject CMTimeRangeValue];
    CGFloat start = CMTimeGetSeconds(ranges.start);
    CGFloat duration = CMTimeGetSeconds(ranges.duration);
    CGFloat totalDuration = self.totalTime?:CMTimeGetSeconds(playerItem.duration);
    self.progress = MIN((start + duration) / totalDuration, 1);
    if (((start + duration) - self.cacheTime) >= self.currentTime && self.autoPlay) {
        [self kj_playerPlay];
    }else{
        [self.player pause];
        self.state = KJPlayerStateLoading;
    }
}

#pragma mark - public method
/* 准备播放 */
- (void)kj_playerPlay{
    if (self.player == nil) return;
    [self.player play];
    self.player.rate = self.speed;
    self.userPause = NO;
}
/* 重播 */
- (void)kj_playerReplay{
    [self kj_playerSeekTime:0 completionHandler:nil];
}
/* 继续 */
- (void)kj_playerResume{
    [self kj_playerPlay];
}
/* 暂停 */
- (void)kj_playerPause{
    if (self.player == nil) return;
    [self.player pause];
    self.state = KJPlayerStatePause;
    self.userPause = YES;
}
/* 停止 */
- (void)kj_playerStop{
    [self kj_destroyPlayer];
    self.state = KJPlayerStateStopped;
}
/* 设置开始播放时间 */
- (void)kj_playerSeekTime:(NSTimeInterval)seconds completionHandler:(void(^_Nullable)(BOOL finished))completionHandler{
    [self.player.currentItem cancelPendingSeeks];
    seconds = MIN(MAX(0, seconds), self.totalTime);
    CMTime seekTime = CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC);
    PLAYER_WEAKSELF;
    [self.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) [weakself kj_playerPlay];
        if (completionHandler) completionHandler(finished);
    }];
}

#pragma mark - private method
//初始化配置信息
- (void)kj_playerConfig{
    if (self.player && [self isPlaying]) [self.player pause];
    self.currentTime = self.totalTime = 0;
    self.localityData = self.userPause = NO;
    if (!_connection) _connection = nil;
    self.progress = 0.0;
    self.videoSize = CGSizeZero;
}
//播放准备
- (void)kj_initPreparePlayer{
    [self kj_removePlayerItem];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    [self.playerItem addObserver:self forKeyPath:kStatus options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:kLoadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:kPresentationSize options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:kPlaybackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:kPlaybackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
    if (@available(iOS 9.0, *)) {
        self.playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
    }
    if (@available(iOS 10.0, *)) {
        self.playerItem.preferredForwardBufferDuration = 5;
    }
    
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    }else{
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    }
    [self kj_addTimeObserver];
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    if (self.playerLayer) { }
}
- (void)kj_addTimeObserver{
    if (self.player == nil) return;
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
    }
    PLAYER_WEAKSELF;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(self.timeSpace, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSTimeInterval sec = CMTimeGetSeconds(time);
        if (isnan(sec) || sec < 0) sec = 0;
        weakself.currentTime = sec;
        if ([weakself.delegate respondsToSelector:@selector(kj_player:currentTime:totalTime:)]) {
            [weakself.delegate kj_player:weakself currentTime:weakself.currentTime totalTime:weakself.totalTime];
        }
        if (weakself.currentTime >= weakself.totalTime && weakself.totalTime != 0) {
            weakself.state = KJPlayerStatePlayEnd;
        }else if (weakself.userPause == NO) {
            weakself.state = KJPlayerStatePlaying;
        }
    }];
}
//销毁播放
- (void)kj_destroyPlayer{
    [self kj_playerConfig];
    [self kj_removePlayerItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player removeTimeObserver:self.timeObserver];
    _timeObserver = nil;
    _player = nil;
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
// 判断是否含有视频轨道
NS_INLINE bool kPlayerHaveTracks(NSURL *url, void(^assetblock)(AVURLAsset *), NSDictionary *requestHeader){
    if (url == nil) return false;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:requestHeader];
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

#pragma mark - setter
- (void)setVideoURL:(NSURL *)videoURL{
    [self kj_playerConfig];
    if (self.useCacheFunction) {
        NSString *path = kPlayerIntactPath(videoURL);
        self.localityData = [[NSFileManager defaultManager] fileExistsAtPath:path];
        if (self.localityData) videoURL = [NSURL fileURLWithPath:path];
    }else{
        self.state = KJPlayerStateLoading;
    }
    PLAYER_WEAKSELF;
    if (!kPlayerHaveTracks(videoURL, ^(AVURLAsset * asset) {
        weakself.totalTime = ceil(asset.duration.value / asset.duration.timescale);
        if (weakself.kVideoTotalTime) {
            weakself.kVideoTotalTime(weakself.totalTime);
        }
        if (weakself.useCacheFunction && !weakself.localityData) {
            weakself.state = KJPlayerStateLoading;
            weakself.loadState = KJPlayerLoadStateNone;
            NSURL * tempURL = weakself.connection.kj_createSchemeURL(videoURL);
            asset = [AVURLAsset URLAssetWithURL:tempURL options:weakself.requestHeader];
            [asset.resourceLoader setDelegate:weakself.connection queue:dispatch_get_main_queue()];
        }
        weakself.asset = asset;
    }, self.requestHeader)) {
        self.errorCode = KJPlayerErrorCodeVideoURLError;
        self.state = KJPlayerStateError;
        [self kj_destroyPlayer];
        _videoURL = videoURL;
        return;
    }
    if (videoURL != _videoURL) {
        _videoURL = videoURL;
        [self kj_initPreparePlayer];
    }else{
        if (self.autoPlay) {
            [self kj_playerReplay];
        }
    }
}
- (void)setVolume:(float)volume{
    _volume = MIN(MAX(0, volume), 1);
    self.player.volume = volume;
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
    if (_progress == progress || _progress == 1.) return;
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
    PLAYER_WEAKSELF;
    return ^(NSTimeInterval time) {
        if (weakself.asset == nil) return weakself.placeholder;
        AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:weakself.asset];
        assetGen.appliesPreferredTrackTransform = YES;
        CMTime actualTime;
        CGImageRef cgimage = [assetGen copyCGImageAtTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) actualTime:&actualTime error:nil];
        UIImage *videoImage = [[UIImage alloc] initWithCGImage:cgimage];
        CGImageRelease(cgimage);
        assetGen = nil;
        return videoImage?:weakself.placeholder;
    };
}


#pragma mark - lazy loading
- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.videoGravity = kPlayerVideoGravity(_videoGravity);
        _playerLayer.backgroundColor = _background;
        if (_playerView) {
            _playerLayer.frame = _playerView.bounds;
            [_playerView.layer addSublayer:_playerLayer];
        }
    }
    return _playerLayer;
}
- (KJURLConnection *)connection{
    if (!_connection) {
        _connection = [[KJURLConnection alloc] init];
        _connection.maxCacheRange = 300 * 1024;
        PLAYER_WEAKSELF;
        _connection.kURLConnectionDidFinishLoadingAndSaveFileBlcok = ^(BOOL saveSuccess) {
            if (saveSuccess) {
                weakself.progress = 1.0;
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
            weakself.state = KJPlayerStateError;
        };
    }
    return _connection;
}
    
@end
