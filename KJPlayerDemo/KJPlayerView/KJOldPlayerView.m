//
//  KJOldPlayerView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJOldPlayerView.h"
#import <MediaPlayer/MPVolumeView.h> 
#import <QuartzCore/QuartzCore.h>
/// 设置图片
#define PLAYER_GET_BUNDLE_IMAGE(imageName) \
([UIImage imageNamed:[@"KJPlayerView.bundle" stringByAppendingPathComponent:(imageName)]])
@implementation UIButton (KJPlayerAreaInsets)
- (UIEdgeInsets)touchAreaInsets{
    return [objc_getAssociatedObject(self, @selector(touchAreaInsets)) UIEdgeInsetsValue];
}
- (void)setTouchAreaInsets:(UIEdgeInsets)touchAreaInsets{
    NSValue *value = [NSValue valueWithUIEdgeInsets:touchAreaInsets];
    objc_setAssociatedObject(self, @selector(touchAreaInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    UIEdgeInsets touchAreaInsets = self.touchAreaInsets;
    CGRect bounds = self.bounds;
    bounds = CGRectMake(bounds.origin.x - touchAreaInsets.left,
                        bounds.origin.y - touchAreaInsets.top,
                        bounds.size.width + touchAreaInsets.left + touchAreaInsets.right,
                        bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom);
    return CGRectContainsPoint(bounds, point);
}
@end

@interface KJOldPlayerView ()<KJOldPlayerDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) id videoURL;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) KJOldPlayer *player;
@property (nonatomic,strong) KJPlayerViewConfiguration *configuration;

/* ************* 记录视图初始位置 ***************/
/* 父视图 */
@property (nonatomic,assign) CGRect superViewFrame;
/* 底部操作工具栏 */
@property (nonatomic,assign) CGRect bottomViewFrame;
/* 顶部操作工具栏 */
@property (nonatomic,assign) CGRect topViewFrame;
/* 开始播放前背景占位图片 */
@property (nonatomic,assign) CGRect coverImageViewFrame;
/* 显示播放视频的title */
@property (nonatomic,assign) CGRect topTitleLabelFrame;
/* 控制全屏的按钮 */
@property (nonatomic,assign) CGRect fullScreenButtonFrame;
/* 播放暂停按钮 */
@property (nonatomic,assign) CGRect playOrPauseButtonFrame;
/* 左上角关闭按钮 */
@property (nonatomic,assign) CGRect backButtonFrame;
/* 右上角功能按钮 */
@property (nonatomic,assign) CGRect functionButtonFrame;
/* 菊花（加载框）*/
@property (nonatomic,assign) CGRect loadingViewFrame;
/* 快进快退 */
@property (nonatomic,assign) CGRect fastViewFrame;
/* 显示播放时间的UILabel */
@property (nonatomic,assign) CGRect leftTimeLabelFrame;
@property (nonatomic,assign) CGRect rightTimeLabelFrame;
/* 播放进度滑块 */
@property (nonatomic,assign) CGRect playScheduleSliderFrame;
/* 显示缓冲进度 */
@property (nonatomic,assign) CGRect loadingProgressFrame;

@end

@implementation KJOldPlayerView

