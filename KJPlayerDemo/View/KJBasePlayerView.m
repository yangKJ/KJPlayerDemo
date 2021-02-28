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
NSString *kPlayerBaseViewChangeNotification = @"kPlayerBaseViewNotification";
NSString *kPlayerBaseViewChangeKey = @"kPlayerBaseViewKey";
@interface KJBasePlayerView ()<UIGestureRecognizerDelegate>
@property (nonatomic,assign) KJPlayerVideoScreenState screenState;
@property (nonatomic,assign) NSInteger width,height;
@property (nonatomic,assign) BOOL haveVolume;
@property (nonatomic,assign) BOOL haveBrightness;
@property (nonatomic,assign) float lastValue;
@property (nonatomic,strong) UIPanGestureRecognizer *pan;
@property (nonatomic,strong) UISlider *systemVolumeSlider;
@property (nonatomic,strong) KJPlayerHintInfo *hintInfo;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,assign) BOOL displayOperation;
@end
@implementation KJBasePlayerView
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.systemVolumeSlider removeFromSuperview];
    _systemVolumeSlider = nil;
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
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    self.smallScreenHiddenBackButton = YES;
    self.displayOperation = YES;
    [self kj_hiddenOperationView];
}
#pragma mark - NSNotification
//屏幕旋转
- (void)kj_orientationChange:(NSNotification*)notification{
    
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
    if (_hintTextLayer) [_hintTextLayer setValue:@(self.screenState) forKey:@"screenState"];
    self.topView.frame = CGRectMake(0, 0, self.width, self.operationViewHeight);
    self.bottomView.frame = CGRectMake(0, self.height-self.operationViewHeight, self.width, self.operationViewHeight);
    [self.topView kj_reloadUI];
    [self.bottomView kj_reloadUI];
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
    if (self.backButton.superview == nil) {
        [self addSubview:self.backButton];
    }
    self.backButton.hidden = fullScreenHiddenBackButton;
}
- (void)setSmallScreenHiddenBackButton:(BOOL)smallScreenHiddenBackButton{
    _smallScreenHiddenBackButton = smallScreenHiddenBackButton;
    if (self.backButton.superview == nil) {
        [self addSubview:self.backButton];
    }
    self.backButton.hidden = smallScreenHiddenBackButton;
}

#pragma maek - UIGestureRecognizer
//单击手势
- (void)tapAction:(UITapGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:isSingleTap:)]) {
            [self.delegate kj_basePlayerView:self isSingleTap:YES];
        }
    }
}
//双击手势
- (void)doubleAction:(UITapGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:isSingleTap:)]) {
            [self.delegate kj_basePlayerView:self isSingleTap:NO];
        }
    }
}
//长按手势
- (void)longAction:(UILongPressGestureRecognizer*)longPress{
    if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:longPress:)]) {
        [self.delegate kj_basePlayerView:self longPress:longPress];
    }
}
//音量手势，亮度手势，快进倒退进度手势
static BOOL movingH;
- (void)panAction:(UIPanGestureRecognizer*)pan{
    PLAYER_WEAKSELF;
    void (^kSetBrightness)(float) = ^(float value){
        float brightness = weakself.lastValue - value / (weakself.height/2);
        if (isnan(brightness)) return;
        brightness = MIN(MAX(0, brightness), 1);
        [UIScreen mainScreen].brightness = brightness;
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
        float volume = weakself.lastValue - value / (weakself.height/2);
        if (isnan(volume)) return;
        volume = MIN(MAX(0, volume), 1);
        kGCD_player_main(^{
            [weakself.systemVolumeSlider setValue:volume animated:NO];
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
                float value = translate.x / (self.width>>1);
                value = MIN(MAX(-1, value), 1);
                if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:progress:end:)]) {
                    NSArray *array = [self.delegate kj_basePlayerView:self progress:value end:NO];
                    if (array.count == 2) {
                        NSTimeInterval totalTime = [array[1] floatValue];
                        if (totalTime <= 0) return;
                        if (!self.fastLayer.superlayer) {
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
                    float value = translate.x / (self.width>>1);
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
    _displayOperation = NO;
//    CGFloat y1 = self.topView.frame.origin.y;
//    CGFloat y2 = self.bottomView.frame.origin.y;
    [UIView animateWithDuration:0.5f animations:^{
//        if (self.screenState == KJPlayerVideoScreenStateFullScreen) {
//            self.topView.frame = CGRectMake(self.topView.frame.origin.x, -self.topView.frame.size.height, self.topView.frame.size.width, self.topView.frame.size.height);
//            self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, y2+self.bottomView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
//        }else{
        self.topView.hidden = YES;
        self.bottomView.hidden = YES;
        if (self.screenState == KJPlayerVideoScreenStateFullScreen) {
            self.backButton.hidden = self.isHiddenBackButton;
        }else if (self.smallScreenHiddenBackButton) {
            self.backButton.hidden = YES;
        }
//        }
    } completion:^(BOOL finished) {
//        if (self.screenState == KJPlayerVideoScreenStateFullScreen) {
//            self.topView.hidden = YES;
//            self.bottomView.hidden = YES;
//        }
//        self.topView.frame = CGRectMake(self.topView.frame.origin.x, y1, self.topView.frame.size.width, self.topView.frame.size.height);
//        self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, y2, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
    }];
}
/* 显示操作面板 */
- (void)kj_displayOperationView{
    _displayOperation = YES;
    [UIView animateWithDuration:0.3f animations:^{
        self.topView.hidden = NO;
        self.bottomView.hidden = NO;
        if (self.screenState == KJPlayerVideoScreenStateFullScreen) {
            self.backButton.hidden = self.fullScreenHiddenBackButton;
        }else if (self.smallScreenHiddenBackButton == NO) {
            self.backButton.hidden = NO;
        }
    } completion:^(BOOL finished) {
        if (self.autoHideTime) {
            [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(kj_hiddenOperationView) object:nil];
            [self performSelector:@selector(kj_hiddenOperationView) withObject:nil afterDelay:self.autoHideTime];
        }
    }];
}

#pragma mark - action
- (void)backItemClick{
    if (self.screenState == KJPlayerVideoScreenStateFullScreen) {
        self.isFullScreen = NO;
    }
    if (self.kVideoClickButtonBack) {
        self.kVideoClickButtonBack(self);
    }
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
- (UISlider *)systemVolumeSlider{
    if (!_systemVolumeSlider) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *subview in volumeView.subviews) {
            if ([subview.class.description isEqualToString:@"MPVolumeSlider"]) {
                _systemVolumeSlider = (UISlider*)subview;
                break;
            }
        }
    }
    return _systemVolumeSlider;
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
- (UIButton *)backButton{
    if (!_backButton) {
        CGFloat width = self.operationViewHeight - 20;
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, width, width)];
        button.layer.cornerRadius = width/2;
        button.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        [button addTarget:self action:@selector(backItemClick) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"\U0000e697" forState:(UIControlStateNormal)];
        [button setTitleColor:self.mainColor forState:(UIControlStateNormal)];
        button.titleLabel.font = [UIFont fontWithName:@"iconfont" size:width];
        button.layer.zPosition = KJBasePlayerViewLayerZPositionBackButton;
        _backButton = button;
    }
    return _backButton;
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

@end
