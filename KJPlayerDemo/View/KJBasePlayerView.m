//
//  KJBasePlayerView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayerView.h"
#import <MediaPlayer/MPVolumeView.h>
NSString *kPlayerBaseViewChangeNotification = @"kPlayerBaseViewNotification";
NSString *kPlayerBaseViewChangeKey = @"kPlayerBaseViewKey";
@interface KJBasePlayerView ()<UIGestureRecognizerDelegate>
@property (nonatomic,assign) NSInteger width,height;
@property (nonatomic,assign) BOOL haveVolume;
@property (nonatomic,assign) BOOL haveBrightness;
@property (nonatomic,assign) float lastValue;
@property (nonatomic,strong) UIPanGestureRecognizer *pan;
@property (nonatomic,strong) UISlider *systemVolumeSlider;
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
    [self addObserver:self forKeyPath:@"frame"  options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kj_orientationChange:)
                          name:UIDeviceOrientationDidChangeNotification object:nil];
    self.longPressTime = 1.;
    self.mainColor = UIColor.whiteColor;
    self.width = self.frame.size.width;
    self.height = self.frame.size.height;
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
        }
    }
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
            self.width  = (NSInteger)self.frame.size.width;
            self.height = (NSInteger)self.frame.size.height;
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

#pragma mark - public method
+ (UIWindow*)window{
    return ({
        UIWindow *window;
        if (@available(iOS 13.0, *)) {
            window = [UIApplication sharedApplication].windows.firstObject;
        }else{
            window = [UIApplication sharedApplication].keyWindow;
        }
        window;
    });
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
        KJPlayerFastLayer *layer = [[KJPlayerFastLayer layer] init];
        layer.mainColor = self.mainColor;
        CGFloat w = 150,h = 80;
        [layer kj_setLayerNewFrame:CGRectMake((self.width-w)/2, (self.height-h)/2, w, h)];
        _fastLayer = layer;
    }
    return _fastLayer;
}
- (KJPlayerSystemLayer *)vbLayer{
    if (!_vbLayer) {
        KJPlayerSystemLayer *layer = [[KJPlayerSystemLayer layer] init];
        layer.mainColor = self.mainColor;
        CGFloat w = 150,h = 40;
        [layer kj_setLayerNewFrame:CGRectMake((self.width-w)/2, (self.height-h)/2, w, h)];
        _vbLayer = layer;
    }
    return _vbLayer;
}

@end
