//
//  KJBasePlayerView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayerView.h"
#import <MediaPlayer/MPVolumeView.h>
#import "KJRotateManager.h"
#define kLockWidth (40)
#define kCenterPlayWidth (60)
NSString *kPlayerBaseViewChangeNotification = @"kPlayerBaseViewNotification";
NSString *kPlayerBaseViewChangeKey = @"kPlayerBaseViewKey";
@interface KJBasePlayerView ()<UIGestureRecognizerDelegate>
@property (nonatomic,assign) KJPlayerVideoScreenState screenState;
@property (nonatomic,assign) NSInteger width,height;
@property (nonatomic,assign) BOOL haveVolume;
@property (nonatomic,assign) BOOL haveBrightness;
@property (nonatomic,assign) float lastValue;
@property (nonatomic,strong) UIPanGestureRecognizer *pan;
@property (nonatomic,strong) KJPlayerHintInfo *hintInfo;
@property (nonatomic,assign) BOOL displayOperation;
@end
@implementation KJBasePlayerView{
    BOOL movingH;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"frame"];
    [self removeObserver:self forKeyPath:@"bounds"];
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self kj_initializeConfiguration];
    }
    return self;
}
- (void)kj_initializeConfiguration{
    self.userInteractionEnabled = YES;
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kj_orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    self.longPressTime = 1.f;
    self.autoHideTime = 2.f;
    self.mainColor = UIColor.whiteColor;
    self.viceColor = UIColor.redColor;
    self.width = self.frame.size.width;
    self.height = self.frame.size.height;
    self.hintInfo = [KJPlayerHintInfo new];
    self.operationViewHeight = 60;
    self.isHiddenBackButton = YES;
    self.autoRotate = YES;
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self addSubview:self.lockButton];
    [self addSubview:self.centerPlayButton];
    self.smallScreenHiddenBackButton = YES;
    self.displayOperation = YES;
    [self kj_hiddenOperationView];
}
#pragma mark - NSNotification
//屏幕旋转
- (void)kj_orientationChange:(NSNotification*)notification{
    if (self.autoRotate) {
        [KJRotateManager kj_rotateAutoFullScreenBasePlayerView:self];
    }
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context{
    if ([keyPath isEqualToString:@"frame"] || [keyPath isEqualToString:@"bounds"]) {
        if ([object valueForKeyPath:keyPath] != [NSNull null]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerBaseViewChangeNotification object:self userInfo:@{kPlayerBaseViewChangeKey:[object valueForKeyPath:keyPath]}];
            CGRect rect = [[object valueForKeyPath:keyPath] CGRectValue];
            self.width = rect.size.width;self.height = rect.size.height;
            [self kj_changeFrame];
        }
    }
}
- (void)kj_changeFrame{
    self.loadingLayer.position = CGPointMake(self.width/2, self.height/2);
    self.fastLayer.position = CGPointMake(self.width/2, self.height/2);
    self.vbLayer.position = CGPointMake(self.width/2, self.height/2);
    [self.hintTextLayer setValue:@(self.screenState) forKey:@"screenState"];
    self.topView.frame = CGRectMake(0, 0, self.width, self.operationViewHeight);
    self.bottomView.frame = CGRectMake(0, self.height-self.operationViewHeight, self.width, self.operationViewHeight);
    self.lockButton.frame = CGRectMake(10, (self.height-kLockWidth)/2, kLockWidth, kLockWidth);
    self.centerPlayButton.frame = CGRectMake((self.width-kCenterPlayWidth)/2, (self.height-kCenterPlayWidth)/2, kCenterPlayWidth, kCenterPlayWidth);
}

#pragma mark - getter
- (void (^)(void(^)(KJPlayerHintInfo*)))kVideoHintTextInfo{
    return ^(void(^xxblock)(KJPlayerHintInfo*)){
        if (xxblock) xxblock(self.hintInfo);
    };
}

