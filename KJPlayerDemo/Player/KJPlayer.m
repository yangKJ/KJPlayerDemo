//
//  KJPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJPlayer.h"

@interface KJPlayer ()
/* 播放状态 */
@property (nonatomic,assign) KJPlayerState state;
/* 错误的code */
@property (nonatomic,assign) KJPlayerErrorCode errorCode;
/* 当前播放时间 */
@property (nonatomic,assign) CGFloat current;
/* 播放进度 0~1 */
@property (nonatomic,assign) CGFloat progress;
/* 缓冲进度 0~1 */
@property (nonatomic,assign) CGFloat loadedProgress;

@property (nonatomic,strong) KJPlayerURLConnection *kPlayerURLConnection;
@property (nonatomic,strong) AVPlayerItem *kPlayerItem;
@property (nonatomic,strong) NSObject *kPeriodicTimeObserver; /// 观察者
@property (nonatomic,assign) BOOL userPause;//是否被用户暂停
@property (nonatomic,assign) BOOL loadComplete;//是否缓存完成

/**************** 外界需要可以访问的属性 ****************/
/* 视频总时间 */
@property (nonatomic,assign) CGFloat videoTotalTime;
/* 视频第一帧图片 */
@property (nonatomic,strong) UIImage *videoFristImage;
/* 播放器 */
@property (nonatomic,strong) AVPlayer *videoPlayer;
/* 播放器Layer */
@property (nonatomic,strong) AVPlayerLayer *videoPlayerLayer;
/* 是否为本地资源 */
@property (nonatomic,assign) BOOL videoIsLocalityData;

@end

@implementation KJPlayer

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id _sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[KJPlayer alloc] init];
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
    _errorCode = KJPlayerErrorCodeNoError;
    _loadedProgress = 0.0;
    _videoTotalTime = 0.0;
    _current = 0.0;
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
    
    /// 获取视频第一帧图片和视频总时间
    NSArray *temp = [KJPlayerTool kj_playerFristImageWithURL:url];
    self.videoFristImage = temp[0];
    self.videoTotalTime = [(NSNumber*)temp[1] floatValue];
    
    // 本地文件不设置 KJPlayerStateLoading 状态
    if ([url.scheme isEqualToString:@"file"]) {
        // 如果已经在 KJPlayerStatePlaying，则直接发通知，否则设置状态
        if (_state != KJPlayerStatePlaying) {
            self.state = KJPlayerStatePlaying;
        }
    } else {
        // 如果已经在KJPlayerStateLoading，则直接发通知，否则设置状态
        if (_state != KJPlayerStateLoading) {
            self.state = KJPlayerStateLoading;
        }
    }
}

#pragma mark - public methods
- (AVPlayerLayer*)kj_playWithUrl:(NSURL*)url{
    ///1.判断本地是否有缓存
    NSString *path = [KJPlayerTool kj_playerGetIntegrityPathWithUrl:url];
    NSLog(@"%@",path);
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        self.videoIsLocalityData = YES;
        url = [NSURL fileURLWithPath:path];
    }else {
        self.videoIsLocalityData = NO;
        ///2.判断网络地址是否可用
        BOOL isUrl = [KJPlayerTool kj_playerHaveTracksWithURL:url];
        if (!isUrl) {
            self.errorCode = KJPlayerErrorCodeVideoUrlError;
            self.state = KJPlayerStateError;
            return nil;
        }
    }
    
    //3.播放前的准备工作
    [self kPlayBeforePreparationWithURL:url];
    
    //4.判断版本和是否为本地资源  iOS7以下和本地资源直接播放
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 || self.videoIsLocalityData) {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        self.kPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
        if (!self.videoPlayer) {
            self.videoPlayer = [AVPlayer playerWithPlayerItem:self.kPlayerItem];
        } else {
            [self.videoPlayer replaceCurrentItemWithPlayerItem:self.kPlayerItem];
        }
        self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    } else {
        self.kPlayerURLConnection = [[KJPlayerURLConnection alloc] init];
        [self kSetBlock]; /// 设置回调代理
        NSURL *playUrl = [self.kPlayerURLConnection kSetComponentsWithUrl:url];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:playUrl options:nil];
        [asset.resourceLoader setDelegate:self.kPlayerURLConnection queue:dispatch_get_main_queue()];
        self.kPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
        if (!self.videoPlayer) {
            self.videoPlayer = [AVPlayer playerWithPlayerItem:self.kPlayerItem];
        } else {
            [self.videoPlayer replaceCurrentItemWithPlayerItem:self.kPlayerItem];
        }
        self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    }
    
    //5.设置通知和kvo
    [self kSetNotificationAndKvo];
    
    return self.videoPlayerLayer;
}
- (void)kj_seekToTime:(CGFloat)seconds{
    if (_state == KJPlayerStateStopped) return;
    
    seconds = MAX(0, seconds);
    seconds = MIN(seconds, self.videoTotalTime);
    self.current = seconds;
    
    [self.videoPlayer pause];
    [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(seconds, self.kPlayerItem.currentTime.timescale)];
    self.userPause = NO;
    [self.videoPlayer play];
    if (!self.kPlayerItem.isPlaybackBufferEmpty) {
        self.state = KJPlayerStateLoading;
    }
}

