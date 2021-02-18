//
//  KJOldPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJOldPlayer.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface KJOldPlayer ()
@property (nonatomic,strong) KJPlayerSeekBeginPlayBlock seekBeginPlayBlock;
@property (nonatomic,assign) KJPlayerState state;
@property (nonatomic,assign) KJPlayerCustomCode errorCode;
@property (nonatomic,assign) CGFloat current;
@property (nonatomic,assign) CGFloat progress;
@property (nonatomic,assign) CGFloat loadedProgress;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) NSObject *periodicTimeObserver;
@property (nonatomic,assign) BOOL userPause;
@property (nonatomic,assign) BOOL loadComplete;
@property (nonatomic,assign) CGFloat videoTotalTime;
@property (nonatomic,strong) AVPlayer *videoPlayer;
@property (nonatomic,strong) AVPlayerLayer *videoPlayerLayer;
@property (nonatomic,assign) BOOL videoIsLocalityData;
@end

@implementation KJOldPlayer
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id _sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)dealloc{
    [self releasePlayer];
}

#pragma mark - init methods
/// 初始化配置
- (void)config{
    _stopWhenAppEnterBackground = YES;
    _state = KJPlayerStateStopped;
    _errorCode = KJPlayerCustomCodeNormal;
    _loadedProgress = 0.0;
    _videoTotalTime = 0.0;
    _current  = 0.0;
    _progress = 0.0;
    _userPause = YES;
    _loadComplete = NO;
    _videoIsLocalityData = NO;
}
- (instancetype)init{
    if (self == [super init]) {
        [self config];
    }
    return self;
}
/// 播放前的准备工作
- (void)kPlayBeforePreparationWithURL:(NSURL*)url{
    [self.videoPlayer pause];
    [self releasePlayer];
    self.loadedProgress = 0;
    self.current = 0;
    self.userPause = NO;
    self.loadComplete = NO;
    self.videoTotalTime = 0;
}
#pragma mark - public methods
- (AVPlayerLayer*)kj_playerPlayWithURL:(NSURL*)url{
    [self kPlayBeforePreparationWithURL:url];
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
    self.playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    if (self.videoPlayer == nil) {
        self.videoPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.videoPlayer.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    }else{
        [self.videoPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
    }
    self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    [self kSetNotificationAndKvo];
    return self.videoPlayerLayer;
}
/* 重播放地址 */
- (void)kj_playerReplayWithURL:(NSURL*)url{
    [self kj_playerPlayWithURL:url];
}
// 切换倍速
- (void)switchingTimesSpeed:(CGFloat)speed{
    self.videoPlayer.rate = speed;
}
// 从此刻开始播放
- (void)kj_playerSeekToTime:(CGFloat)seconds BeginPlayBlock:(KJPlayerSeekBeginPlayBlock)block{
    if (_state == KJPlayerStateStopped) return;
    self.seekBeginPlayBlock = block;
    seconds = MIN(MAX(0, seconds), self.videoTotalTime);
    self.current = seconds;
    [self.videoPlayer pause];
    [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(seconds, self.playerItem.currentTime.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        self.userPause = NO;
        [self.videoPlayer play];
        if (!self.playerItem.isPlaybackBufferEmpty) {
            self.state = KJPlayerStateBuffering;
        }
    }];
}
- (void)kj_playerResume{
    if (!self.playerItem) return;
    self.userPause = NO;
    [self.videoPlayer play];
}
- (void)kj_playerPause{
    if (!self.playerItem) return;
    self.userPause = YES;
    self.state = KJPlayerStatePausing;
    [self.videoPlayer pause];
}
- (void)kj_playerStop{
    [self.videoPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            self.userPause = YES;
            self.current = 0;
            self.state = KJPlayerStateStopped;
            [self.videoPlayer pause];
            [self releasePlayer];
            if ([self.delegate respondsToSelector:@selector(kj_player:Progress:CurrentTime:DurationTime:)]) {
                [self.delegate kj_player:self Progress:self.progress CurrentTime:self.current DurationTime:self.videoTotalTime];
            }
            if (self.kPlayerPlayProgressBlcok) {
                self.kPlayerPlayProgressBlcok(self,self.progress,self.current,self.videoTotalTime);
            }
        }
    }];
}

#pragma mark - seter/geter
- (CGFloat)progress{
    if (self.videoTotalTime > 0) return self.current / self.videoTotalTime;
    return 0;
}
- (void)setLoadedProgress:(CGFloat)loadedProgress{
    if (_loadedProgress == loadedProgress) return;
    _loadedProgress = loadedProgress;
    if (loadedProgress == 1.0 || loadedProgress == 0.0) return;
    if ([self.delegate respondsToSelector:@selector(kj_player:LoadedProgress:LoadComplete:SaveSuccess:)]) {
        [self.delegate kj_player:self LoadedProgress:loadedProgress LoadComplete:self.loadComplete SaveSuccess:NO];
    }
    if (self.kPlayerLoadingBlcok) {
        self.kPlayerLoadingBlcok(self,loadedProgress,self.loadComplete,self.videoIsLocalityData);
    }
}

