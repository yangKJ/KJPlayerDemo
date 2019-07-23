//
//  KJPlayerView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJPlayerView.h"
#import "KJPlayerViewHeader.h"

#define LeastDistance 15 /// 最小的距离

@interface KJPlayerView ()<KJPlayerDelegate,UIGestureRecognizerDelegate>
//用来判断手势是否移动过
@property (nonatomic,assign) BOOL hasMoved;

//记录touch开始的点
@property (nonatomic,assign) CGPoint touchBeginPoint;
//记录触摸开始时的视频播放的时间
@property (nonatomic,assign) CGFloat touchBeginValue;
//记录触摸开始亮度
@property (nonatomic,assign) CGFloat touchBeginLightValue;
//记录触摸开始的音量
@property (nonatomic,assign) CGFloat touchBeginVoiceValue;
///手势控制的类型
///判断当前手势是在控制进度、声音、亮度
@property (nonatomic,assign) KJPlayerGestureType gestureType;
/** 定时器 */
@property (nonatomic,retain) NSTimer *timer;

/** 播放器状态 */
@property(nonatomic,assign) KJPlayerState state;
@property(nonatomic,strong) KJPlayer *player; /// 播放器
@property(nonatomic,strong) UIColor *mainColor; /// 主色调
//总时间
@property(nonatomic,assign) CGFloat totalTime;
/** 视频网址 */
@property(nonatomic,strong) id url;
/** 视频开始时间 */
@property(nonatomic,assign) CGFloat startTime;

@end

@implementation KJPlayerView