- (void)kj_playerResume{
    if (!self.kPlayerItem) return;
    
    self.userPause = NO;
    [self.videoPlayer play];
}

- (void)kj_playerPause{
    if (!self.kPlayerItem) return;
    
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
            /// 进度处理
            if ([self.playerDelegate respondsToSelector:@selector(kj_player:Progress:CurrentTime:DurationTime:)]) {
                [self.playerDelegate kj_player:self Progress:self.progress CurrentTime:self.current DurationTime:self.videoTotalTime];
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
    /// 缓存进度处理
    if ([self.playerDelegate respondsToSelector:@selector(kj_player:LoadedProgress:LoadComplete:SaveSuccess:)]) {
        [self.playerDelegate kj_player:self LoadedProgress:loadedProgress LoadComplete:self.loadComplete SaveSuccess:NO];
    }
    if (self.kPlayerLoadingBlcok) {
        self.kPlayerLoadingBlcok(self,loadedProgress,self.loadComplete,self.videoIsLocalityData);
    }
}

- (void)setState:(KJPlayerState)state{
    if (_state == state) {
        return;
    }
    _state = state;
    /// 播放状态处理
    if ([self.playerDelegate respondsToSelector:@selector(kj_player:State:ErrorCode:)]) {
        [self.playerDelegate kj_player:self State:_state ErrorCode:self.errorCode];
    }
    if (self.kPlayerStateBlcok) {
        self.kPlayerStateBlcok(self,_state,self.errorCode);
    }
}

#pragma mark - privately methods
//清空播放器监听属性
- (void)releasePlayer{
    if (!self.kPlayerItem) return;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.kPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.kPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.kPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.kPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.videoPlayer removeTimeObserver:self.kPeriodicTimeObserver];
    self.kPeriodicTimeObserver = nil;
    self.kPlayerItem = nil;
}
/// 设置通知和kvo
- (void)kSetNotificationAndKvo{
    [self.kPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.kPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.kPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.kPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    /// 播放进度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlaybackStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.kPlayerItem];
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.kPlayerItem];
}