- (void)dealloc{
    if (self.configuration.openGravitySensing == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [self invalidateTimer];
}

- (void)config{
    if (self.configuration.openGravitySensing == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    self.videoIndex = 0;
    _seekTime = 0.0;
}

/* 初始化 */
- (instancetype)initWithFrame:(CGRect)frame Configuration:(KJPlayerViewConfiguration*)configuration{
    if (self = [super initWithFrame:frame]) {
        self.configuration = configuration;
        [self config];
        [self kSetUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.configuration = [[KJPlayerViewConfiguration alloc] init];
        [self config];
        [self kSetUI];
    }
    return self;
}
#pragma mark - getter/setter
- (KJOldPlayer*)player{
    if (!_player) {
        _player = [KJOldPlayer sharedInstance];
        _player.delegate = self;
        _player.stopWhenAppEnterBackground = self.configuration.stopWhenAppEnterBackground;
        _player.useOpenAppEnterBackground = self.configuration.continuePlayWhenAppReception;
    }
    return _player;
}
- (void)setVideoModel:(KJPlayerViewModel *)videoModel{
    if (videoModel == nil) return;
    _videoModel = videoModel;
    NSString *url = [self kj_getCurrentURL];
    if (url) self.videoURL = self.configuration.url = url;
}
- (NSString*)kj_getCurrentURL{
    return ({
        NSString *name;
        switch (_videoModel.priorityType) {
            case KJPlayerViewModelPriorityTypeSD:
                name = [self kj_getPlayURL:_videoModel.sd:_videoModel.cif:_videoModel.hd];
                break;
            case KJPlayerViewModelPriorityTypeCIF:
                name = [self kj_getPlayURL:_videoModel.cif:_videoModel.sd:_videoModel.hd];
                break;
            case KJPlayerViewModelPriorityTypeHD:
                name = [self kj_getPlayURL:_videoModel.hd:_videoModel.cif:_videoModel.sd];
                break;
            default:
                break;
        }
        name;
    });
}
/// 得到当前播放的视频地址
- (NSString*)kj_getPlayURL:(NSString*)x :(NSString*)y :(NSString*)z{
    return (x || y) == 0 ? z : (x?:y);
}
- (void)setVideoURL:(id)videoURL{
    _videoURL = videoURL;
    if (![videoURL isKindOfClass:[NSURL class]]) {
        videoURL = [NSURL URLWithString:videoURL];
    }
    self.configuration.url = videoURL;
    if (self.playerLayer == nil) {
        self.playerLayer = [self.player kj_playerPlayWithURL:videoURL];
        self.playerLayer.frame = self.bounds;
        [self.contentView.layer addSublayer:self.playerLayer];
    }else{
        [self.player kj_playerReplayWithURL:videoURL];
    }
    [self kPlayBeforePlan];
}
- (void)setSeekTime:(CGFloat)seekTime{
    _seekTime = seekTime;
    [self kStartLoading];
    PLAYER_WEAKSELF;
    [self.player kj_playerSeekToTime:seekTime BeginPlayBlock:^{
        [weakself kStartPlay];
    }];
}
- (void)setVideoModelTemps:(NSArray<KJPlayerViewModel*>*)videoModelTemps{
    _videoModelTemps = videoModelTemps;
    self.videoModel = videoModelTemps[self.videoIndex];
}
#pragma mark - public methods
/// 播放的准备工作
- (void)kPlayBeforePlan{
    PLAYER_WEAKSELF;
    if (self.configuration.haveFristImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            weakself.configuration.videoImage = [self kj_playerFristImageWithURL:weakself.configuration.url];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.coverImageView.image = weakself.configuration.videoImage ?: PLAYER_GET_BUNDLE_IMAGE(@"kj_player_background");
            });
        });
    }
    self.playerLayer.videoGravity = self.configuration.videoGravity;
    self.player.kVideoTotalTime = ^(NSTimeInterval time) {
        weakself.configuration.totalTime = time;
        weakself.rightTimeLabel.text = kPlayerConvertTime(time);
        weakself.playScheduleSlider.maximumValue = time;
    };
    self.leftTimeLabel.text  = kPlayerConvertTime(self.configuration.currentTime);
    [self.loadingProgress setProgress:self.player.videoIsLocalityData?1.0:0.0 animated:YES];
    self.playScheduleSlider.value = self.configuration.currentTime;
    self.playOrPauseButton.selected = YES;
    self.configuration.hasMoved = self.fastView.moveGestureFast = NO;
}
// 获取视频第一帧图片
- (UIImage*)kj_playerFristImageWithURL:(NSURL*)url{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CGImageRef image = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    UIImage *videoImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

#pragma mark - KJPlayerDelegate
- (void)kj_player:(KJOldPlayer *)player LoadedProgress:(CGFloat)loadedProgress LoadComplete:(BOOL)complete SaveSuccess:(BOOL)saveSuccess {
    [self.loadingProgress setProgress:loadedProgress animated:YES];
}
- (void)kj_player:(KJOldPlayer *)player Progress:(CGFloat)progress CurrentTime:(CGFloat)currentTime DurationTime:(CGFloat)durationTime {
    if (self.fastView.moveGestureFast == NO) {
        self.leftTimeLabel.text = kPlayerConvertTime(currentTime);
        self.playScheduleSlider.value = currentTime;
        self.configuration.currentTime = currentTime;
    }
}
- (void)kj_player:(KJOldPlayer *)player State:(KJPlayerState)state ErrorCode:(KJPlayerCustomCode)errorCode {
    self.configuration.state = state;
    switch (state) {
        case KJPlayerStateBuffering:
            [self kStartLoading];
            break;
        case KJPlayerStatePlaying:
            [self kStartPlay];
            break;
        case KJPlayerStatePlayFinished:
            [self kPlayEnd];
            break;
        case KJPlayerStateStopped:
            [self kStoppp];
            break;
        case KJPlayerStatePausing:
            break;
        case KJPlayerStateFailed:
            break;
        default:
            break;
    }
}
/// 加载的相关操作
- (void)kStartLoading{
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    self.playOrPauseButton.selected = NO;
}
/// 开始播放的相关操作
- (void)kStartPlay{
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.coverImageView.hidden = YES;
    }];
    self.playOrPauseButton.selected = YES;
    [self setupTimer];
}
/// 播放完成playEnd的相关操作
- (void)kPlayEnd{
    switch (self.configuration.playType) {
        case KJPlayerPlayTypeOnce:
            [self kStoppp];
            break;
        case KJPlayerPlayTypeReplay:
            [self kReplayXXXXX];
            break;
        case KJPlayerPlayTypeOrder:{
            if (self.videoModelTemps.count == 0 || self.videoModelTemps.count == 1) {
                [self kReplayXXXXX];
            }else if(self.videoModelTemps.count > 1){
                self.videoIndex += 1;
                self.videoIndex = self.videoIndex >= self.videoModelTemps.count ? 0 : self.videoIndex;
                self.videoModel = self.videoModelTemps[self.videoIndex];
                [self kReplayXXXXX];
            }
        }
            break;
        case KJPlayerPlayTypeRandom:{
            if (self.videoModelTemps.count == 0 || self.videoModelTemps.count == 1) {
                [self kReplayXXXXX];
            }else if(self.videoModelTemps.count > 1){
                while (1) {
                    NSInteger idx = arc4random() % (self.videoModelTemps.count);
                    if (self.videoIndex != idx) {
                        self.videoIndex = idx;
                        break;
                    }
                }
                self.videoModel = self.videoModelTemps[self.videoIndex];
                [self kReplayXXXXX];
            }
        }
            break;
        default:
            break;
    }
}
/// 重复播放操作
- (void)kReplayXXXXX{
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    self.coverImageView.hidden = NO;
    self.playScheduleSlider.value = 0;
    self.configuration.currentTime = _seekTime = 0.0;
    self.videoURL = self.configuration.url;
}
/// 播放Stop的相关操作
- (void)kStoppp{
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    self.coverImageView.hidden = NO;
    self.playOrPauseButton.selected = NO;
    self.playScheduleSlider.value = 0;
    self.configuration.currentTime = _seekTime = 0.0;
    if (self.bottomView.alpha == 0.0) {
        [self showControlView];
    }
}