- (void)config{
    //设置默认值
    self.mainColor = PLAYER_UIColorFromHEXA(0xFF1437, 1);
    self.haveFristImage = YES;
    self.enableVolumeGesture = YES;
    self.videoGravity = AVLayerVideoGravityResizeAspect;
    self.hasMoved = NO;
    self.autoHideTime = 5.0;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
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
/* 播放视频并设置开始播放时间 */
- (void)kj_setPlayWithURL:(id)url StartTime:(CGFloat)time{
    self.url = url;
    self.startTime = time;
    if (![url isKindOfClass:[NSURL class]]) {
        url = [NSURL URLWithString:url];
    }
    /// 设置一些信息
    if (self.haveFristImage) {
        /// 获取视频第一帧图片和视频总时间
        NSArray *temp = [KJPlayerTool kj_playerFristImageWithURL:url];
        self.backImageView.image = temp[0];
    }
    /// 播放视频
    AVPlayerLayer *playerLayer = [self.player kj_playWithUrl:url];
    if (time>0) {
        time = time > self.player.videoTotalTime ? self.player.videoTotalTime : time;
        [self.player kj_seekToTime:time];
    }
    playerLayer.frame = self.contentView.bounds;
    [self.contentView.layer addSublayer:playerLayer];
    // 视频的默认填充模式，AVLayerVideoGravityResizeAspect
    playerLayer.videoGravity = self.videoGravity;
    
    self.totalTime = self.player.videoTotalTime;
    self.leftTimeLabel.text  = [self convertTime:time];
    self.rightTimeLabel.text = [self convertTime:self.totalTime];
    CGFloat loadValue = self.player.videoIsLocalityData ? 1.0 : 0.0;
    [self.loadingProgress setProgress:loadValue animated:YES];
    self.playScheduleSlider.maximumValue = self.totalTime;
    self.playScheduleSlider.value = time;//指定初始值
    self.playOrPauseButton.selected = YES;
}

#pragma mark - KJPlayerDelegate
- (void)kj_player:(nonnull KJPlayer *)player LoadedProgress:(CGFloat)loadedProgress LoadComplete:(BOOL)complete SaveSuccess:(BOOL)saveSuccess {
    //    NSLog(@"Load:%.2f==%d==%d",loadedProgress,complete,saveSuccess);
    [self.loadingProgress setProgress:loadedProgress animated:YES];
}

- (void)kj_player:(nonnull KJPlayer *)player Progress:(CGFloat)progress CurrentTime:(CGFloat)currentTime DurationTime:(CGFloat)durationTime {
    //    NSLog(@"Time:%.2f==%.2f==%.2f",progress,currentTime,durationTime);
    self.leftTimeLabel.text  = [self convertTime:currentTime];
    self.playScheduleSlider.value = currentTime;//指定初始值
}

- (void)kj_player:(nonnull KJPlayer *)player State:(KJPlayerState)state ErrorCode:(KJPlayerErrorCode)errorCode {
//    NSLog(@"State:%ld==%ld",state,errorCode);
    self.state = state;
    switch (state) {
        case KJPlayerStateLoading: /// 加载中 缓存数据
            [self kStartLoading];
            break;
        case KJPlayerStatePlaying:
            [self kStartPlay];
            break;
        case KJPlayerStateStopped:
            [self kStoppp];
            break;
        case KJPlayerStatePause:
            
            break;
        case KJPlayerStateError:
            
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
    if (self.bottomView.alpha == 0.0) {
        [self showControlView];
    }else{
        [self hiddenControlView];
    }
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
/// 播放完成的相关操作
- (void)kStoppp{
    self.backImageView.hidden = NO;
    self.playOrPauseButton.selected = NO;
    self.playScheduleSlider.value = self.totalTime;//指定初始值
    if (self.bottomView.alpha == 0.0) {
        [self showControlView];
    }else{
        [self hiddenControlView];
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
    [self invalidateTimer]; // 创建定时器前先停止定时器,不然会出现僵尸定时器,导致错误
    NSTimer *timer = [NSTimer timerWithTimeInterval:self.autoHideTime target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES]; /// 创建只执行一次的计时器
    /// 放入当前的自动释放池
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.timer = timer;
}
///显示操作栏view
- (void)showControlView{
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
    }];
}
/// 自动隐藏控制面板
- (void)autoDismissBottomView:(NSTimer*)timer{
    if (self.state == KJPlayerStatePlaying) {
        if (self.bottomView.alpha == 1.0) {
            [self hiddenControlView];//隐藏操作栏
        }
    }
}
/// 设置时间显示
- (NSString *)convertTime:(CGFloat)second{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    if (second / 3600 >= 1) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    }else {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    return [dateFormatter stringFromDate:date];
}

#pragma mark - 事件处理
// 播放和暂停
- (void)playOrPauseAction:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (self.state == KJPlayerStatePause) {
        [self.player kj_playerResume];
    } else if(self.state == KJPlayerStatePlaying){
        [self.player kj_playerPause];
    } else if (self.state == KJPlayerStateStopped){
        [self kj_setPlayWithURL:self.url StartTime:self.startTime];
    }
}
// 全屏切换
- (void)fullScreenAction:(UIButton*)sender{
    sender.selected = !sender.selected;

}
// 返回按钮
- (void)goBackAction:(UIButton*)sender{
    
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
            self.leftTimeLabel.text = [self convertTime:slider.value];
        break;
        case UITouchPhaseEnded:
//            NSLog(@"结束拖动");
            [self.player kj_playerResume];
            self.playOrPauseButton.selected = YES;
            CGFloat second = slider.value;
            second = second < 0.0 ? 0.0 : second;
            second = second > self.totalTime ? self.totalTime : second;
            [self.playScheduleSlider setValue:second animated:YES];
            [self.player kj_seekToTime:second];
        break;
        default:
        break;
    }
}
//视频进度条的点击事件
- (void)tapGestureForSlider:(UITapGestureRecognizer *)gesture{
    CGPoint touchLocation = [gesture locationInView:self.playScheduleSlider];
    CGFloat value = (self.playScheduleSlider.maximumValue - self.playScheduleSlider.minimumValue) * (touchLocation.x / self.playScheduleSlider.frame.size.width);
    CGFloat second = value;
    second = second < 0.0 ? 0.0 : second;
    second = second > self.totalTime ? self.totalTime : second;
    
    [self.playScheduleSlider setValue:second animated:YES];
    [self.player kj_seekToTime:second];
}

