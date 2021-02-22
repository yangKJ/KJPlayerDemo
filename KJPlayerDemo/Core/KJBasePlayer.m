//
//  KJBasePlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer.h"

@interface KJBasePlayer ()
@property (nonatomic,strong) UITableView *bindTableView;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) KJPlayerLoadingLayer *loadingLayer;
@property (nonatomic,strong) KJPlayerHintTextLayer *hintTextLayer;
@property (nonatomic,assign) CGFloat hintMaxWidth;
@property (nonatomic,strong) UIColor *hintBackgroundColor;
@property (nonatomic,strong) UIColor *hintTextColor;
@property (nonatomic,strong) UIFont *hintFont;
@end

@implementation KJBasePlayer
PLAYER_COMMON_PROPERTY PLAYER_COMMON_UI_PROPERTY
@synthesize kVideoCanCacheURL;
static KJBasePlayer *_instance = nil;
static dispatch_once_t onceToken;
+ (instancetype)kj_sharedInstance{
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}
+ (void)kj_attempDealloc{
    onceToken = 0;
    _instance = nil;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self kj_saveRecordLastTime];
    [_playerView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
}
- (instancetype)init{
    if (self = [super init]) {
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(kj_detectAppEnterBackground:)
                              name:UIApplicationDidEnterBackgroundNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(kj_detectAppEnterForeground:)
                              name:UIApplicationWillEnterForegroundNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(kj_basePlayerViewChange:)
                              name:kPlayerBaseViewChangeNotification object:nil];
        //kvo
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
        [self addObserver:self forKeyPath:@"state" options:options context:nil];
        [self addObserver:self forKeyPath:@"progress" options:options context:nil];
        [self addObserver:self forKeyPath:@"playError" options:options context:nil];
        [self addObserver:self forKeyPath:@"currentTime" options:options context:nil];
        
        //提示框默认值
        self.hintMaxWidth = 250;
        self.hintBackgroundColor = [UIColor.blackColor colorWithAlphaComponent:.6];
        self.hintTextColor = UIColor.whiteColor;
        self.hintFont = [UIFont systemFontOfSize:16];
    }
    return self;
}
#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"state"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:state:)]) {
            if ([change[@"new"] intValue] != [change[@"old"] intValue]) {
                kGCD_player_main(^{
                    KJPlayerState state = (KJPlayerState)[change[@"new"] intValue];
                    [self.delegate kj_player:self state:state];
                });
            }
        }
    }else if ([keyPath isEqualToString:@"progress"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:loadProgress:)]) {
            if (self.totalTime<=0) return;
            CGFloat new = [change[@"new"] floatValue];
            CGFloat old = [change[@"old"] floatValue];
            if (new != old || (new == 0 && old == 0)) {
                kGCD_player_main(^{
                    [self.delegate kj_player:self loadProgress:new];
                });
            }
        }
    }else if ([keyPath isEqualToString:@"playError"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:playFailed:)]) {
            if (change[@"new"] != change[@"old"]) {
                kGCD_player_main(^{
                    [self.delegate kj_player:self playFailed:change[@"new"]];
                });
            }
        }
    }else if ([keyPath isEqualToString:@"currentTime"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:currentTime:)]) {
            CGFloat new = [change[@"new"] floatValue];
            CGFloat old = [change[@"old"] floatValue];
            if (new != old || (new == 0 && old == 0)) {
                kGCD_player_main(^{
                    [self.delegate kj_player:self currentTime:new];
                });
            }
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSNotification
//进入后台
- (void)kj_detectAppEnterBackground:(NSNotification*)notification{
    if (self.backgroundPause) {
        [self kj_pause];
    }else{
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}
//进入前台
- (void)kj_detectAppEnterForeground:(NSNotification*)notification{
    if (self.roregroundResume && self.userPause == NO && ![self isPlaying]) {
        [self kj_resume];
    }
}
//KJBasePlayerView位置和尺寸发生变化
- (void)kj_basePlayerViewChange:(NSNotification*)notification{
    CGFloat width = self.loadingLayer.frame.size.width;
    self.loadingLayer.frame = CGRectMake((self.playerView.frame.size.width-width)/2.f, (self.playerView.frame.size.height-width)/2.f, width, width);
}
#pragma mark - child method（子类实现处理）
/* 准备播放 */
- (void)kj_play{ }
/* 重播 */
- (void)kj_replay{ }
/* 继续 */
- (void)kj_resume{ }
/* 暂停 */
- (void)kj_pause{ }
/* 停止 */
- (void)kj_stop{ }

#pragma mark - public method
- (void)kj_saveRecordLastTime{
    @synchronized (@(self.recordLastTime)) {
        if (self.recordLastTime) {
            kRecordLastTime(self.currentTime, kPlayerIntactName(self.originalURL));
        }
    }
}

#pragma mark - table
/* 列表上播放绑定tableView */
- (void)kj_bindTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    self.bindTableView = tableView;
    self.indexPath = indexPath;
}

#pragma mark - getter
@dynamic kVideoPlaceholderImage;
- (void (^)(void(^)(UIImage *image),NSURL *,NSTimeInterval))kVideoPlaceholderImage{
    return ^(void(^xxblock)(UIImage*),NSURL *videoURL,NSTimeInterval time){
        kGCD_player_async(^{
            UIImage *image = [KJCachePlayerManager kj_getVideoCoverImageWithURL:videoURL];
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
            [KJCachePlayerManager kj_saveVideoCoverImage:videoImage VideoURL:videoURL];
            CGImageRelease(cgimage);
        });
    };
}

#pragma mark - Animation
- (KJPlayerLoadingLayer *)loadingLayer{
    if (!_loadingLayer) {
        CGFloat width = 40;
        _loadingLayer = [[KJPlayerLoadingLayer alloc] init];
        [_loadingLayer kj_setAnimationSize:CGSizeMake(width, width) color:UIColor.whiteColor];
        _loadingLayer.frame = CGRectMake((self.playerView.frame.size.width-width)/2.f, (self.playerView.frame.size.height-width)/2.f, width, width);
    }
    return _loadingLayer;
}
/* 圆圈加载动画 */
- (void)kj_startAnimation{
    if (CGRectEqualToRect(CGRectZero, self.playerView.frame)) {
        return;
    }
    if (self.loadingLayer.superlayer == nil) {
        [self.playerView.layer addSublayer:self.loadingLayer];
    }
    if (self.loadingLayer.isHidden) {
        self.loadingLayer.hidden = NO;
    }
}
/* 停止动画 */
- (void)kj_stopAnimation{
    [UIView animateWithDuration:1.f animations:^{
        self.loadingLayer.hidden = YES;
    }];
}

#pragma mark - hintText
- (void (^)(CGFloat, UIColor *, UIColor *, UIFont *))kVideoHintTextProperty{
    return ^(CGFloat maxWidth, UIColor *background, UIColor *textColor, UIFont *font){
        self.hintMaxWidth = maxWidth;
        self.hintBackgroundColor = background;
        self.hintTextColor = textColor;
        self.hintFont = font;
    };
}
- (KJPlayerHintTextLayer *)hintTextLayer{
    if (!_hintTextLayer) {
        _hintTextLayer = [[KJPlayerHintTextLayer alloc] init];
        _hintTextLayer.backgroundColor = self.hintBackgroundColor.CGColor;
        [_hintTextLayer kj_setFont:self.hintFont color:self.hintTextColor];
    }
    return _hintTextLayer;
}

/* 提示文字 */
- (void)kj_displayHintText:(id)text{
    [self kj_displayHintText:text max:self.hintMaxWidth];
}
- (void)kj_displayHintText:(id)text max:(float)max{
    [self kj_displayHintText:text time:1.f max:max position:KJPlayerHintPositionCenter];
}
- (void)kj_displayHintText:(id)text position:(id)position{
    [self kj_displayHintText:text time:1.f position:position];
}
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time{
    [self kj_displayHintText:text time:time position:KJPlayerHintPositionCenter];
}
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time position:(id)position{
    [self kj_displayHintText:text time:time max:self.hintMaxWidth position:position];
}
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time max:(float)max position:(id)position{
    kGCD_player_main(^{
        if (CGRectEqualToRect(CGRectZero, self.playerView.frame)) {
            return;
        }        
    });
    [self.hintTextLayer kj_displayHintText:text time:time max:max position:position playerView:self.playerView];
    if (self.hintTextLayer.superlayer == nil) {
        [self.playerView.layer addSublayer:self.hintTextLayer];
    }
    self.hintTextLayer.hidden = NO;
    /// 先取消上次的延时执行
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(kj_hideHintText) object:nil];
    if (time) {
        [self performSelector:@selector(kj_hideHintText) withObject:nil afterDelay:time];
    }
}
/* 隐藏提示文字 */
- (void)kj_hideHintText{
    self.hintTextLayer.hidden = YES;
}

@end
