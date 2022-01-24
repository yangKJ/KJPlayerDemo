//
//  KJBasePlayerView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayerView.h"
#import "KJRotateManager.h"

#define kLockWidth (40)
#define kCenterPlayWidth (60)

@interface KJBasePlayerView ()
@property (nonatomic,assign) CGSize size;

@end

@implementation KJBasePlayerView

#pragma mark - subclass method

/// 配置初始化信息
- (void)kj_subclassInitializeConfiguration{
    self.size = self.frame.size;
    self.operationViewHeight = 60;
    self.isHiddenBackButton = YES;
    self.smallScreenHiddenBackButton = YES;
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self addSubview:self.lockButton];
    [self addSubview:self.centerPlayButton];
    [self kj_hiddenOperationView];
}

/// 屏幕旋转
- (void)kj_subclassOrientation{
    [KJRotateManager kj_rotateAutoFullScreenBasePlayerView:self];
}

/// 尺寸发生改变
/// @param size 改变后的尺寸
- (void)kj_subclassChangeSize:(CGSize)size{
    self.size = size;
    [self.hintTextLayer setValue:@(self.screenState) forKey:@"screenState"];
    self.loadingLayer.position = CGPointMake(size.width/2, size.height/2);
    self.fastLayer.position = CGPointMake(size.width/2, size.height/2);
    self.vbLayer.position = CGPointMake(size.width/2, size.height/2);
    self.topView.frame = CGRectMake(0, 0, size.width, self.operationViewHeight);
    self.bottomView.frame = CGRectMake(0, size.height-self.operationViewHeight, size.width, self.operationViewHeight);
    self.lockButton.frame = CGRectMake(10, (size.height-kLockWidth)/2, kLockWidth, kLockWidth);
    self.centerPlayButton.frame = CGRectMake((size.width-kCenterPlayWidth)/2, (size.height-kCenterPlayWidth)/2, kCenterPlayWidth, kCenterPlayWidth);
}

/// 全屏模式
/// @param full 是否全屏
- (void)kj_subclassFullScreen:(BOOL)full{
    self.lockButton.hidden = !full;
    if (full) {
        [KJRotateManager kj_rotateFullScreenBasePlayerView:self];
        self.backButton.hidden = self.fullScreenHiddenBackButton;
        [self kj_displayOperationView];
    } else {
        [KJRotateManager kj_rotateSmallScreenBasePlayerView:self];
        self.backButton.hidden = self.smallScreenHiddenBackButton;
    }
}

/// 手势处理
/// @param tap 是否为单击
/// @return 方式是否跳过后续操作
- (BOOL)kj_subclassTapLocked:(BOOL)tap{
    if (tap == NO) {
        if (self.lockButton.isLocked) return YES;
    }
    if (self.lockButton.isLocked) {
        if (self.lockButton.isHidden) {
            [self.lockButton kj_hiddenLockButton];
        } else {
            self.lockButton.hidden = YES;
        }
        return YES;
    }
    return NO;
}

/// 设置音量
/// @param value 音量
- (void)kj_subclassBrightnessValue:(float)value{
    if (!self.vbLayer.superlayer) {
        [self.layer addSublayer:self.vbLayer];
    }else if (self.vbLayer.isHidden) {
        self.vbLayer.hidden = NO;
    }
    self.vbLayer.isBrightness = YES;
    self.vbLayer.value = value;
}

/// 设置亮度
/// @param value 亮度
- (void)kj_subclassVolumeValue:(float)value{
    if (!self.vbLayer.superlayer) {
        [self.layer addSublayer:self.vbLayer];
    }else if (self.vbLayer.isHidden) {
        self.vbLayer.hidden = NO;
    }
    self.vbLayer.isBrightness = NO;
    self.vbLayer.value = value;
}

/// 快进处理
/// @param timeUnion 总时长和当前时间
/// @param value 进度比例
- (void)kj_subclassFastTimeUnion:(KJPlayerTimeUnion)timeUnion value:(float)value{
    if (timeUnion.isReplace == true || timeUnion.totalTime <= 0) return;
    if (self.fastLayer.superlayer == nil) {
        [self.layer addSublayer:self.fastLayer];
    } else {
        self.fastLayer.hidden = NO;
    }
    CGFloat _value = (timeUnion.currentTime + value * timeUnion.totalTime) ?: 0.0;
    [self.fastLayer kj_updateFastValue:_value totalTime:timeUnion.totalTime];
}