#pragma mark - 手势事件处理
// 单击手势方法
- (void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [self setupTimer]; /// 创建计时器
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
    // 这个是用来判断, 如果有多个手指点击则不做出响应
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1) {
        return;
    }
    // 这个是用来判断, 手指点击的是不是本视图, 如果不是则不做出响应
    if (![[(UITouch *)touches.anyObject view] isEqual:self] &&  ![[(UITouch *)touches.anyObject view] isEqual:self]) {
        return;
    }
    [super touchesBegan:touches withEvent:event];
    
    //触摸开始, 初始化一些值
    _hasMoved = NO;
    _touchBeginValue = self.playScheduleSlider.value;
    //位置
    _touchBeginPoint = [touches.anyObject locationInView:self];
    //亮度
    _touchBeginLightValue = [UIScreen mainScreen].brightness;
    //声音
    _touchBeginVoiceValue = _volumeSlider.value;
    self.fastView.hidden = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1  || event.allTouches.count > 1) {
        return;
    }
    if (![[(UITouch *)touches.anyObject view] isEqual:self] && ![[(UITouch *)touches.anyObject view] isEqual:self]) {
        return;
    }
    [super touchesMoved:touches withEvent:event];
    
    //如果移动的距离过于小, 就判断为没有移动
    CGPoint tempPoint = [touches.anyObject locationInView:self];
    if (fabs(tempPoint.x - _touchBeginPoint.x) < LeastDistance && fabs(tempPoint.y - _touchBeginPoint.y) < LeastDistance) {
        return;
    }
    _hasMoved = YES;
    //如果还没有判断出使什么控制手势, 就进行判断
    //滑动角度的tan值
    float tan = fabs(tempPoint.y - _touchBeginPoint.y) / fabs(tempPoint.x - _touchBeginPoint.x);
    if (tan < 1 / sqrt(3)) {    //当滑动角度小于30度的时候, 进度手势
        _gestureType = KJPlayerGestureTypeProgress;
    }else if(tan > sqrt(3)){  //当滑动角度大于60度的时候, 声音和亮度
        //判断是在屏幕的左半边还是右半边滑动, 左侧控制为亮度, 右侧控制音量
        if (_touchBeginPoint.x < self.bounds.size.width/2) {
            _gestureType = KJPlayerGestureTypeLight;
        }else{
            _gestureType = KJPlayerGestureTypeVoice;
        }
    }else{ //如果是其他角度则不是任何控制
        _gestureType = KJPlayerGestureTypeNone;
        return;
    }
    
    if (_gestureType == KJPlayerGestureTypeProgress) { //如果是进度手势
        CGFloat value = [self moveProgressControllWithTempPoint:tempPoint];
        [self timeValueChangingWithValue:value];
    }else if(_gestureType == KJPlayerGestureTypeVoice){    //如果是音量手势
        if (self.fullScreen) {//全屏的时候才开启音量的手势调节
            if (self.enableVolumeGesture) {
                //根据触摸开始时的音量和触摸开始时的点去计算出现在滑动到的音量
                float voiceValue = _touchBeginVoiceValue - ((tempPoint.y - _touchBeginPoint.y)/self.bounds.size.height);
                //判断控制一下, 不能超出 0~1
                if (voiceValue < 0) {
                    _volumeSlider.value = 0;
                }else if(voiceValue > 1){
                    _volumeSlider.value = 1;
                }else{
                    _volumeSlider.value = voiceValue;
                }
            }
        }
    }else if(_gestureType == KJPlayerGestureTypeLight){   //如果是亮度手势
        //显示音量控制的view
        [self hideTheLightViewWithHidden:NO];
        if (self.fullScreen) {
            //根据触摸开始时的亮度, 和触摸开始时的点来计算出现在的亮度
            CGFloat tempLightValue = _touchBeginLightValue - ((tempPoint.y - _touchBeginPoint.y)/self.bounds.size.height);
            if (tempLightValue < 0) {
                tempLightValue = 0;
            }else if(tempLightValue > 1){
                tempLightValue = 1;
            }
            // 控制亮度的方法
            [UIScreen mainScreen].brightness = tempLightValue;
            // 实时改变现实亮度进度的view
            NSLog(@"亮度调节 = %f",tempLightValue);
        }
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    //判断是否移动过
    if (_hasMoved) {
        if (_gestureType == KJPlayerGestureTypeProgress) { //进度控制就跳到响应的进度
            CGPoint tempPoint = [touches.anyObject locationInView:self];
            CGFloat second = [self moveProgressControllWithTempPoint:tempPoint];
            second = second < 0.0 ? 0.0 : second;
            second = second > self.totalTime ? self.totalTime : second;
            [self.player kj_seekToTime:second];
            self.fastView.hidden = YES;
        }else if (_gestureType == KJPlayerGestureTypeLight){//如果是亮度控制, 控制完亮度还要隐藏显示亮度的view
            [self hideTheLightViewWithHidden:YES];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    self.fastView.hidden = YES;
    [self hideTheLightViewWithHidden:YES];
    [super touchesEnded:touches withEvent:event];
    //判断是否移动过
    if (self.hasMoved) {
        if (_gestureType == KJPlayerGestureTypeProgress) { //进度控制就跳到响应的进度
            CGPoint tempPoint = [touches.anyObject locationInView:self];
            CGFloat second = [self moveProgressControllWithTempPoint:tempPoint];
            second = second < 0.0 ? 0.0 : second;
            second = second > self.totalTime ? self.totalTime : second;
            self.fastView.hidden = YES;
        }else if (_gestureType == KJPlayerGestureTypeLight){//如果是亮度控制, 控制完亮度还要隐藏显示亮度的view
            [self hideTheLightViewWithHidden:YES];
        }
    }
}
// 用来控制移动过程中计算手指划过的时间
- (CGFloat)moveProgressControllWithTempPoint:(CGPoint)tempPoint{
    //90代表整个屏幕代表的时间
    CGFloat tempValue = _touchBeginValue + self.totalTime * ((tempPoint.x - _touchBeginPoint.x) / ([UIScreen mainScreen].bounds.size.width));
    if (tempValue > self.totalTime) {
        tempValue = self.totalTime;
    }else if (tempValue < 0){
        tempValue = 0.0f;
    }
    return tempValue;
}
// 用来显示时间的view在时间发生变化时所作的操作
- (void)timeValueChangingWithValue:(CGFloat)value{
    if (value > _touchBeginValue) {
        self.fastView.stateImageView.image = PLAYER_GET_BUNDLE_IMAGE(@"kj_player_progress_right");
    } else if(value < _touchBeginValue){
        self.fastView.stateImageView.image = PLAYER_GET_BUNDLE_IMAGE(@"kj_player_progress_left");
    }
    self.fastView.hidden = NO;
    self.fastView.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [self convertTime:value], [self convertTime:_totalTime]];
    self.leftTimeLabel.text = [self convertTime:value];
    [self showControlView];
    [self.playScheduleSlider setValue:value animated:YES];
}
// 用来控制显示亮度的view, 以及毛玻璃效果的view
- (void)hideTheLightViewWithHidden:(BOOL)hidden{
    if (self.fullScreen) {//全屏才出亮度调节的view
        if (hidden) {
            [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.effectView.alpha = 0.0;
            } completion:nil];
        }else{
            self.effectView.alpha = 1.0;
        }
        self.effectView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.height)/2-155/2, ([UIScreen mainScreen].bounds.size.width)/2-155/2, 155, 155);
    }
}