// 播放处理
- (void)kDealPlayWithItem:(AVPlayerItem *)playerItem{
//    self.videoTotalTime = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
    [self.videoPlayer play];
    __weak __typeof(self)weakSelf = self;
    self.kPeriodicTimeObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        CGFloat current = playerItem.currentTime.value / playerItem.currentTime.timescale;
        if (strongSelf.userPause == NO) {
            strongSelf.state = KJPlayerStatePlaying;
        }
        // 不相等的时候才更新，并发通知，否则seek时会继续跳动
        if (strongSelf.current != current) {
            strongSelf.current = current;
            if (strongSelf.current > strongSelf.videoTotalTime) {
                strongSelf.videoTotalTime = strongSelf.current;
            }
        
            /// 播放进度时间处理
            if ([strongSelf.playerDelegate respondsToSelector:@selector(kj_player:Progress:CurrentTime:DurationTime:)]) {
                [strongSelf.playerDelegate kj_player:strongSelf
                                            Progress:strongSelf.progress
                                         CurrentTime:strongSelf.current
                                        DurationTime:strongSelf.videoTotalTime];
            }
            if (strongSelf.kPlayerPlayProgressBlcok) {
                strongSelf.kPlayerPlayProgressBlcok(strongSelf,strongSelf.progress,strongSelf.current,strongSelf.videoTotalTime);
            }
        }
    }];
}
/// 缓存下载进度
- (void)kDownloadProgressWithItem:(AVPlayerItem *)playerItem{
    // 获取缓冲区域
    CMTimeRange ranges = [[playerItem loadedTimeRanges].firstObject CMTimeRangeValue];
    CGFloat start    = CMTimeGetSeconds(ranges.start);
    CGFloat duration = CMTimeGetSeconds(ranges.duration);
    // 计算缓冲总进度
    NSTimeInterval timeInterval = start + duration;
    CMTime durationTime   = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(durationTime);
    // 计算缓存进度
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.userPause) {
            kLoading = NO;
            return;
        }
        [self.videoPlayer play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        kLoading = NO;
        if (!self.kPlayerItem.isPlaybackLikelyToKeepUp) {
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
    if (!self.userPause) {
        [self kj_playerResume];
        self.state = KJPlayerStatePlaying;
    }
}
///当前视频播放结束
- (void)playerItemDidPlayToEnd:(NSNotification *)notification{
    [self kj_playerStop];
}
//在监听播放器状态中处理比较准确
- (void)playerItemPlaybackStalled:(NSNotification *)notification{
    // 这里网络不好的时候，就会进入，不做处理，会在playbackBufferEmpty里面缓存之后重新播放
    NSLog(@"buffing-----buffing");
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    /// 播放器状态
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [self kDealPlayWithItem:playerItem];// 播放处理
        } else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            [self kj_playerStop];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {/// 监听播放器的下载进度
        [self kDownloadProgressWithItem:playerItem];
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {/// 监听播放器在缓冲数据的状态
        if (playerItem.isPlaybackBufferEmpty) {
            self.state = KJPlayerStateLoading;
            [self loadingSomeSecond];
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        /// seekToTime后,可以正常播放，相当于readyToPlay，一般拖动滑竿菊花转，到了这个这个状态菊花隐藏
        
    }
}

#pragma mark - block
- (void)kSetBlock{
    __weak __typeof(self) weakSelf = self;
    self.kPlayerURLConnection.kPlayerURLConnectionDidFinishLoadingAndSaveFileBlcok = ^(KJRequestTask * _Nonnull task, BOOL saveSuccess) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        /// 回调数据出去处理
        CGFloat xx = task.completeLoad ? 1.0 : 0.0;
        strongSelf.loadComplete = task.completeLoad;
        strongSelf.videoIsLocalityData = saveSuccess;
        if ([strongSelf.playerDelegate respondsToSelector:@selector(kj_player:LoadedProgress:LoadComplete:SaveSuccess:)]) {
            [strongSelf.playerDelegate kj_player:strongSelf LoadedProgress:xx LoadComplete:task.completeLoad SaveSuccess:saveSuccess];
        }
        if (strongSelf.kPlayerLoadingBlcok) {
            strongSelf.kPlayerLoadingBlcok(strongSelf,xx,task.completeLoad,saveSuccess);
        }
    };
    self.kPlayerURLConnection.kPlayerURLConnectiondidFailWithErrorCodeBlcok = ^(KJRequestTask * _Nonnull task, NSInteger errorCode) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        switch (errorCode) {
            case -1001:
                strongSelf.errorCode = KJPlayerErrorCodeNetworkOvertime;
                break;
            case -1003:
                strongSelf.errorCode = KJPlayerErrorCodeServerNotFound;
                break;
            case -1004:
                strongSelf.errorCode = KJPlayerErrorCodeServerInternalError;
                break;
            case -1005:
                strongSelf.errorCode = KJPlayerErrorCodeNetworkInterruption;
                break;
            case -1009:
                strongSelf.errorCode = KJPlayerErrorCodeNetworkNoConnection;
                break;
            default:
                strongSelf.errorCode = KJPlayerErrorCodeOtherSituations;
                break;
        }
    };
}

@end