#pragma mark - setter
- (void)setGestureType:(KJPlayerGestureType)gestureType{
    if (gestureType != _gestureType) {
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
             [self removeGestureRecognizer:gesture];
        }
    }
    _gestureType = gestureType;
    if (_pan) _pan = nil;
    self.haveVolume = self.haveBrightness = NO;
    BOOL haveTap = NO;
    UITapGestureRecognizer *tapGesture;
    if (gestureType == 1 || (gestureType & KJPlayerGestureTypeSingleTap)) {
        haveTap = YES;
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [tapGesture setDelaysTouchesBegan:YES];
        [self addGestureRecognizer:tapGesture];
    }
    if (gestureType == 2 || (gestureType & KJPlayerGestureTypeDoubleTap)) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleAction:)];
        [gesture setNumberOfTapsRequired:2];
        [gesture setDelaysTouchesBegan:YES];
        [self addGestureRecognizer:gesture];
        if (haveTap) [tapGesture requireGestureRecognizerToFail:gesture];
    }
    if (gestureType == 3 || (gestureType & KJPlayerGestureTypeLong)) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longAction:)];
        longPress.minimumPressDuration = self.longPressTime;
        [self addGestureRecognizer:longPress];
    }
    if (gestureType == 4 || (gestureType & KJPlayerGestureTypeProgress)) {
        if (self.pan) { }
    }
    if (gestureType == 5 || (gestureType & KJPlayerGestureTypeVolume)) {
        self.haveVolume = YES;
        if (self.pan) { }
    }
    if (gestureType == 6 || (gestureType & KJPlayerGestureTypeBrightness)) {
        self.haveBrightness = YES;
        if (self.pan) { }
    }
}
- (void)setIsFullScreen:(BOOL)isFullScreen{
    if (isFullScreen == _isFullScreen) return;
    _isFullScreen = isFullScreen;
    self.lockButton.hidden = !isFullScreen;
    if (isFullScreen) {
        [KJRotateManager kj_rotateFullScreenBasePlayerView:self];
        self.screenState = KJPlayerVideoScreenStateFullScreen;
        self.backButton.hidden = self.fullScreenHiddenBackButton;
        [self kj_displayOperationView];
    }else{
        [KJRotateManager kj_rotateSmallScreenBasePlayerView:self];
        self.screenState = KJPlayerVideoScreenStateSmallScreen;
        self.backButton.hidden = self.smallScreenHiddenBackButton;
    }
    if (self.kVideoChangeScreenState) {
        self.kVideoChangeScreenState(self.screenState);
    }
}
- (void)setFullScreenHiddenBackButton:(BOOL)fullScreenHiddenBackButton{
    _fullScreenHiddenBackButton = fullScreenHiddenBackButton;
    if (fullScreenHiddenBackButton) {
        if (_backButton.superview == nil) {
            [self addSubview:self.backButton];
        }
    }
    _backButton.hidden = fullScreenHiddenBackButton;
}
- (void)setSmallScreenHiddenBackButton:(BOOL)smallScreenHiddenBackButton{
    _smallScreenHiddenBackButton = smallScreenHiddenBackButton;
    if (smallScreenHiddenBackButton) {
        if (_backButton.superview == nil) {
            [self addSubview:self.backButton];
        }
    }
    _backButton.hidden = smallScreenHiddenBackButton;
}

