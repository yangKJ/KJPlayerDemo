//
//  KJOldPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJOldPlayer.h"
#import "KJResourceLoader.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface KJOldPlayer ()
@property (nonatomic,strong) KJPlayerSeekBeginPlayBlock seekBeginPlayBlock;
@property (nonatomic,assign) KJPlayerState state;
@property (nonatomic,assign) KJPlayerErrorCode errorCode;
@property (nonatomic,assign) CGFloat current;//当前播放时间
@property (nonatomic,assign) CGFloat progress;
@property (nonatomic,assign) CGFloat loadedProgress;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) NSObject *periodicTimeObserver;//观察者
@property (nonatomic,assign) BOOL userPause;//是否被用户暂停
@property (nonatomic,assign) BOOL loadComplete;//是否缓存完成

/* ************** 外界需要可以访问的属性 ****************/
/* 视频总时间 */
@property (nonatomic,assign) CGFloat videoTotalTime;
/* 播放器 */
@property (nonatomic,strong) AVPlayer *videoPlayer;
/* 播放器Layer */
@property (nonatomic,strong) AVPlayerLayer *videoPlayerLayer;
/* 是否为本地资源 */
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
    _errorCode = KJPlayerErrorCodeNormal;
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
    //播放前的准备工作
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
    
    //5.设置通知和kvo
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
//    [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(seconds, self.kPlayerItem.currentTime.timescale)];
    [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(seconds, self.playerItem.currentTime.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        self.userPause = NO;
        [self.videoPlayer play];
        if (!self.playerItem.isPlaybackBufferEmpty) {
            self.state = KJPlayerStateLoading;
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
    self.state = KJPlayerStatePause;
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
    
    /// 播放进度
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
        // 不相等的时候才更新，并回调出去，否则seek时会继续跳动
        if (weakself.current != current) {
            weakself.current = current > weakself.videoTotalTime ? weakself.videoTotalTime : current;
            /// 播放进度时间处理
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
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    static BOOL kLoading = NO;
    if (kLoading) return;
    kLoading = YES;
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.videoPlayer pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        kLoading = NO;
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.userPause) return;
        [self.videoPlayer play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
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
        self.state = KJPlayerStatePause;
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
    self.state = KJPlayerStatePlayEnd;
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
        } else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            [self kj_playerStop];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {// 监听播放器的下载进度
        [self kDownloadProgressWithItem:playerItem];
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {// 监听播放器在缓冲数据的状态
        if (playerItem.isPlaybackBufferEmpty) {
            self.state = KJPlayerStateLoading;
            [self loadingSomeSecond];
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        // seekToTime后,可以正常播放，相当于readyToPlay，一般拖动滑竿菊花转，到了这个这个状态菊花隐藏
        !self.seekBeginPlayBlock?:self.seekBeginPlayBlock();
    }
}

@end

#pragma clang diagnostic pop