#pragma mark - kSetUI
- (void)kSetUI{
    //    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    //    for (UIControl *view in volumeView.subviews) {
    //        if ([view.superclass isSubclassOfClass:[UISlider class]]) {
    //            self.volumeSlider = (UISlider*)view;
    //        }
    //    }
    [self addSubview:self.contentView];
    [self addSubview:self.backImageView];
    [self addSubview:self.fastView];
    [self addSubview:self.loadingView];
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    
    [self.bottomView addSubview:self.loadingProgress];
    [self.bottomView addSubview:self.playScheduleSlider];
    [self.bottomView addSubview:self.leftTimeLabel];
    [self.bottomView addSubview:self.rightTimeLabel];
    [self.bottomView addSubview:self.fullScreenButton];
    [self.bottomView addSubview:self.playOrPauseButton];
    
    [self.topView addSubview:self.backButton];
    [self.topView addSubview:self.topTitleLabel];
    
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
        _backImageView.contentMode = UIViewContentModeScaleAspectFit;
        _backImageView.image = PLAYER_GET_BUNDLE_IMAGE(@"kj_player_background");
    }
    return _backImageView;
}
- (KJFastView*)fastView{
    if (!_fastView) {
        _fastView = [[KJFastView alloc]initWithFrame:CGRectMake(0, 0, 120, 60)];
        _fastView.center = self.center;
        _fastView.layer.cornerRadius = 10;
        _fastView.hidden = YES;
    }
    return _fastView;
}
- (UIActivityIndicatorView*)loadingView{
    if (!_loadingView) {
        //小菊花
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadingView.center = self.center;
        [_loadingView startAnimating];
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
        [_playOrPauseButton addTarget:self action:@selector(playOrPauseAction:) forControlEvents:UIControlEventTouchUpInside];
        [_playOrPauseButton setImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_播放-全屏") forState:UIControlStateNormal];
        [_playOrPauseButton setImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_暂停-全屏") forState:UIControlStateSelected];
        _playOrPauseButton.frame = CGRectMake(0, 0, 50, 50);
        _playOrPauseButton.selected = YES;//默认状态，即默认是不自动播放
    }
    return _playOrPauseButton;
}
- (UISlider*)playScheduleSlider{
    if (!_playScheduleSlider) {
        _playScheduleSlider = [[UISlider alloc]initWithFrame:CGRectMake(_loadingProgress.frame.origin.x-3, 0, CGRectGetWidth(self.loadingProgress.frame)-3, 20)];
        _playScheduleSlider.center = CGPointMake(_playScheduleSlider.center.x, _loadingProgress.center.y);
        _playScheduleSlider.backgroundColor = [UIColor clearColor];
        _playScheduleSlider.minimumValue = 0.0;
        [_playScheduleSlider setThumbImage:PLAYER_GET_BUNDLE_IMAGE(@"kj_player_dot")  forState:UIControlStateNormal];
        _playScheduleSlider.minimumTrackTintColor = self.mainColor;
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
        _loadingProgress.progressTintColor = UIColor.whiteColor;
        _loadingProgress.backgroundColor = UIColor.whiteColor;
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
        _leftTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, self.bottomView.frame.size.height-20, self.bottomView.frame.size.width-90, 20)];
        _leftTimeLabel.textAlignment = NSTextAlignmentLeft;
        _leftTimeLabel.textColor = [UIColor whiteColor];
        _leftTimeLabel.font = [UIFont systemFontOfSize:11];
        _leftTimeLabel.text = [self convertTime:0.0];//设置默认值
    }
    return _leftTimeLabel;
}
- (UILabel*)rightTimeLabel{
    if (!_rightTimeLabel) {
        _rightTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, self.bottomView.frame.size.height-20, self.bottomView.frame.size.width-90, 20)];
        _rightTimeLabel.textAlignment = NSTextAlignmentRight;
        _rightTimeLabel.textColor = [UIColor whiteColor];
        _rightTimeLabel.font = [UIFont systemFontOfSize:11];
        _rightTimeLabel.text = [self convertTime:0.0];//设置默认值
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
        _topTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, 0, self.topView.frame.size.width-90, 30)];
        _topTitleLabel.center = CGPointMake(_topTitleLabel.center.x, _backButton.center.y);
        _topTitleLabel.textColor = [UIColor whiteColor];
        _topTitleLabel.numberOfLines = 1;
        _topTitleLabel.font = [UIFont boldSystemFontOfSize:(16)];
    }
    return _topTitleLabel;
}

@end
