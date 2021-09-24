//
//  KJPlayerView.m
//  KJPlayer
//
//  Created by yangkejun on 2021/8/12.
//

#import "KJPlayerView.h"
#import "KJPlayerConst.h"

@interface KJPlayerView () <UIGestureRecognizerDelegate>{
    BOOL movingH;
}
@property (nonatomic,assign) KJPlayerVideoScreenState screenState;
@property (nonatomic,strong) UIPanGestureRecognizer * panGesture;
@property (nonatomic,assign) NSInteger width,height;
@property (nonatomic,assign) float lastValue;
@property (nonatomic,assign) BOOL haveVolume;
@property (nonatomic,assign) BOOL haveBrightness;
@property (nonatomic,assign) BOOL displayOperation;

@end

@implementation KJPlayerView

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kj_orientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    self.longPressTime = 1.f;
    self.mainColor = UIColor.whiteColor;
    self.viceColor = UIColor.redColor;
    self.width  = self.frame.size.width;
    self.height = self.frame.size.height;
    self.autoRotate = YES;
    self.autoHideTime = 2.f;
    self.displayOperation = YES;
    [self kj_subclassInitializeConfiguration];
}

#pragma mark - subclass method

/// 配置初始化信息
- (void)kj_subclassInitializeConfiguration{ }

/// 屏幕旋转
- (void)kj_subclassOrientation{ }

/// 全屏模式
/// @param full 是否全屏
- (void)kj_subclassFullScreen:(BOOL)full{ }

/// 尺寸发生改变
/// @param size 改变后的尺寸
- (void)kj_subclassChangeSize:(CGSize)size{ }

/// 手势处理
/// @param tap 是否为单击
/// @return 方式是否跳过后续操作
- (BOOL)kj_subclassTapLocked:(BOOL)tap{
    return NO;
}

/// 设置音量
/// @param value 音量
- (void)kj_subclassBrightnessValue:(float)value{ }

/// 设置亮度
/// @param value 亮度
- (void)kj_subclassVolumeValue:(float)value{ }

/// 快进处理
/// @param timeUnion 总时长和当前时间
/// @param value 进度比例
- (void)kj_subclassFastTimeUnion:(KJPlayerTimeUnion)timeUnion value:(float)value{ }

/// 隐藏快进弹框
- (void)kj_subclassHiddenFast{ }

/// 隐藏音量亮度弹框
- (void)kj_subclassHiddenSystem{ }

#pragma mark - NSNotification

/// 屏幕旋转
- (void)kj_orientationChange:(NSNotification *)notification{
    if (self.autoRotate) {
        [self kj_subclassOrientation];
    }
}

#pragma mark - method

/// 隐藏操作面板
- (void)kj_hiddenOperationView{
    self.displayOperation = NO;
}

/// 显示操作面板
- (void)kj_displayOperationView{
    self.displayOperation = YES;
}

/// 取消收起操作面板，可用于滑动滑杆时刻不自动隐藏
- (void)kj_cancelHiddenOperationView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(kj_hiddenOperationView)
                                               object:nil];
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if ([keyPath isEqualToString:@"frame"] || [keyPath isEqualToString:@"bounds"]) {
        if ([object valueForKeyPath:keyPath] != [NSNull null]) {
            NSDictionary * userInfo = @{
                kPlayerBaseViewChangeKey : [object valueForKeyPath:keyPath]
            };
            PLAYER_POST_NOTIFICATION(kPlayerBaseViewChangeNotification, self, userInfo);
            CGRect rect = [[object valueForKeyPath:keyPath] CGRectValue];
            self.width  = rect.size.width;
            self.height = rect.size.height;
            [self kj_subclassChangeSize:rect.size];
        }
    }
}

#pragma mark - setter

- (void)setGestureType:(KJPlayerGestureType)gestureType{
    if (gestureType != _gestureType) {
        for (UIGestureRecognizer * gesture in self.gestureRecognizers) {
             [self removeGestureRecognizer:gesture];
        }
    }
    _gestureType = gestureType;
    if (_panGesture) _panGesture = nil;
    self.haveVolume = self.haveBrightness = NO;
    BOOL haveTap = NO;
    UITapGestureRecognizer * tapGesture = nil;
    if (gestureType == 1 || (gestureType & KJPlayerGestureTypeSingleTap)) {
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [tapGesture setDelaysTouchesBegan:YES];
        [self addGestureRecognizer:tapGesture];
        haveTap = YES;
    }
    if (gestureType == 2 || (gestureType & KJPlayerGestureTypeDoubleTap)) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleAction:)];
        [gesture setNumberOfTapsRequired:2];
        [gesture setDelaysTouchesBegan:YES];
        [self addGestureRecognizer:gesture];
        if (haveTap) [tapGesture requireGestureRecognizerToFail:gesture];
    }
    if (gestureType == 3 || (gestureType & KJPlayerGestureTypeLong)) {
        UILongPressGestureRecognizer * longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
        longPress.minimumPressDuration = self.longPressTime;
        [self addGestureRecognizer:longPress];
    }
    if (gestureType == 4 || (gestureType & KJPlayerGestureTypeProgress)) {
        if (self.panGesture) { }
    }
    if (gestureType == 5 || (gestureType & KJPlayerGestureTypeVolume)) {
        self.haveVolume = YES;
        if (self.panGesture) { }
    }
    if (gestureType == 6 || (gestureType & KJPlayerGestureTypeBrightness)) {
        self.haveBrightness = YES;
        if (self.panGesture) { }
    }
}
- (void)setIsFullScreen:(BOOL)isFullScreen{
    if (isFullScreen == _isFullScreen) return;
    _isFullScreen = isFullScreen;
    self.screenState = isFullScreen ? KJPlayerVideoScreenStateFullScreen : KJPlayerVideoScreenStateSmallScreen;
    [self kj_subclassFullScreen:isFullScreen];
    if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:screenState:)]) {
        [self.delegate kj_basePlayerView:self screenState:self.screenState];
    }
}

