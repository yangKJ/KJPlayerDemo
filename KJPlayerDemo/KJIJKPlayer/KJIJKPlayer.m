//
//  KJIJKPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/3/1.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJIJKPlayer.h"
#import "KJIJKPlayer+KJCache.h"

#if __has_include(<IJKMediaFramework/IJKMediaFramework.h>)

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface KJIJKPlayer ()
PLAYER_COMMON_EXTENSION_PROPERTY
@property (nonatomic,strong) IJKFFMoviePlayerController *player;
@property (nonatomic,strong) IJKFFOptions *options;
@property (nonatomic,assign) CGFloat lastVolume;
@property (nonatomic,strong) NSTimer *timer;

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
    }
    return self;
}
- (void)dealloc{
    [self kj_stop];
}
#pragma mark - super method
- (void)kj_basePlayerViewChange:(NSNotification*)notification{
    [super kj_basePlayerViewChange:notification];
//    CGRect rect = [notification.userInfo[kPlayerBaseViewChangeKey] CGRectValue];
//    self.playerLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
//    if (self.playerLayer.superlayer == nil) {
//        [self.playerView.layer addSublayer:self.playerLayer];
//    }
}

#pragma mark - public method
/* 准备播放 */
- (void)kj_play{
    if (self.player == nil || self.tryLooked) return;
    self.userPause = NO;
    [self.player play];
//    self.player.muted = self.muted;
//    self.player.rate = self.speed;
}
/* 重播 */
- (void)kj_replay{
//    [self.player seekToTime:CMTimeMakeWithSeconds(self.skipHeadTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
//        if (finished) [self kj_play];
//    }];
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
//    [self kj_destroyPlayer];
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

#pragma mark - setter
- (void)setOriginalURL:(NSURL *)originalURL{
    _originalURL = originalURL;
    kGCD_player_main(^{
        self.state = KJPlayerStateBuffering;
//        if (self->_playerLayer.superlayer) {
//            [self.playerLayer removeFromSuperlayer];
//            self->_playerLayer = nil;
//        }
//        if (self.playerLayer.superlayer == nil && self.playerView) {
//            self.playerLayer.frame = self.playerView.bounds;
//            [self.playerView.layer addSublayer:self.playerLayer];
//        }
        /// 封面图
        if (self.placeholder) {
//            self.playerLayer.contents = (id)self.placeholder.CGImage;
//            self.playerLayer.contentsGravity = kPlayerContentsGravity(self.videoGravity);
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
    dispatch_group_async(self.group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
        [weakself kj_judgeHaveCacheWithVideoURL:&tempURL];
        if (![tempURL.absoluteString isEqualToString:self->_videoURL.absoluteString]) {
            self->_videoURL = tempURL;
//            [weakself kj_initPreparePlayer];
        }else{
            [weakself kj_replay];
        }
    });
}
- (void)setVolume:(float)volume{
    _volume = MIN(MAX(0, volume), 1);
//    if (self.player) self.player.playbackVolume = volume;
}
- (void)setMuted:(BOOL)muted{
    if (self.player && _muted != muted) {
//        self.player.muted = muted;
    }
    _muted = muted;
}
- (void)setSpeed:(float)speed{
//    if (self.player && fabsf(_player.rate) > 0.00001f && _speed != speed) {
//        if (speed <= 0) {
//            speed = 0.1;
//        }else if (speed >= 2){
//            speed = 2;
//        }
//        self.player.rate = speed;
//    }
    _speed = speed;
}
- (void)setVideoGravity:(KJPlayerVideoGravity)videoGravity{
//    if (_playerLayer && _videoGravity != videoGravity) {
//        _playerLayer.videoGravity = kPlayerVideoGravity(videoGravity);
//    }
    _videoGravity = videoGravity;
}
- (void)setBackground:(CGColorRef)background{
//    if (_playerLayer && _background != background) {
//        _playerLayer.backgroundColor = background;
//    }
    _background = background;
}
- (void)setTimeSpace:(NSTimeInterval)timeSpace{
    if (_timeSpace != timeSpace) {
        _timeSpace = timeSpace;
//        [self kj_addTimeObserver];
    }
}
- (void)setPlayerView:(KJBasePlayerView *)playerView{
    if (playerView == nil) return;
    _playerView = playerView;
//    self.playerLayer.frame = playerView.bounds;
//    if (self.playerLayer.superlayer == nil) {
//        [playerView.layer addSublayer:self.playerLayer];
//    }
}

#pragma mark - getter
- (BOOL)isPlaying{
//    if (@available(iOS 10.0, *)) {
//        return self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
//    }else{
//        return self.player.currentItem.status == AVPlayerStatusReadyToPlay;
//    }
    return YES;
}
/* 快进或快退 */
- (void (^)(NSTimeInterval,void (^_Nullable)(BOOL)))kVideoAdvanceAndReverse{
    PLAYER_WEAKSELF;
    return ^(NSTimeInterval seconds, void (^xxblock)(BOOL)){
        if (weakself.player) {
            [weakself.player pause];
//            [weakself.player.currentItem cancelPendingSeeks];
        }
        __block NSTimeInterval time = seconds;
        dispatch_group_notify(weakself.group, dispatch_get_main_queue(), ^{
            CMTime seekTime;
//            if (weakself.openAdvanceCache && weakself.locality == NO) {
//                if (weakself.totalTime) {
//                    NSTimeInterval _time = weakself.progress * weakself.totalTime;
//                    if (time + weakself.cacheTime >= _time) time = _time - weakself.cacheTime;
//                }else{
//                    time = weakself.currentTime;
//                }
//            }
            if (weakself.totalTime) {
                weakself.currentTime = time;
            }
            seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
//            [weakself.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
//                if (finished) [weakself kj_play];
//                if (xxblock) xxblock(finished);
//            }];
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
//        kGCD_player_async(^{
//            KJPlayerAssetType type = kPlayerVideoAesstType(self.originalURL);
//        });
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
- (IJKFFOptions *)options{
    if (!_options) {
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame" ofCategory:kIJKFFOptionCategoryCodec];
        [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter" ofCategory:kIJKFFOptionCategoryCodec];
        [options setOptionIntValue:0 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
        [options setOptionIntValue:60 forKey:@"max-fps" ofCategory:kIJKFFOptionCategoryPlayer];
        [options setPlayerOptionIntValue:256 forKey:@"vol"];
        /// 精准seek
        [options setPlayerOptionIntValue:1 forKey:@"enable-accurate-seek"];
        /// 解决http播放不了
        [options setOptionIntValue:1 forKey:@"dns_cache_clear" ofCategory:kIJKFFOptionCategoryFormat];
        _options = options;
    }
    return _options;
}

@end

#pragma clang diagnostic pop
#endif
