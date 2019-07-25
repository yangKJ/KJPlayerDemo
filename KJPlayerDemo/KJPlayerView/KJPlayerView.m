//
//  KJPlayerView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJPlayerView.h"
#import <MediaPlayer/MPVolumeView.h> /// 控制系统音量
#import <QuartzCore/QuartzCore.h>

@interface KJPlayerView ()<KJPlayerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSTimer *timer;//定时器
@property (nonatomic,assign) CGFloat startTime;//视频开始时间
@property (nonatomic,strong) KJPlayer *player; ///播放器
@property (nonatomic,strong) KJPlayerViewConfiguration *configuration;

/*************** 记录视图初始位置 ***************/
/** 父视图 */
@property (nonatomic,assign) CGRect superViewFrame;
/** 底部操作工具栏 */
@property (nonatomic,assign) CGRect bottomViewFrame;
/** 顶部操作工具栏 */
@property (nonatomic,assign) CGRect topViewFrame;
/** 开始播放前背景占位图片 */
@property (nonatomic,assign) CGRect backImageViewFrame;
/** 显示播放视频的title */
@property (nonatomic,assign) CGRect topTitleLabelFrame;
/** 控制全屏的按钮 */
@property (nonatomic,assign) CGRect fullScreenButtonFrame;
/** 播放暂停按钮 */
@property (nonatomic,assign) CGRect playOrPauseButtonFrame;
/** 左上角关闭按钮 */
@property (nonatomic,assign) CGRect backButtonFrame;
/** 菊花（加载框）*/
@property (nonatomic,assign) CGRect loadingViewFrame;
/** 快进快退 */
@property (nonatomic,assign) CGRect fastViewFrame;
/** 显示播放时间的UILabel */
@property (nonatomic,assign) CGRect leftTimeLabelFrame;
@property (nonatomic,assign) CGRect rightTimeLabelFrame;
/** 播放进度滑块 */
@property (nonatomic,assign) CGRect playScheduleSliderFrame;
/** 显示缓冲进度 */
@property (nonatomic,assign) CGRect loadingProgressFrame;

@end

@implementation KJPlayerView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self invalidateTimer]; /// 清除计时器
}