#pragma mark - gesture

/// 单击手势
- (void)tapAction:(UITapGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self kj_subclassTapLocked:YES]) {
            return;
        }
        if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:isSingleTap:)]) {
            [self.delegate kj_basePlayerView:self isSingleTap:YES];
        }
    }
}
/// 双击手势
- (void)doubleAction:(UITapGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self kj_subclassTapLocked:YES]) {
            return;
        }
        if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:isSingleTap:)]) {
            [self.delegate kj_basePlayerView:self isSingleTap:NO];
        }
    }
}
/// 长按手势
- (void)longAction:(UILongPressGestureRecognizer *)longPress{
    if ([self kj_subclassTapLocked:YES]) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:longPress:)]) {
        [self.delegate kj_basePlayerView:self longPress:longPress];
    }
}
/// 音量手势，亮度手势，快进倒退进度手势
- (void)panAction:(UIPanGestureRecognizer *)pan{
    if ([self kj_subclassTapLocked:YES]) {
        return;
    }
    PLAYER_WEAKSELF;
    void (^kSetBrightness)(float) = ^(float value){
        float brightness = weakself.lastValue - value / (weakself.height >> 1);
        kGCD_player_main(^{
            if ([weakself.delegate respondsToSelector:@selector(kj_basePlayerView:brightnessValue:)]) {
                if (![weakself.delegate kj_basePlayerView:weakself brightnessValue:brightness]) {
                    [weakself kj_subclassBrightnessValue:brightness];
                }
            }
        });
    };
    void (^kSetVolume)(float) = ^(float value){
        float volume = weakself.lastValue - value / (weakself.height >> 1);
        kGCD_player_main(^{
            if ([weakself.delegate respondsToSelector:@selector(kj_basePlayerView:volumeValue:)]) {
                if (![weakself.delegate kj_basePlayerView:weakself volumeValue:volume]) {
                    [weakself kj_subclassVolumeValue:volume];
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
            } else {
                movingH = NO;
                if (self.haveBrightness && self.haveVolume) {
                    if ([pan locationInView:self].x > self.width >> 1) {
                        self.lastValue = [AVAudioSession sharedInstance].outputVolume;
                    } else {
                        self.lastValue = [UIScreen mainScreen].brightness;
                    }
                } else if (self.haveBrightness) {
                    self.lastValue = [UIScreen mainScreen].brightness;
                } else if (self.haveVolume) {
                    self.lastValue = [AVAudioSession sharedInstance].outputVolume;
                }
            }
        } break;
        case UIGestureRecognizerStateChanged:{
            if (movingH) {
                float value = translate.x / (self.width >> 1);
                value = MIN(MAX(-1, value), 1);
                if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:progress:end:)]) {
                    KJPlayerTimeUnion timeUnion = [self.delegate kj_basePlayerView:self progress:value end:NO];
                    [self kj_subclassFastTimeUnion:timeUnion value:value];
                }
            } else {
                if (self.haveBrightness && self.haveVolume) {
                    if ([pan locationInView:self].x > self.width >> 1) {
                        kSetVolume(translate.y);
                    } else {
                        kSetBrightness(translate.y);
                    }
                } else if (self.haveBrightness) {
                    kSetBrightness(translate.y);
                } else if (self.haveVolume) {
                    kSetVolume(translate.y);
                }
            }
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:{
            if (movingH) {
                if ([self.delegate respondsToSelector:@selector(kj_basePlayerView:progress:end:)]) {
                    float value = translate.x / (self.width >> 1);
                    value = MIN(MAX(-1, value), 1);
                    [self.delegate kj_basePlayerView:self progress:value end:YES];
                    [self kj_subclassHiddenFast];
                }
            } else {
                [self kj_subclassHiddenSystem];
            }
        } break;
        default:break;
    }
}

#pragma mark - lazy

- (UIPanGestureRecognizer *)panGesture{
    if (_panGesture == nil) {
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
        _panGesture.delegate = self;
        [_panGesture setMaximumNumberOfTouches:1];
        [_panGesture setDelaysTouchesBegan:YES];
        [_panGesture setDelaysTouchesEnded:YES];
        [_panGesture setCancelsTouchesInView:YES];
        [self addGestureRecognizer:_panGesture];
    }
    return _panGesture;
}

@end