/// 隐藏快进弹框
- (void)kj_subclassHiddenFast{
    if (_fastLayer) _fastLayer.hidden = YES;
}

/// 隐藏音量亮度弹框
- (void)kj_subclassHiddenSystem{
    if (_vbLayer) _vbLayer.hidden = YES;
}

#pragma mark - setter

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

#pragma mark - public method

/// 隐藏操作面板，是否隐藏返回按钮
- (void)kj_hiddenOperationView{
    [super kj_hiddenOperationView];
    [KJRotateManager kj_operationViewHiddenBasePlayerView:self];
}
/// 显示操作面板
- (void)kj_displayOperationView{
    [super kj_displayOperationView];
    [KJRotateManager kj_operationViewDisplayBasePlayerView:self];
}
/// 取消收起操作面板，可用于滑动滑杆时刻不自动隐藏
- (void)kj_cancelHiddenOperationView{
    [super kj_cancelHiddenOperationView];
}

#pragma mark - lazy

- (KJPlayerFastLayer *)fastLayer{
    if (!_fastLayer) {
        KJPlayerFastLayer *layer = [KJPlayerFastLayer layer];
        layer.mainColor = self.mainColor;
        layer.viceColor = self.viceColor;
        CGFloat w = 150,h = 80;
        layer.frame = CGRectMake((self.size.width-w)/2, (self.size.height-h)/2, w, h);
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
        layer.frame = CGRectMake((self.size.width-w)/2, (self.size.height-h)/2, w, h);
        _vbLayer = layer;
    }
    return _vbLayer;
}
- (KJPlayerLoadingLayer *)loadingLayer{
    if (!_loadingLayer) {
        CGFloat width = 40;
        KJPlayerLoadingLayer *layer = [KJPlayerLoadingLayer layer];
        [layer setValue:self forKey:@"loadSuperPlayerView"];
        [layer kj_setAnimationSize:CGSizeMake(width, width) color:self.mainColor];
        layer.frame = CGRectMake((self.size.width-width)/2.f, (self.size.height-width)/2.f, width, width);
        _loadingLayer = layer;
    }
    return _loadingLayer;
}
- (KJPlayerHintLayer *)hintTextLayer{
    if (!_hintTextLayer) {
         _hintTextLayer = [KJPlayerHintLayer layer];
        [_hintTextLayer setValue:self forKey:@"hintSuperPlayerView"];
        [_hintTextLayer kj_setHintFont:nil textColor:nil background:nil maxWidth:250];
    }
    return _hintTextLayer;
}
- (KJPlayerOperationView *)topView{
    if (!_topView) {
        _topView = [[KJPlayerOperationView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.operationViewHeight)
                                                  operationType:(KJPlayerOperationViewTypeTop)];
        _topView.mainColor = self.mainColor;
    }
    return _topView;
}
- (KJPlayerOperationView *)bottomView{
    if (!_bottomView) {
        CGFloat height = self.operationViewHeight;
        _bottomView = [[KJPlayerOperationView alloc] initWithFrame:CGRectMake(0, self.size.height - height, self.size.width, height)
                                                     operationType:(KJPlayerOperationViewTypeBottom)];
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
        _lockButton = [[KJPlayerButton alloc]initWithFrame:CGRectMake(10, (self.size.height-kLockWidth)/2, kLockWidth, kLockWidth)];
        _lockButton.mainColor = self.mainColor;
        _lockButton.type = KJPlayerButtonTypeLock;
    }
    return _lockButton;
}
- (KJPlayerButton *)centerPlayButton{
    if (!_centerPlayButton) {
        CGFloat width = kCenterPlayWidth;
        _centerPlayButton = [[KJPlayerButton alloc]initWithFrame:CGRectMake((self.size.width-width)/2, (self.size.height-width)/2, width, width)];
        _centerPlayButton.mainColor = self.mainColor;
        _centerPlayButton.type = KJPlayerButtonTypeCenterPlay;
    }
    return _centerPlayButton;
}

@end