- (void)setState:(KJPlayerState)state{
    if (_state == state) return;
    _state = state;
    if ([self.delegate respondsToSelector:@selector(kj_player:State:ErrorCode:)]) {
        [self.delegate kj_player:self State:_state ErrorCode:self.errorCode];
    }
    if (self.kPlayerStateBlcok) {
        self.kPlayerStateBlcok(self,_state,self.errorCode);
    }
}

#pragma mark - privately methods
//清空播放器监听属性
- (void)releasePlayer{
    if (!self.playerItem) return;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.videoPlayer removeTimeObserver:self.periodicTimeObserver];
    self.periodicTimeObserver = nil;
    self.playerItem = nil;
}
/// 设置通知和kvo
- (void)kSetNotificationAndKvo{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    if (self.stopWhenAppEnterBackground) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    }
    if (self.useOpenAppEnterBackground) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlaybackStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.playerItem];
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}
// 播放处理
- (void)kDealPlayWithItem:(AVPlayerItem *)playerItem{
    [self.videoPlayer play];
    PLAYER_WEAKSELF;
    self.periodicTimeObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat current = playerItem.currentTime.value / playerItem.currentTime.timescale;
        if (weakself.userPause == NO) {
            weakself.state = KJPlayerStatePlaying;
        }
        if (weakself.current != current) {
            weakself.current = current > weakself.videoTotalTime ? weakself.videoTotalTime : current;
            if ([weakself.delegate respondsToSelector:@selector(kj_player:Progress:CurrentTime:DurationTime:)]) {
                [weakself.delegate kj_player:weakself Progress:weakself.progress CurrentTime:weakself.current DurationTime:weakself.videoTotalTime];
            }
            if (weakself.kPlayerPlayProgressBlcok) {
                weakself.kPlayerPlayProgressBlcok(weakself,weakself.progress,weakself.current,weakself.videoTotalTime);
            }
        }
    }];
}
/// 缓存下载进度
- (void)kDownloadProgressWithItem:(AVPlayerItem *)playerItem{
    CMTimeRange ranges = [[playerItem loadedTimeRanges].firstObject CMTimeRangeValue];
    CGFloat start    = CMTimeGetSeconds(ranges.start);
    CGFloat duration = CMTimeGetSeconds(ranges.duration);
    NSTimeInterval timeInterval = start + duration;
    CMTime durationTime   = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(durationTime);
    self.loadedProgress = timeInterval / totalDuration;
}
/// 提前缓存一点数据
- (void)loadingSomeSecond{
    static BOOL kLoading = NO;
    if (kLoading) return;
    kLoading = YES;
    [self.videoPlayer pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        kLoading = NO;
        if (self.userPause) return;
        [self.videoPlayer play];
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            [self loadingSomeSecond];
        }
    });
}

#pragma mark - observer
///进入后台
- (void)appDidEnterBackground{
    if (self.stopWhenAppEnterBackground) {
        [self kj_playerPause];
        self.state = KJPlayerStatePausing;
        self.userPause = NO;
    }
}
///从后台返回
- (void)appDidEnterPlayGround{
    if (!self.userPause && self.useOpenAppEnterBackground) {
        [self kj_playerResume];
        self.state = KJPlayerStatePlaying;
    }
}
///当前视频播放结束
- (void)playerItemDidPlayToEnd:(NSNotification *)notification{
    self.state = KJPlayerStatePlayFinished;
    [self.videoPlayer pause];
}
//在监听播放器状态中处理比较准确
- (void)playerItemPlaybackStalled:(NSNotification *)notification{
    // 这里网络不好的时候，就会进入，不做处理，会在playbackBufferEmpty里面缓存之后重新播放
    NSLog(@"buffing-----buffing");
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            self.videoTotalTime = CMTimeGetSeconds(playerItem.duration);
            if (self.kVideoTotalTime) self.kVideoTotalTime(self.videoTotalTime);
            [self kDealPlayWithItem:playerItem];
        }else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            [self kj_playerStop];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        [self kDownloadProgressWithItem:playerItem];
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        if (playerItem.isPlaybackBufferEmpty) {
            self.state = KJPlayerStateBuffering;
            [self loadingSomeSecond];
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        !self.seekBeginPlayBlock?:self.seekBeginPlayBlock();
    }
}

@end

#pragma clang diagnostic pop