#pragma mark - privately methods
/// 释放计时器
- (void)invalidateTimer{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissBottomView:) object:nil];
    [_timer invalidate];
    _timer = nil;
}
/// 创建定时器
- (void)setupTimer{
    if (self.configuration.autoHideTime <= 0) return;
    [self invalidateTimer];
    NSTimer *timer = [NSTimer timerWithTimeInterval:self.configuration.autoHideTime
                                             target:self
                                           selector:@selector(autoDismissBottomView:)
                                           userInfo:nil
                                            repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.timer = timer;
}
///显示操作栏view
- (void)showControlView{
    [self setupTimer];
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.alpha = 1.0;
        self.topView.alpha = 1.0;
    }];
}
///隐藏操作栏view
- (void)hiddenControlView{
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.alpha = 0.0;
        self.topView.alpha = 0.0;
        if (self.fastView.moveGestureFast == NO) {
            self.fastView.hidden = YES;
        }
    }];
}
/// 自动隐藏控制面板
- (void)autoDismissBottomView:(NSTimer*)timer{
    if (self.configuration.state == KJPlayerStatePlaying) {
        if (self.bottomView.alpha == 1.0) {
            [self hiddenControlView];
            [self invalidateTimer];
        }
    }
}
/// 全屏和半屏切换
- (void)kFullWithDirection:(KJPlayerDeviceDirection)direction{
    if (direction == KJPlayerDeviceDirectionLeft) {
        [UIView animateWithDuration:0.5 animations:^{
            self.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0, 0, 1);
            self.layer.frame = CGRectMake(0, 0, PLAYER_SCREEN_WIDTH, PLAYER_SCREEN_HEIGHT);
            self.playerLayer.frame = self.bounds;
            self.coverImageView.frame = self.bounds;
            
            self.fastView.center = CGPointMake(PLAYER_SCREEN_HEIGHT*.5, PLAYER_SCREEN_WIDTH*.5);
            self.loadingView.center = CGPointMake(PLAYER_SCREEN_HEIGHT*.5, PLAYER_SCREEN_WIDTH*.5);
            
            self.topView.frame = CGRectMake(0, 0, PLAYER_SCREEN_HEIGHT, 50);
            self.topView.backgroundColor = PLAYER_UIColorFromHEXA(0x000000, 0.8);
            self.backButton.center = CGPointMake(self.backButton.center.x + 10, self.topView.center.y);
            self.functionButton.center = CGPointMake(PLAYER_SCREEN_HEIGHT - 10 - self.functionButton.frame.size.width, self.topView.center.y);
            self.topTitleLabel.center = CGPointMake(self.topTitleLabel.center.x + 10, self.topView.center.y);
            
            self.bottomView.frame = CGRectMake(0, PLAYER_SCREEN_WIDTH-50, PLAYER_SCREEN_HEIGHT, 50);
            self.bottomView.backgroundColor = PLAYER_UIColorFromHEXA(0x000000, 0.8);
            
            CGFloat bottomCenterY = self.bottomView.frame.size.height*.5;
            self.playOrPauseButton.center = CGPointMake(30, bottomCenterY);
            self.leftTimeLabel.center = CGPointMake(70, bottomCenterY);
            self.leftTimeLabel.textAlignment = NSTextAlignmentCenter;
            self.fullScreenButton.center = CGPointMake(PLAYER_SCREEN_HEIGHT - CGRectGetWidth(self.fullScreenButton.frame)*.5, bottomCenterY);
            
            self.definitionButton.hidden = NO;
            self.definitionButton.center = CGPointMake(CGRectGetMinX(self.fullScreenButton.frame)-CGRectGetWidth(self.definitionButton.frame)*.5, bottomCenterY);
            self.downloadButton.hidden = NO;
            self.downloadButton.center = CGPointMake(CGRectGetMinX(self.definitionButton.frame)-CGRectGetWidth(self.downloadButton.frame)*.5-10, bottomCenterY);
            self.collectButton.hidden = NO;
            self.collectButton.center = CGPointMake(CGRectGetMinX(self.downloadButton.frame)-CGRectGetWidth(self.collectButton.frame)*.5-10, bottomCenterY);
            
            self.rightTimeLabel.center = CGPointMake(CGRectGetMinX(self.collectButton.frame)-CGRectGetWidth(self.rightTimeLabel.frame)*.5-10, bottomCenterY);
            self.rightTimeLabel.textAlignment = NSTextAlignmentCenter;
            CGFloat loadingWidth = CGRectGetMinX(self.rightTimeLabel.frame) - CGRectGetMaxX(self.leftTimeLabel.frame) - 10;
            self.loadingProgress.frame = CGRectMake(CGRectGetMaxX(self.leftTimeLabel.frame)+5, 0, loadingWidth, 2);
            self.loadingProgress.center = CGPointMake(self.loadingProgress.center.x, bottomCenterY);
            self.playScheduleSlider.frame = CGRectMake(0, 0, CGRectGetWidth(self.loadingProgress.frame)+6, 20);
            self.playScheduleSlider.center = self.loadingProgress.center;
        } completion:^(BOOL finished) {
            
        }];
    }else if (direction == KJPlayerDeviceDirectionRight){
        [UIView animateWithDuration:0.5 animations:^{
            self.layer.transform = CATransform3DMakeRotation(M_PI/2, 0, 0, 1);
            self.layer.frame = CGRectMake(0, 0, PLAYER_SCREEN_WIDTH, PLAYER_SCREEN_HEIGHT);
            self.playerLayer.frame = self.bounds;
            self.coverImageView.frame = self.bounds;
            
            self.fastView.center = CGPointMake(PLAYER_SCREEN_HEIGHT*.5, PLAYER_SCREEN_WIDTH*.5);
            self.loadingView.center = CGPointMake(PLAYER_SCREEN_HEIGHT*.5, PLAYER_SCREEN_WIDTH*.5);
            
            self.topView.frame = CGRectMake(0, 0, PLAYER_SCREEN_HEIGHT, 50);
            self.topView.backgroundColor = PLAYER_UIColorFromHEXA(0x000000, 0.8);
            self.backButton.center = CGPointMake(self.backButton.center.x + 10, self.topView.center.y);
            self.functionButton.center = CGPointMake(PLAYER_SCREEN_HEIGHT - 10 - self.functionButton.frame.size.width, self.topView.center.y);
            self.topTitleLabel.center = CGPointMake(self.topTitleLabel.center.x + 10, self.topView.center.y);
            
            self.bottomView.frame = CGRectMake(0, PLAYER_SCREEN_WIDTH-50, PLAYER_SCREEN_HEIGHT, 50);
            self.bottomView.backgroundColor = PLAYER_UIColorFromHEXA(0x000000, 0.8);
            
            CGFloat bottomCenterY = self.bottomView.frame.size.height*.5;
            self.playOrPauseButton.center = CGPointMake(30, bottomCenterY);
            self.leftTimeLabel.center = CGPointMake(70, bottomCenterY);
            self.leftTimeLabel.textAlignment = NSTextAlignmentCenter;
            self.fullScreenButton.center = CGPointMake(PLAYER_SCREEN_HEIGHT - CGRectGetWidth(self.fullScreenButton.frame)*.5, bottomCenterY);
            
            self.definitionButton.hidden = NO;
            self.definitionButton.center = CGPointMake(CGRectGetMinX(self.fullScreenButton.frame)-CGRectGetWidth(self.definitionButton.frame)*.5, bottomCenterY);
            self.downloadButton.hidden = NO;
            self.downloadButton.center = CGPointMake(CGRectGetMinX(self.definitionButton.frame)-CGRectGetWidth(self.downloadButton.frame)*.5-10, bottomCenterY);
            self.collectButton.hidden = NO;
            self.collectButton.center = CGPointMake(CGRectGetMinX(self.downloadButton.frame)-CGRectGetWidth(self.collectButton.frame)*.5-10, bottomCenterY);
            
            self.rightTimeLabel.center = CGPointMake(CGRectGetMinX(self.collectButton.frame)-CGRectGetWidth(self.rightTimeLabel.frame)*.5-10, bottomCenterY);
            self.rightTimeLabel.textAlignment = NSTextAlignmentCenter;
            CGFloat loadingWidth = CGRectGetMinX(self.rightTimeLabel.frame) - CGRectGetMaxX(self.leftTimeLabel.frame) - 10;
            self.loadingProgress.frame = CGRectMake(CGRectGetMaxX(self.leftTimeLabel.frame)+5, 0, loadingWidth, 2);
            self.loadingProgress.center = CGPointMake(self.loadingProgress.center.x, bottomCenterY);
            self.playScheduleSlider.frame = CGRectMake(0, 0, CGRectGetWidth(self.loadingProgress.frame)+6, 20);
            self.playScheduleSlider.center = self.loadingProgress.center;
        } completion:^(BOOL finished) {
            
        }];
    }else if (direction == KJPlayerDeviceDirectionTop || direction == KJPlayerDeviceDirectionBottom){
        [UIView animateWithDuration:0.3 animations:^{
            self.layer.transform = CATransform3DIdentity;
            self.layer.frame = self.superViewFrame;
            self.playerLayer.frame = self.bounds;
            self.coverImageView.frame = self.coverImageViewFrame;
            self.topView.backgroundColor = UIColor.clearColor;
            self.topView.frame = self.topViewFrame;
            self.bottomView.backgroundColor = UIColor.clearColor;
            self.bottomView.frame = self.bottomViewFrame;
            self.topTitleLabel.frame = self.topTitleLabelFrame;
            self.backButton.frame = self.backButtonFrame;
            self.functionButton.frame = self.functionButtonFrame;
            self.playOrPauseButton.frame = self.playOrPauseButtonFrame;
            self.loadingProgress.frame = self.loadingProgressFrame;
            self.playScheduleSlider.frame = self.playScheduleSliderFrame;
            self.leftTimeLabel.frame = self.leftTimeLabelFrame;
            self.leftTimeLabel.textAlignment = NSTextAlignmentLeft;
            self.rightTimeLabel.frame = self.rightTimeLabelFrame;
            self.rightTimeLabel.textAlignment = NSTextAlignmentRight;
            self.fullScreenButton.frame = self.fullScreenButtonFrame;
            self.fastView.frame = self.fastViewFrame;
            self.loadingView.frame = self.loadingViewFrame;
            self.definitionButton.hidden = YES;
            self.downloadButton.hidden = YES;
            self.collectButton.hidden = YES;
            self.lightView.hidden = YES;
        }];
    }
}