- (void)config{
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

/* 初始化 */
- (instancetype)initWithFrame:(CGRect)frame Configuration:(KJPlayerViewConfiguration*)configuration{
    if (self==[super initWithFrame:frame]) {
        self.configuration = configuration;
        [self config];
        [self kSetUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        self.configuration = [[KJPlayerViewConfiguration alloc] init];
        [self config];
        [self kSetUI];
    }
    return self;
}

- (KJPlayer*)player{
    if (!_player) {
        _player = [KJPlayer sharedInstance];
        _player.delegate = self;
    }
    return _player;
}

#pragma mark - public methods
- (void)kj_setReplayWithURL:(id)url StartTime:(CGFloat)time{
    self.configuration.url = url;
    self.startTime = time;
    if (![url isKindOfClass:[NSURL class]]) {
        url = [NSURL URLWithString:url];
    }
    /// 播放视频
    [self.player kj_playerReplayWithURL:url];
    /// 播放的准备工作
    [self kPlayBeforePlanWithURL:url Time:time];
}
/* 播放视频并设置开始播放时间 */
- (void)kj_setPlayWithURL:(id)url StartTime:(CGFloat)time{
    self.configuration.url = url;
    self.startTime = time;
    if (![url isKindOfClass:[NSURL class]]) {
        url = [NSURL URLWithString:url];
    }
    
    /// 播放视频
    self.playerLayer = [self.player kj_playerPlayWithURL:url];
    self.playerLayer.frame = self.bounds;
    [self.contentView.layer addSublayer:self.playerLayer];
    
    /// 播放的准备工作
    [self kPlayBeforePlanWithURL:url Time:time];
}
/// 播放的准备工作
- (void)kPlayBeforePlanWithURL:(NSURL*)url Time:(CGFloat)time{
    /// 设置一些信息
    if (self.configuration.haveFristImage) {
        /// 获取视频第一帧图片
        self.configuration.videoImage = [KJPlayerTool kj_playerFristImageWithURL:url];
        self.backImageView.image = self.configuration.videoImage ? self.configuration.videoImage : PLAYER_GET_BUNDLE_IMAGE(@"kj_player_background");
    }
    if (time>0) {
        time = time > self.player.videoTotalTime ? self.player.videoTotalTime : time;
        [self.player kj_playerSeekToTime:time];
    }
    // 视频的默认填充模式，AVLayerVideoGravityResizeAspect
    self.playerLayer.videoGravity = self.configuration.videoGravity;
    
    CGFloat totalTime = self.configuration.totalTime = self.player.videoTotalTime;
    self.leftTimeLabel.text  = [KJPlayerTool kj_playerConvertTime:time];
    self.rightTimeLabel.text = [KJPlayerTool kj_playerConvertTime:totalTime];
    CGFloat loadValue = self.player.videoIsLocalityData ? 1.0 : 0.0;
    [self.loadingProgress setProgress:loadValue animated:YES];
    self.playScheduleSlider.maximumValue = totalTime;
    self.playScheduleSlider.value = time;//指定初始值
    self.playOrPauseButton.selected = YES;
    
    self.fastView.moveGestureFast = NO;
    self.configuration.hasMoved = NO;
}

#pragma mark - KJPlayerDelegate
- (void)kj_player:(nonnull KJPlayer *)player LoadedProgress:(CGFloat)loadedProgress LoadComplete:(BOOL)complete SaveSuccess:(BOOL)saveSuccess {
        NSLog(@"PlayerLoad:%.2f",loadedProgress);
    [self.loadingProgress setProgress:loadedProgress animated:YES];
}

- (void)kj_player:(nonnull KJPlayer *)player Progress:(CGFloat)progress CurrentTime:(CGFloat)currentTime DurationTime:(CGFloat)durationTime {
//    NSLog(@"Time:%.2f==%.2f==%.2f",progress,currentTime,durationTime);
    if (self.fastView.moveGestureFast == NO) {
        self.leftTimeLabel.text = [KJPlayerTool kj_playerConvertTime:currentTime];
        self.playScheduleSlider.value = currentTime;//指定初始值
    }
}

- (void)kj_player:(nonnull KJPlayer *)player State:(KJPlayerState)state ErrorCode:(KJPlayerErrorCode)errorCode {
    self.configuration.state = state;
    switch (state) {
        case KJPlayerStateLoading: /// 加载中 缓存数据
            NSLog(@"KJPlayerStateLoading");
            [self kStartLoading];
            break;
        case KJPlayerStatePlaying:
            NSLog(@"KJPlayerStatePlaying");
            [self kStartPlay];
            break;
        case KJPlayerStatePlayEnd:
            NSLog(@"KJPlayerStatePlayEnd");
            [self kPlayEnd];
            break;
        case KJPlayerStateStopped:
            NSLog(@"KJPlayerStateStopped");
            [self kStoppp];
            break;
        case KJPlayerStatePause:
            NSLog(@"KJPlayerStatePause");
            break;
        case KJPlayerStateError:
            NSLog(@"KJPlayerStateError:%ld",errorCode);
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
    /// 隐藏加载
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    self.backImageView.hidden = YES;
    self.playOrPauseButton.selected = YES;
    [self setupTimer]; /// 创建计时器
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
            /// 没数据或者只有一条数据
            if (self.videoUrlTemps.count == 0 || self.videoUrlTemps.count == 1) {
                [self kReplayXXXXX];
            }else if(self.videoUrlTemps.count > 1){
                self.videoIndex += 1;
                self.videoIndex = self.videoIndex >= self.videoUrlTemps.count ? 0 : self.videoIndex;
                [self kj_setReplayWithURL:self.videoUrlTemps[self.videoIndex] StartTime:self.startTime];
            }
        }
            break;
        case KJPlayerPlayTypeRandom:{
            /// 没数据或者只有一条数据
            if (self.videoUrlTemps.count == 0 || self.videoUrlTemps.count == 1) {
                [self kReplayXXXXX];
            }else if(self.videoUrlTemps.count > 1){
                /// 生成随机数
                NSInteger idx = arc4random() % (self.videoUrlTemps.count);
                [self kj_setReplayWithURL:self.videoUrlTemps[idx] StartTime:self.startTime];
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
    self.backImageView.hidden = NO;
    self.playScheduleSlider.value = 0;//指定初始值
    [self kj_setReplayWithURL:self.configuration.url StartTime:self.startTime];
}
/// 播放Stop的相关操作
- (void)kStoppp{
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    self.backImageView.hidden = NO;
    self.playOrPauseButton.selected = NO;
    self.playScheduleSlider.value = 0;//指定初始值
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
    /// 为0时表示关闭自动隐藏功能
    if (self.configuration.autoHideTime <= 0) return;
    [self invalidateTimer]; // 创建定时器前先停止定时器,不然会出现僵尸定时器,导致错误
    NSTimer *timer = [NSTimer timerWithTimeInterval:self.configuration.autoHideTime target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES]; /// 创建只执行一次的计时器
    /// 放入当前的自动释放池
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.timer = timer;
}
///显示操作栏view
- (void)showControlView{
    [self setupTimer]; /// 创建计时器
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
            [self hiddenControlView];//隐藏操作栏
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
            
            self.fastView.center = CGPointMake(PLAYER_SCREEN_HEIGHT*.5, PLAYER_SCREEN_WIDTH*.5);
            self.loadingView.center = CGPointMake(PLAYER_SCREEN_HEIGHT*.5, PLAYER_SCREEN_WIDTH*.5);
            
            self.topView.frame = CGRectMake(0, 0, PLAYER_SCREEN_HEIGHT, 50);
            self.topView.backgroundColor = PLAYER_UIColorFromHEXA(0x000000, 0.8);
            self.backButton.center = CGPointMake(self.backButton.center.x + 10, self.topView.center.y);
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
            
            self.fastView.center = CGPointMake(PLAYER_SCREEN_HEIGHT*.5, PLAYER_SCREEN_WIDTH*.5);
            self.loadingView.center = CGPointMake(PLAYER_SCREEN_HEIGHT*.5, PLAYER_SCREEN_WIDTH*.5);
            
            self.topView.frame = CGRectMake(0, 0, PLAYER_SCREEN_HEIGHT, 50);
            self.topView.backgroundColor = PLAYER_UIColorFromHEXA(0x000000, 0.8);
            self.backButton.center = CGPointMake(self.backButton.center.x + 10, self.topView.center.y);
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
            self.topView.backgroundColor = UIColor.clearColor;
            self.topView.frame = self.topViewFrame;
            self.bottomView.backgroundColor = UIColor.clearColor;
            self.bottomView.frame = self.bottomViewFrame;
            self.topTitleLabel.frame = self.topTitleLabelFrame;
            self.backButton.frame = self.backButtonFrame;
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
    /// 判断是否开启重力感应
    if (self.configuration.openGravitySensing == NO) {
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    KJPlayerDeviceDirection direction = KJPlayerDeviceDirectionCustom;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:{
            NSLog(@"top");
            direction = KJPlayerDeviceDirectionTop;
        }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"bottom");
            direction = KJPlayerDeviceDirectionBottom;
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"left");
            direction = KJPlayerDeviceDirectionLeft;
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"right");
            direction = KJPlayerDeviceDirectionRight;
        }
            break;
        default:
            break;
    }
    if (direction == KJPlayerDeviceDirectionCustom) return;
    BOOL boo = NO;
    if ((direction == KJPlayerDeviceDirectionRight) || (direction == KJPlayerDeviceDirectionLeft)) {
        boo = YES;
    }
    self.configuration.fullScreen = boo;
    /// 当前手机方向  同时也控制全屏和半屏切换  全屏：left和right  半屏：top和bottom
    if ([self.delegate respondsToSelector:@selector(kj_PlayerView:DeviceDirection:)]) {
        BOOL close = [self.delegate kj_PlayerView:self DeviceDirection:direction];
        if (close) return;
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
        BOOL close = [self.delegate kj_PlayerView:self DeviceDirection:KJPlayerDeviceDirectionRight];
        if (close) return;
    }
    if (sender.selected) {
        [self kFullWithDirection:KJPlayerDeviceDirectionRight];
    }else{
        [self kFullWithDirection:(KJPlayerDeviceDirectionTop)];
    }
}
// 播放和暂停
- (void)playOrPauseAction:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (self.configuration.state == KJPlayerStatePause) {
        [self.player kj_playerResume];
    } else if(self.configuration.state == KJPlayerStatePlaying){
        [self.player kj_playerPause];
    } else if (self.configuration.state == KJPlayerStateStopped){
        [self kj_setReplayWithURL:self.configuration.url StartTime:self.startTime];
    }
}
// 返回按钮
- (void)goBackAction:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(kj_PlayerView:PlayerState:)]) {
        [self.delegate kj_PlayerView:self PlayerState:self.configuration.state];
    }
}
//底部按钮事件处理
- (void)kBottomButtonAction:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(kj_PlayerView:BottomButton:)]) {
        [self.delegate kj_PlayerView:self BottomButton:sender];
    }
}
///进度条的拖拽事件 监听UISlider拖动状态
- (void)sliderValueChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch *touchEvent = [[event allTouches]anyObject];
    switch(touchEvent.phase) {
        case UITouchPhaseBegan:
//            NSLog(@"开始拖动");
            [self.player kj_playerPause];
            self.playOrPauseButton.selected = NO;
            break;
        case UITouchPhaseMoved:
//            NSLog(@"正在拖动");
            self.leftTimeLabel.text = [KJPlayerTool kj_playerConvertTime:slider.value];
            break;
        case UITouchPhaseEnded:
//            NSLog(@"结束拖动");
            [self.player kj_playerResume];
            self.playOrPauseButton.selected = YES;
            CGFloat second = slider.value;
            [self.playScheduleSlider setValue:second animated:YES];
            [self.player kj_playerSeekToTime:second];
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
    [self.player kj_playerSeekToTime:value];
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
// 双击手势方法
- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap{
    [self playOrPauseAction:self.playOrPauseButton];
    [self showControlView];
}

#pragma mark - touches
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    NSLog(@"touchesBegan");
    // 这个是用来判断, 如果有多个手指点击则不做出响应
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1) {
        return;
    }
    // 这个是用来判断, 手指点击的是不是本视图, 如果不是则不做出响应
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
            self.configuration.gestureType = KJPlayerGestureTypeLight;
            self.lightView.changeLightValue = YES;
        }else{
            self.configuration.gestureType = KJPlayerGestureTypeVoice;
        }
        if (!self.configuration.enableVolumeGesture) {
            return;
        }
    }else{ //如果是其他角度则不是任何控制
        self.configuration.gestureType = KJPlayerGestureTypeNone;
        return;
    }
    
    //3.手势事件处理
    if (self.configuration.gestureType == KJPlayerGestureTypeProgress) { //如果是进度手势
        CGFloat value = [self kmoveFastViewWithTempPoint:tempPoint];
        /// 设置快进数据
        self.fastView.moveGestureFast = YES;
        [self.fastView kj_updateFastValue:value TotalTime:self.configuration.totalTime];
        self.leftTimeLabel.text = [KJPlayerTool kj_playerConvertTime:value];
        [self.playScheduleSlider setValue:value animated:YES];
    }else if(self.configuration.gestureType == KJPlayerGestureTypeVoice){ //如果是音量手势
        if (self.configuration.fullScreen) {//全屏的时候才开启音量的手势调节
            //根据触摸开始时的音量和触摸开始时的点去计算出现在滑动到的音量
            CGFloat value = self.configuration.touchBeginVoiceValue - ((tempPoint.y - self.configuration.touchBeginPoint.y)/self.bounds.size.height);
            //判断控制一下, 不能超出 0~1
            value = MAX(0, value);
            value = MIN(value, 1);
            self.volumeSlider.value = value;
        }
    }else if(self.configuration.gestureType == KJPlayerGestureTypeLight){ //如果是亮度手势
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
    NSLog(@"touchesEnded");
    [super touchesEnded:touches withEvent:event];
    self.fastView.moveGestureFast = NO;
    self.lightView.changeLightValue = NO;
    //判断是否移动过
    if (self.configuration.hasMoved &&
        self.configuration.playProgressGesture && // 是否使用手势控制播放进度
        self.configuration.gestureType == KJPlayerGestureTypeProgress) { //进度控制就跳到响应的进度
        CGPoint tempPoint = [touches.anyObject locationInView:self];
        CGFloat second = [self kmoveFastViewWithTempPoint:tempPoint];
        [self.player kj_playerSeekToTime:second];
    }
}
// 用来控制移动过程中计算手指划过的时间
- (CGFloat)kmoveFastViewWithTempPoint:(CGPoint)tempPoint{
    //整个屏幕代表的时间
    CGFloat tempValue = self.fastView.touchBeginValue + self.configuration.totalTime * ((tempPoint.x - self.configuration.touchBeginPoint.x) / (self.frame.size.width));
    tempValue = MAX(0.0, tempValue);
    tempValue = MIN(tempValue, self.configuration.totalTime);
    return tempValue;
}