#pragma maek - UIGestureRecognizer
//单击手势
- (void)tapAction:(UITapGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.lockButton.isLocked) {
            if (self.lockButton.isHidden) {
                [self.lockButton kj_hiddenLockButton];
            }else{
                self.lockButton.hidden = YES;
            }
            return;
        }
        if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:isSingleTap:)]) {
            [self.delegate kj_basePlayerView:self isSingleTap:YES];
        }
    }
}
//双击手势
- (void)doubleAction:(UITapGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.lockButton.isLocked) return;
        if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:isSingleTap:)]) {
            [self.delegate kj_basePlayerView:self isSingleTap:NO];
        }
    }
}
//长按手势
- (void)longAction:(UILongPressGestureRecognizer*)longPress{
    if (self.lockButton.isLocked) return;
    if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:longPress:)]) {
        [self.delegate kj_basePlayerView:self longPress:longPress];
    }
}
//音量手势，亮度手势，快进倒退进度手势
- (void)panAction:(UIPanGestureRecognizer*)pan{
    if (self.lockButton.isLocked) return;
    PLAYER_WEAKSELF;
    void (^kSetBrightness)(float) = ^(float value){
        float brightness = weakself.lastValue - value / (weakself.height >> 1);
        kGCD_player_main(^{
            if ([weakself.delegate respondsToSelector:@selector(kj_basePlayerView:brightnessValue:)]) {
                if (![weakself.delegate kj_basePlayerView:weakself brightnessValue:brightness]) {
                    if (!weakself.vbLayer.superlayer) {
                        [weakself.layer addSublayer:weakself.vbLayer];
                    }else if (weakself.vbLayer.isHidden) {
                        weakself.vbLayer.hidden = NO;
                    }
                    weakself.vbLayer.isBrightness = YES;
                    weakself.vbLayer.value = brightness;
                }
            }
        });
    };
    void (^kSetVolume)(float) = ^(float value){
        float volume = weakself.lastValue - value / (weakself.height >> 1);
        kGCD_player_main(^{
            if ([weakself.delegate respondsToSelector:@selector(kj_basePlayerView:volumeValue:)]) {
                if (![weakself.delegate kj_basePlayerView:weakself volumeValue:volume]) {
                    if (!weakself.vbLayer.superlayer) {
                        [weakself.layer addSublayer:weakself.vbLayer];
                    }else if (weakself.vbLayer.isHidden) {
                        weakself.vbLayer.hidden = NO;
                    }
                    weakself.vbLayer.isBrightness = NO;
                    weakself.vbLayer.value = volume;
                }
            }
        });
    };
    CGPoint translate = [pan translationInView:pan.view];
    switch (pan.state) {
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateBegan:{
            CGPoint velocity = [pan velocityInView:pan.view];
            if (fabs(velocity.x) > fabs(velocity.y)) {
                movingH = YES;
            }else{
                movingH = NO;
                if (self.haveBrightness && self.haveVolume) {
                    if ([pan locationInView:self].x > self.width >> 1) {
                        self.lastValue = [AVAudioSession sharedInstance].outputVolume;
                    }else{
                        self.lastValue = [UIScreen mainScreen].brightness;
                    }
                }else if (self.haveBrightness) {
                    self.lastValue = [UIScreen mainScreen].brightness;
                }else if (self.haveVolume) {
                    self.lastValue = [AVAudioSession sharedInstance].outputVolume;
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if (movingH) {
                float value = translate.x / (self.width >> 1);
                value = MIN(MAX(-1, value), 1);
                if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:progress:end:)]) {
                    NSArray *array = [self.delegate kj_basePlayerView:self progress:value end:NO];
                    if (array.count == 2) {
                        NSTimeInterval totalTime = [array[1] floatValue];
                        if (totalTime <= 0) return;
                        if (self.fastLayer.superlayer == nil) {
                            [self.layer addSublayer:self.fastLayer];
                        }else{
                            self.fastLayer.hidden = NO;
                        }
                        NSTimeInterval time = [array[0] floatValue] + value * totalTime;
                        [self.fastLayer kj_updateFastValue:time?:0.0 TotalTime:totalTime];
                    }
                }
            }else{
                if (self.haveBrightness && self.haveVolume) {
                    if ([pan locationInView:self].x > self.width >> 1) {
                        kSetVolume(translate.y);
                    }else{
                        kSetBrightness(translate.y);
                    }
                }else if (self.haveBrightness) {
                    kSetBrightness(translate.y);
                }else if (self.haveVolume) {
                    kSetVolume(translate.y);
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:{
            if (movingH) {
                if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:progress:end:)]) {
                    float value = translate.x / (self.width >> 1);
                    value = MIN(MAX(-1, value), 1);
                    [self.delegate kj_basePlayerView:self progress:value end:YES];
                    if (_fastLayer) _fastLayer.hidden = YES;
                }
            }else{
                if (_vbLayer) _vbLayer.hidden = YES;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - method
/* 隐藏操作面板，是否隐藏返回按钮 */
- (void)kj_hiddenOperationView{
    [KJRotateManager kj_operationViewHiddenBasePlayerView:self];
}
/* 显示操作面板 */
- (void)kj_displayOperationView{
    [KJRotateManager kj_operationViewDisplayBasePlayerView:self];
}
/* 取消收起操作面板，可用于滑动滑杆时刻不自动隐藏 */
- (void)kj_cancelHiddenOperationView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(kj_hiddenOperationView) object:nil];
}

#pragma mark - lazy
- (UIPanGestureRecognizer *)pan{
    if (!_pan) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
        [pan setDelaysTouchesBegan:YES];
        [self addGestureRecognizer:pan];
        _pan = pan;
    }
    return _pan;
}
- (KJPlayerFastLayer *)fastLayer{
    if (!_fastLayer) {
        KJPlayerFastLayer *layer = [KJPlayerFastLayer layer];
        layer.mainColor = self.mainColor;
        layer.viceColor = self.viceColor;
        CGFloat w = 150,h = 80;
        layer.frame = CGRectMake((self.width-w)/2, (self.height-h)/2, w, h);
        CATextLayer *textLayer = [layer valueForKey:@"textLayer"];
        textLayer.frame = CGRectMake(0, h/4, w, h/4);
        _fastLayer = layer;
    }
    return _fastLayer;
}
- (KJPlayerSystemLayer *)vbLayer{
    if (!_vbLayer) {
        KJPlayerSystemLayer *layer = [KJPlayerSystemLayer layer];
        layer.mainColor = self.mainColor;
        layer.viceColor = self.viceColor;
        CGFloat w = 150,h = 40;
        layer.frame = CGRectMake((self.width-w)/2, (self.height-h)/2, w, h);
        _vbLayer = layer;
    }
    return _vbLayer;
}
- (KJPlayerLoadingLayer *)loadingLayer{
    if (!_loadingLayer) {
        CGFloat width = 40;
        KJPlayerLoadingLayer *layer = [KJPlayerLoadingLayer layer];
        [layer kj_setAnimationSize:CGSizeMake(width, width) color:self.mainColor];
        layer.frame = CGRectMake((self.width-width)/2.f, (self.height-width)/2.f, width, width);
        _loadingLayer = layer;
    }
    return _loadingLayer;
}
- (KJPlayerHintTextLayer *)hintTextLayer{
    if (!_hintTextLayer) {
        KJPlayerHintTextLayer *layer = [KJPlayerHintTextLayer layer];
        layer.backgroundColor = self.hintInfo.background.CGColor;
        [layer setValue:@(self.hintInfo.maxWidth) forKey:@"maxWidth"];
        [layer setValue:@(self.screenState) forKey:@"screenState"];
        [layer kj_setFont:self.hintInfo.font color:self.hintInfo.textColor];
        _hintTextLayer = layer;
    }
    return _hintTextLayer;
}
- (KJPlayerOperationView *)topView{
    if (!_topView) {
        _topView = [[KJPlayerOperationView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.operationViewHeight) OperationType:(KJPlayerOperationViewTypeTop)];
        _topView.mainColor = self.mainColor;
    }
    return _topView;
}
- (KJPlayerOperationView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[KJPlayerOperationView alloc] initWithFrame:CGRectMake(0, self.height-self.operationViewHeight, self.width, self.operationViewHeight) OperationType:(KJPlayerOperationViewTypeBottom)];
        _bottomView.mainColor = self.mainColor;
    }
    return _bottomView;
}
- (KJPlayerButton *)backButton{
    if (!_backButton) {
        CGFloat width = self.operationViewHeight - 20;
        _backButton = [[KJPlayerButton alloc]initWithFrame:CGRectMake(10, 10, width, width)];
        _backButton.mainColor = self.mainColor;
        _backButton.type = KJPlayerButtonTypeBack;
    }
    return _backButton;
}
- (KJPlayerButton *)lockButton{
    if (!_lockButton) {
        _lockButton = [[KJPlayerButton alloc]initWithFrame:CGRectMake(10, (self.height-kLockWidth)/2, kLockWidth, kLockWidth)];
        _lockButton.mainColor = self.mainColor;
        _lockButton.type = KJPlayerButtonTypeLock;
    }
    return _lockButton;
}
- (KJPlayerButton *)centerPlayButton{
    if (!_centerPlayButton) {
        _centerPlayButton = [[KJPlayerButton alloc]initWithFrame:CGRectMake((self.width-kCenterPlayWidth)/2, (self.height-kCenterPlayWidth)/2, kCenterPlayWidth, kCenterPlayWidth)];
        _centerPlayButton.mainColor = self.mainColor;
        _centerPlayButton.type = KJPlayerButtonTypeCenterPlay;
    }
    return _centerPlayButton;
}

@end