#pragma mark - 通知事件处理
/** 旋转屏幕通知 */
- (void)onDeviceOrientationChange{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    KJPlayerDeviceDirection direction = KJPlayerDeviceDirectionCustom;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            direction = KJPlayerDeviceDirectionTop;
            self.configuration.fullScreen = NO;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            direction = KJPlayerDeviceDirectionBottom;
            self.configuration.fullScreen = NO;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            direction = KJPlayerDeviceDirectionLeft;
            self.configuration.fullScreen = YES;
            break;
        case UIInterfaceOrientationLandscapeRight:
            direction = KJPlayerDeviceDirectionRight;
            self.configuration.fullScreen = YES;
            break;
        default:
            break;
    }
    if (direction == KJPlayerDeviceDirectionCustom) return;
    /// 当前手机方向  同时也控制全屏和半屏切换  全屏：left和right  半屏：top和bottom
    if ([self.delegate respondsToSelector:@selector(kj_PlayerView:DeviceDirection:)]) {
        if ([self.delegate kj_PlayerView:self DeviceDirection:direction]) return;
    }
    /// 旋转屏幕
    [self kFullWithDirection:(direction)];
}

#pragma mark - 事件处理
// 全屏切换
- (void)fullScreenAction:(UIButton*)sender{
    sender.selected = !sender.selected;
    self.configuration.fullScreen = sender.selected;
    if ([self.delegate respondsToSelector:@selector(kj_PlayerView:DeviceDirection:)]) {
        if ([self.delegate kj_PlayerView:self DeviceDirection:KJPlayerDeviceDirectionRight]) return;
    }
    [self kFullWithDirection:sender.selected?(KJPlayerDeviceDirectionRight):(KJPlayerDeviceDirectionTop)];
}
// 播放和暂停
- (void)playOrPauseAction:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (self.configuration.state == KJPlayerStatePausing) {
        [self.player kj_playerResume];
    }else if (self.configuration.state == KJPlayerStatePlaying){
        [self.player kj_playerPause];
    }else if (self.configuration.state == KJPlayerStateStopped){
        self.videoURL = self.configuration.url;
    }
}
// 返回按钮
- (void)goBackAction:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(kj_PlayerView:PlayerState:TopButton:)]) {
        [self.delegate kj_PlayerView:self PlayerState:self.configuration.state TopButton:sender];
    }
}
// 功能按钮事件
- (void)functionButtonAction:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(kj_PlayerView:PlayerState:TopButton:)]) {
        [self.delegate kj_PlayerView:self PlayerState:self.configuration.state TopButton:sender];
    }
}
//底部按钮事件处理
- (void)kBottomButtonAction:(UIButton*)sender{
    if (sender.tag == 522) {
        if (self.configuration.useCustomDefinition) {
            PLAYER_WEAKSELF;
            [KJDefinitionView createDefinitionView:^KJPlayerViewModel * _Nonnull(KJDefinitionView * _Nonnull obj) {
                obj.KJAddView(weakself);
                obj.KJConfiguration(weakself.configuration);
                return weakself.videoModel;
            } ModelBlock:^(KJPlayerViewModel * _Nonnull model) {
                weakself.videoModel = model;
                weakself.seekTime = weakself.configuration.currentTime;
            }];
            return;
        }
    }
    if ([self.delegate respondsToSelector:@selector(kj_PlayerView:BottomButton:)]) {
        [self.delegate kj_PlayerView:self BottomButton:sender];
    }
}
///进度条的拖拽事件 监听UISlider拖动状态
- (void)sliderValueChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch *touchEvent = [[event allTouches]anyObject];
    switch(touchEvent.phase) {
        case UITouchPhaseBegan:
            [self.player kj_playerPause];
            self.playOrPauseButton.selected = NO;
            break;
        case UITouchPhaseMoved:
            self.leftTimeLabel.text = kPlayerConvertTime(slider.value);
            break;
        case UITouchPhaseEnded:
            [self.player kj_playerResume];
            self.playOrPauseButton.selected = YES;
            CGFloat second = slider.value;
            [self.playScheduleSlider setValue:second animated:YES];
            self.configuration.currentTime = second;
            [self.player kj_playerSeekToTime:second BeginPlayBlock:^{
                
            }];
            break;
        default:
            break;
    }
}
//视频进度条的点击事件
- (void)tapGestureForSlider:(UITapGestureRecognizer *)gesture{
    CGPoint touchLocation = [gesture locationInView:self.playScheduleSlider];
    CGFloat value = (self.playScheduleSlider.maximumValue - self.playScheduleSlider.minimumValue) * (touchLocation.x / self.playScheduleSlider.frame.size.width);
    [self.playScheduleSlider setValue:value animated:YES];
    self.configuration.currentTime = value;
    [self.player kj_playerSeekToTime:value BeginPlayBlock:^{
        
    }];
}