#pragma mark - kSetUI
- (void)kSetUI{
    [self addSubview:self.contentView]; /// 显示播放器layer视图层
    [self addSubview:self.backImageView];
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
    [self.topView addSubview:self.topTitleLabel];
    
    /*************** 记录视图初始位置 ***************/
    /** 父视图 */
    self.superViewFrame = self.frame;
    /** 底部操作工具栏 */
    self.bottomViewFrame = self.bottomView.frame;
    /** 顶部操作工具栏 */
    self.topViewFrame = self.topView.frame;
    /** 开始播放前背景占位图片 */
    self.backImageViewFrame = self.backImageView.frame;
    /** 显示播放视频的title */
    self.topTitleLabelFrame = self.topTitleLabel.frame;
    /** 控制全屏的按钮 */
    self.fullScreenButtonFrame = self.fullScreenButton.frame;
    /** 播放暂停按钮 */
    self.playOrPauseButtonFrame = self.playOrPauseButton.frame;
    /** 左上角关闭按钮 */
    self.backButtonFrame = self.backButton.frame;
    /** 进度滑块 */
    self.fastViewFrame = self.fastView.frame;
    /** 显示播放时间的UILabel */
    self.leftTimeLabelFrame = self.leftTimeLabel.frame;
    self.rightTimeLabelFrame = self.rightTimeLabel.frame;
    /** 播放进度滑块 */
    self.playScheduleSliderFrame = self.playScheduleSlider.frame;
    /** 显示缓冲进度 */
    self.loadingProgressFrame = self.loadingProgress.frame;
    /** 菊花（加载框）*/
    self.loadingViewFrame = self.loadingView.frame;

    // 单击的 Recognizer
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1; // 单击
    singleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    // 双击的 Recognizer
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTouchesRequired = 1; //手指数
    doubleTap.numberOfTapsRequired = 2; // 双击
    [self addGestureRecognizer:doubleTap];
    
    // 解决点击当前view时候响应其他控件事件
    [singleTap setDelaysTouchesBegan:YES];
    [doubleTap setDelaysTouchesBegan:YES];
    [singleTap requireGestureRecognizerToFail:doubleTap];//如果双击成立，则取消单击手势（双击的时候不回走单击事件）
}