#pragma mark - 手势事件处理
// 单击手势方法
- (void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [UIView animateWithDuration:0.5 animations:^{
        if (self.bottomView.alpha == 0.0) {
            [self showControlView];
        }else{
            [self hiddenControlView];
        }
    }];
}
/// 点击标题也触发返回
- (void)topTitleSingleTap:(UITapGestureRecognizer *)sender{
    [self goBackAction:self.backButton];
}
// 双击手势方法
- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap{
    [self playOrPauseAction:self.playOrPauseButton];
    [self showControlView];
}

#pragma mark - touches
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1) {
        return;
    }
    if (![[(UITouch *)touches.anyObject view] isEqual:self.contentView] && ![[(UITouch *)touches.anyObject view] isEqual:self]) {
        return;
    }
    [super touchesBegan:touches withEvent:event];
    
    //触摸开始, 初始化一些值
    self.configuration.hasMoved = NO;
    self.fastView.touchBeginValue = self.playScheduleSlider.value;
    //位置
    self.configuration.touchBeginPoint = [touches.anyObject locationInView:self];
    //亮度
    self.lightView.changeLightValue = NO;
    //声音
    self.configuration.touchBeginVoiceValue = self.volumeSlider.value;
}
/// 滑动当中
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1  || event.allTouches.count > 1) {
        return;
    }
    if (![[(UITouch *)touches.anyObject view] isEqual:self.contentView] && ![[(UITouch *)touches.anyObject view] isEqual:self]) {
        return;
    }
    [super touchesMoved:touches withEvent:event];
    
    //1.如果移动的距离过于小  判断为没有移动
    CGPoint tempPoint = [touches.anyObject locationInView:self];
    if (fabs(tempPoint.x - self.configuration.touchBeginPoint.x) < self.configuration.gestureSliderMinX &&
        fabs(tempPoint.y - self.configuration.touchBeginPoint.y) < self.configuration.gestureSliderMinX) {
        return;
    }
    
    //2.滑动角度的tan值  判断出使什么控制手势
    float tan = fabs(tempPoint.y - self.configuration.touchBeginPoint.y) / fabs(tempPoint.x - self.configuration.touchBeginPoint.x);
    if (tan < 1 / sqrt(3)) {  //当滑动角度小于30度的时候, 进度手势
        self.configuration.gestureType = KJPlayerGestureTypeProgress;
        if (!self.configuration.playProgressGesture) {
            return;
        }
    }else if(tan > sqrt(3)){  //当滑动角度大于60度的时候, 声音和亮度
        //判断是在屏幕的左半边还是右半边滑动, 左侧控制为亮度, 右侧控制音量
        if (self.configuration.touchBeginPoint.x < self.bounds.size.width*0.5) {
            self.configuration.gestureType = KJPlayerGestureTypeBrightness;
            self.lightView.changeLightValue = YES;
        }else{
            self.configuration.gestureType = KJPlayerGestureTypeVolume;
        }
        if (!self.configuration.enableVolumeGesture) {
            return;
        }
    }else{ //如果是其他角度则不是任何控制
        return;
    }
    
    //3.手势事件处理
    if (self.configuration.gestureType == KJPlayerGestureTypeProgress) { //如果是进度手势
        CGFloat value = [self kmoveFastViewWithTempPoint:tempPoint];
        /// 设置快进数据
        self.fastView.moveGestureFast = YES;
        [self.fastView kj_updateFastValue:value TotalTime:self.configuration.totalTime];
        self.leftTimeLabel.text = kPlayerConvertTime(value);
        [self.playScheduleSlider setValue:value animated:YES];
    }else if(self.configuration.gestureType == KJPlayerGestureTypeVolume){ //如果是音量手势
        if (self.configuration.fullScreen) {//全屏的时候才开启音量的手势调节
            //根据触摸开始时的音量和触摸开始时的点去计算出现在滑动到的音量
            CGFloat value = self.configuration.touchBeginVoiceValue - ((tempPoint.y - self.configuration.touchBeginPoint.y)/self.bounds.size.height);
            //判断控制一下, 不能超出 0~1
            value = MIN(MAX(0, value), 1);
            self.volumeSlider.value = value;
        }
    }else if(self.configuration.gestureType == KJPlayerGestureTypeBrightness){ //如果是亮度手势
        if (self.configuration.fullScreen) {
            //根据触摸开始时的亮度, 和触摸开始时的点来计算出现在的亮度
            CGFloat value = self.lightView.touchBeginLightValue - ((tempPoint.y - self.configuration.touchBeginPoint.y)/self.bounds.size.height);
            // 实时改变现实亮度进度
            [self.lightView kj_updateLightValue:value];
        }
    }
    /// 有移动距离
    self.configuration.hasMoved = YES;
}
/// 触摸结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    self.fastView.moveGestureFast = NO;
    self.lightView.changeLightValue = NO;
    //判断是否移动过
    if (self.configuration.hasMoved &&
        self.configuration.playProgressGesture && // 是否使用手势控制播放进度
        self.configuration.gestureType == KJPlayerGestureTypeProgress) { //进度控制就跳到响应的进度
        CGPoint tempPoint = [touches.anyObject locationInView:self];
        CGFloat second = [self kmoveFastViewWithTempPoint:tempPoint];
        self.configuration.currentTime = second;
        [self.player kj_playerSeekToTime:second BeginPlayBlock:^{
            
        }];
    }
}
// 用来控制移动过程中计算手指划过的时间
- (CGFloat)kmoveFastViewWithTempPoint:(CGPoint)tempPoint{
    //整个屏幕代表的时间
    CGFloat tempValue = self.fastView.touchBeginValue + self.configuration.totalTime * ((tempPoint.x - self.configuration.touchBeginPoint.x) / (self.frame.size.width));
    tempValue = MIN(MAX(0.0, tempValue), self.configuration.totalTime);
    return tempValue;
}

#pragma mark - kSetUI
- (void)kSetUI{
    [self addSubview:self.contentView];
    [self addSubview:self.coverImageView];
    [self addSubview:self.loadingView];
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self addSubview:self.fastView];
    [self addSubview:self.lightView];
    
    [self.bottomView addSubview:self.playOrPauseButton];
    [self.bottomView addSubview:self.leftTimeLabel];
    [self.bottomView addSubview:self.rightTimeLabel];
    [self.bottomView addSubview:self.fullScreenButton];
    [self.bottomView addSubview:self.loadingProgress];
    [self.bottomView addSubview:self.playScheduleSlider];
    
    [self.topView addSubview:self.backButton];
    [self.topView addSubview:self.functionButton];
    [self.topView addSubview:self.topTitleLabel];
    
    // 单击的 Recognizer
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    // 双击的 Recognizer
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [singleTap setDelaysTouchesBegan:YES];
    [doubleTap setDelaysTouchesBegan:YES];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

#pragma mark - lazy
- (UIView*)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:self.bounds];
        self.superViewFrame = self.frame;
    }
    return _contentView;
}
- (UIImageView*)coverImageView{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _coverImageView.contentMode = UIViewContentModeScaleToFill;
        _coverImageView.image = PLAYER_GET_BUNDLE_IMAGE(@"kj_player_background");
        self.coverImageViewFrame = _coverImageView.frame;
    }
    return _coverImageView;
}
- (KJOldFastView*)fastView{
    if (!_fastView) {
        _fastView = [[KJOldFastView alloc]initWithFrame:CGRectMake(0, 0, 160, 75)];
        _fastView.center = self.contentView.center;
        _fastView.moveGestureFast = NO;
        _fastView.progressView.progressTintColor = self.configuration.mainColor;
        self.fastViewFrame = _fastView.frame;
    }
    return _fastView;
}
- (UISlider*)volumeSlider{
    if (!_volumeSlider) {
        MPVolumeView *volumeView = [[MPVolumeView alloc]init];
        volumeView.transform = CGAffineTransformMakeRotation(M_PI/2);
        for (UIControl *view in volumeView.subviews) {
            if ([view.superclass isSubclassOfClass:[UISlider class]]) {
                _volumeSlider = (UISlider*)view;
            }
        }
    }
    return _volumeSlider;
}
- (KJLightView*)lightView{
    if (!_lightView) {
        _lightView = [[KJLightView alloc] initWithFrame:CGRectMake(PLAYER_SCREEN_HEIGHT - 30 - 20, 50 + 20, 30, PLAYER_SCREEN_WIDTH - 100 - 40)];
        _lightView.changeLightValue = NO;
        CGFloat value = [UIScreen mainScreen].brightness;
        [_lightView kj_updateLightValue:value];
    }
    return _lightView;
}
- (UIActivityIndicatorView*)loadingView{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadingView.center = self.contentView.center;
        [_loadingView startAnimating];
        self.loadingViewFrame = _loadingView.frame;
    }
    return _loadingView;
}
- (UIImageView*)topView{
    if (!_topView) {
        _topView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 70)];
        _topView.image = PLAYER_GET_BUNDLE_IMAGE(@"kj_player_top_shadow");
        _topView.userInteractionEnabled = YES;
        self.topViewFrame = _topView.frame;
    }
    return _topView;
}
- (UIImageView*)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-50, self.frame.size.width, 50)];
        _bottomView.image = PLAYER_GET_BUNDLE_IMAGE(@"kj_player_bottom_shadow");
        _bottomView.userInteractionEnabled = YES;
        self.bottomViewFrame = _bottomView.frame;
    }
    return _bottomView;
}
- (UIButton*)playOrPauseButton{
    if (!_playOrPauseButton) {
        _playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playOrPauseButton.frame = CGRectMake(0, 0, 50, 50);
        [_playOrPauseButton addTarget:self action:@selector(playOrPauseAction:) forControlEvents:UIControlEventTouchUpInside];
        [_playOrPauseButton setImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_播放-全屏") forState:UIControlStateNormal];
        [_playOrPauseButton setImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_暂停-全屏") forState:UIControlStateSelected];
        _playOrPauseButton.selected = YES;
        self.playOrPauseButtonFrame = _playOrPauseButton.frame;
    }
    return _playOrPauseButton;
}
- (UISlider*)playScheduleSlider{
    if (!_playScheduleSlider) {
        _playScheduleSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_loadingProgress.frame)+6, 20)];
        _playScheduleSlider.center = _loadingProgress.center;
        _playScheduleSlider.backgroundColor = [UIColor clearColor];
        _playScheduleSlider.minimumValue = 0.0;
        [_playScheduleSlider setThumbImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_dot")  forState:UIControlStateNormal];
        _playScheduleSlider.minimumTrackTintColor = self.configuration.mainColor;
        _playScheduleSlider.maximumTrackTintColor = [UIColor clearColor];
        _playScheduleSlider.value = 0.0;
        [_playScheduleSlider addTarget:self action:@selector(sliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureForSlider:)];
        tap.delegate = self;
        [_playScheduleSlider addGestureRecognizer:tap];
        self.playScheduleSliderFrame = _playScheduleSlider.frame;
    }
    return _playScheduleSlider;
}
- (UIProgressView*)loadingProgress{
    if (!_loadingProgress) {
        CGFloat x = 45 + 40;
        _loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _loadingProgress.frame = CGRectMake(x, self.bottomView.frame.size.height/2-1, self.bottomView.frame.size.width-2*x, 2);
        _loadingProgress.trackTintColor = UIColor.lightGrayColor;
        _loadingProgress.progressTintColor = UIColor.whiteColor;
        [_loadingProgress setProgress:0.0 animated:NO];
        self.loadingProgressFrame = _loadingProgress.frame;
    }
    return _loadingProgress;
}
- (UILabel*)leftTimeLabel{
    if (!_leftTimeLabel) {
        _leftTimeLabel = [UILabel new];
        _leftTimeLabel.frame = CGRectMake(45, self.bottomView.frame.size.height/2-10, 40, 20);
        _leftTimeLabel.textAlignment = NSTextAlignmentLeft;
        _leftTimeLabel.textColor = [UIColor whiteColor];
        _leftTimeLabel.font = [UIFont systemFontOfSize:11];
        _leftTimeLabel.text = kPlayerConvertTime(0.0);
        self.leftTimeLabelFrame = _leftTimeLabel.frame;
    }
    return _leftTimeLabel;
}
- (UILabel*)rightTimeLabel{
    if (!_rightTimeLabel) {
        _rightTimeLabel = [UILabel new];
        _rightTimeLabel.frame = CGRectMake(self.bottomView.frame.size.width-45-40, self.bottomView.frame.size.height/2-10, 40, 20);
        _rightTimeLabel.textAlignment = NSTextAlignmentRight;
        _rightTimeLabel.textColor = [UIColor whiteColor];
        _rightTimeLabel.font = [UIFont systemFontOfSize:11];
        _rightTimeLabel.text = kPlayerConvertTime(0.0);
        self.rightTimeLabelFrame = _rightTimeLabel.frame;
    }
    return _rightTimeLabel;
}
- (UIButton*)fullScreenButton{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenButton.frame = CGRectMake(self.bottomView.frame.size.width-50, self.bottomView.frame.size.height-50, 50, 50);
        _fullScreenButton.showsTouchWhenHighlighted = NO;
        [_fullScreenButton addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
        [_fullScreenButton setImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_全屏") forState:UIControlStateNormal];
        [_fullScreenButton setImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_全屏") forState:UIControlStateSelected];
        self.fullScreenButtonFrame = _fullScreenButton.frame;
    }
    return _fullScreenButton;
}
- (UIButton*)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(5, 5, 30, 30);
        _backButton.tag = 200;
        [_backButton setImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_返回-视频") forState:(UIControlStateNormal)];
        [_backButton addTarget:self action:@selector(goBackAction:) forControlEvents:UIControlEventTouchUpInside];
        self.backButtonFrame = _backButton.frame;
    }
    return _backButton;
}
- (UIButton*)functionButton{
    if (!_functionButton) {
        _functionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _functionButton.frame = CGRectMake(self.frame.size.width - 30 - 10, 5, 30, 30);
        _functionButton.tag = 201;
        [_functionButton setImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_转发-视频") forState:(UIControlStateNormal)];
        [_functionButton addTarget:self action:@selector(functionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.functionButtonFrame = _functionButton.frame;
    }
    return _functionButton;
}
- (UILabel*)topTitleLabel{
    if (!_topTitleLabel) {
        _topTitleLabel = [UILabel new];
        _topTitleLabel.frame = CGRectMake(35, 0, self.topView.frame.size.width-90, 30);
        _topTitleLabel.center = CGPointMake(_topTitleLabel.center.x, _backButton.center.y);
        _topTitleLabel.textColor = [UIColor whiteColor];
        _topTitleLabel.numberOfLines = 1;
        _topTitleLabel.font = [UIFont boldSystemFontOfSize:(16)];
        _topTitleLabel.text = self.configuration.backString;
        _topTitleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topTitleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [_topTitleLabel addGestureRecognizer:singleTap];
        self.topTitleLabelFrame = _topTitleLabel.frame;
    }
    return _topTitleLabel;
}
- (UIButton*)collectButton{
    if (!_collectButton) {
        _collectButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _collectButton.frame = CGRectMake(0, 0, 50, 23);
        _collectButton.tag = 520;
        [_collectButton setTitle:@"收藏" forState:(UIControlStateNormal)];
        [_collectButton setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
        _collectButton.backgroundColor = PLAYER_UIColorFromHEXA(0xffffff, 0.3);
        _collectButton.titleLabel.font = [UIFont boldSystemFontOfSize:(12)];
        _collectButton.layer.cornerRadius = 2;
        _collectButton.hidden = YES;
        [_collectButton addTarget:self action:@selector(kBottomButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.bottomView addSubview:_collectButton];
        _collectButton.touchAreaInsets = UIEdgeInsetsMake(10., .0, 10., .0);
    }
    return _collectButton;
}
- (UIButton*)downloadButton{
    if (!_downloadButton) {
        _downloadButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _downloadButton.frame = CGRectMake(0, 0, 50, 23);
        _downloadButton.tag = 521;
        [_downloadButton setTitle:@"下载" forState:(UIControlStateNormal)];
        [_downloadButton setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
        _downloadButton.backgroundColor = PLAYER_UIColorFromHEXA(0xffffff, 0.3);
        _downloadButton.titleLabel.font = [UIFont boldSystemFontOfSize:(12)];
        _downloadButton.layer.cornerRadius = 2;
        _downloadButton.hidden = YES;
        [_downloadButton addTarget:self action:@selector(kBottomButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.bottomView addSubview:_downloadButton];
        _downloadButton.touchAreaInsets = UIEdgeInsetsMake(10., .0, 10., .0);
    }
    return _downloadButton;
}
- (UIButton*)definitionButton{
    if (!_definitionButton) {
        _definitionButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _definitionButton.frame = CGRectMake(0, 0, 50, 23);
        _definitionButton.tag = 522;
        [_definitionButton setTitle:@"清晰度" forState:(UIControlStateNormal)];
        [_definitionButton setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
        _definitionButton.backgroundColor = PLAYER_UIColorFromHEXA(0xffffff, 0.3);
        _definitionButton.titleLabel.font = [UIFont boldSystemFontOfSize:(12)];
        _definitionButton.layer.cornerRadius = 2;
        _definitionButton.hidden = YES;
        [_definitionButton addTarget:self action:@selector(kBottomButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.bottomView addSubview:_definitionButton];
        _definitionButton.touchAreaInsets = UIEdgeInsetsMake(10., .0, 10., .0);
    }
    return _definitionButton;
}

@end