#pragma mark - lazy
- (UIView*)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:self.bounds];
    }
    return _contentView;
}
- (UIImageView*)backImageView{
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backImageView;
}
- (KJFastView*)fastView{
    if (!_fastView) {
        _fastView = [[KJFastView alloc]initWithFrame:CGRectMake(0, 0, 160, 75)];
        _fastView.center = self.contentView.center;
        _fastView.moveGestureFast = NO;
        _fastView.progressView.progressTintColor = self.configuration.mainColor;
    }
    return _fastView;
}
- (UISlider*)volumeSlider{
    if (!_volumeSlider) {
        /// 声音滑块
        MPVolumeView *volumeView = [[MPVolumeView alloc]init];
        volumeView.transform = CGAffineTransformMakeRotation(M_PI/2);//旋转一下即可 -_-!!
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
        /// 获取当前屏幕的亮度
        CGFloat value = [UIScreen mainScreen].brightness;
        [_lightView kj_updateLightValue:value];
    }
    return _lightView;
}
- (UIActivityIndicatorView*)loadingView{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadingView.center = self.contentView.center;
//        [_loadingView startAnimating];
    }
    return _loadingView;
}
- (UIImageView*)topView{
    if (!_topView) {
        _topView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 70)];
        _topView.image = PLAYER_GET_BUNDLE_IMAGE(@"kj_player_top_shadow");
        _topView.userInteractionEnabled = YES;
    }
    return _topView;
}
- (UIImageView*)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-50, self.frame.size.width, 50)];
        _bottomView.image = PLAYER_GET_BUNDLE_IMAGE(@"kj_player_bottom_shadow");
        _bottomView.userInteractionEnabled = YES;
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
        _playOrPauseButton.selected = YES;//默认状态，即默认是不自动播放
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
        _playScheduleSlider.value = 0.0;//指定初始值
        //进度条的拖拽事件
        [_playScheduleSlider addTarget:self action:@selector(sliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
        //给进度条添加单击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureForSlider:)];
        tap.delegate = self;
        [_playScheduleSlider addGestureRecognizer:tap];
    }
    return _playScheduleSlider;
}
- (UIProgressView*)loadingProgress{
    if (!_loadingProgress) {
        _loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _loadingProgress.frame = CGRectMake(45, self.bottomView.frame.size.height/2-1, self.bottomView.frame.size.width-90, 2);
        _loadingProgress.trackTintColor = UIColor.lightGrayColor;
        _loadingProgress.progressTintColor = [self.configuration.mainColor colorWithAlphaComponent:0.2];
        [_loadingProgress setProgress:0.0 animated:NO];
    }
    return _loadingProgress;
}
- (UIButton*)fullScreenButton{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenButton.frame = CGRectMake(self.bottomView.frame.size.width-50, self.bottomView.frame.size.height-50, 50, 50);
        _fullScreenButton.showsTouchWhenHighlighted = NO;
        [_fullScreenButton addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
        [_fullScreenButton setImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_全屏") forState:UIControlStateNormal];
        [_fullScreenButton setImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_全屏") forState:UIControlStateSelected];
    }
    return _fullScreenButton;
}
- (UILabel*)leftTimeLabel{
    if (!_leftTimeLabel) {
        _leftTimeLabel = [UILabel new];
        _leftTimeLabel.frame = CGRectMake(45, self.bottomView.frame.size.height-20, 50, 20);
        _leftTimeLabel.textAlignment = NSTextAlignmentLeft;
        _leftTimeLabel.textColor = [UIColor whiteColor];
        _leftTimeLabel.font = [UIFont systemFontOfSize:11];
        _leftTimeLabel.text = [KJPlayerTool kj_playerConvertTime:0.0];//设置默认值
    }
    return _leftTimeLabel;
}
- (UILabel*)rightTimeLabel{
    if (!_rightTimeLabel) {
        _rightTimeLabel = [UILabel new];
        _rightTimeLabel.frame = CGRectMake(self.bottomView.frame.size.width-45-50, self.bottomView.frame.size.height-20, 50, 20);
        _rightTimeLabel.textAlignment = NSTextAlignmentRight;
        _rightTimeLabel.textColor = [UIColor whiteColor];
        _rightTimeLabel.font = [UIFont systemFontOfSize:11];
        _rightTimeLabel.text = [KJPlayerTool kj_playerConvertTime:0.0];//设置默认值
    }
    return _rightTimeLabel;
}
- (UIButton*)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(5, 5, 30, 30);
        [_backButton setImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_返回") forState:(UIControlStateNormal)];
        [_backButton addTarget:self action:@selector(goBackAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
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
    }
    return _definitionButton;
}

@end
