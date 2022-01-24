//
//  KJPlayerButton.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerButton.h"
#import "KJBasePlayerView.h"
#import <objc/runtime.h>
#import "KJPlayerPod.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface UIButton (KJPlayerAreaInsets)
/// 设置按钮额外热区
@property(nonatomic,assign)UIEdgeInsets touchAreaInsets;

@end

@implementation KJPlayerButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self setTitleColor:self.mainColor forState:(UIControlStateNormal)];
        self.layer.zPosition = KJBasePlayerViewLayerZPositionButton;
    }
    return self;
}
- (void)buttonAction:(KJPlayerButton *)sender{
    sender.selected = !sender.selected;
    KJBasePlayerView *baseView = (KJBasePlayerView*)self.superview;
    if (baseView == nil) return;
    if (_type == KJPlayerButtonTypeBack) {
        if (baseView.screenState == KJPlayerVideoScreenStateFullScreen) {
            baseView.isFullScreen = NO;
        }
        if ([baseView.delegate respondsToSelector:@selector(kj_basePlayerView:clickBack:)]) {
            [baseView.delegate kj_basePlayerView:baseView clickBack:YES];
        }
    } else if (_type == KJPlayerButtonTypeLock) {
        self.isLocked = sender.selected;
        if (self.isLocked) {
            baseView.topView.hidden = YES;
            baseView.bottomView.hidden = YES;
            if (baseView.screenState == KJPlayerVideoScreenStateFullScreen) {
                baseView.backButton.hidden = YES;
            }
            [self kj_hiddenLockButton];
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(kj_lockButton) object:nil];
            [KJRotateManager kj_operationViewDisplayBasePlayerView:baseView];
        }
        if ([baseView.delegate respondsToSelector:@selector(kj_basePlayerView:locked:)]) {
            [baseView.delegate kj_basePlayerView:baseView locked:self.isLocked];
        }
    } else if (_type == KJPlayerButtonTypeCenterPlay) {
        
    }
    if ([baseView.delegate respondsToSelector:@selector(kj_basePlayerView:buttonType:playerButton:)]) {
        [baseView.delegate kj_basePlayerView:baseView buttonType:_type playerButton:sender];
    }
}

/// 隐藏锁屏按钮 
- (void)kj_hiddenLockButton{
    self.hidden = NO;
    self.alpha = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(kj_lockButton) object:nil];
    [self performSelector:@selector(kj_lockButton) withObject:nil afterDelay:1.];
}

- (void)kj_lockButton{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1;
    }];
}

- (void)setType:(KJPlayerButtonType)type{
    _type = type;
    if (type == KJPlayerButtonTypeBack) {
        self.layer.cornerRadius = self.frame.size.width/2;
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        [self setTitle:@"\U0000e697" forState:(UIControlStateNormal)];
        self.titleLabel.font = [KJPlayerPod iconFontOfSize:self.frame.size.width/4*3];
    } else if (type == KJPlayerButtonTypeLock) {
        self.hidden = YES;
        self.layer.cornerRadius = self.frame.size.width/2;
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        [self setTitle:@"\U0000e82b" forState:(UIControlStateNormal)];
        [self setTitle:@"\U0000e832" forState:(UIControlStateSelected)];
        self.titleLabel.font = [KJPlayerPod iconFontOfSize:self.frame.size.width/5*3];
        self.touchAreaInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    } else if (type == KJPlayerButtonTypeCenterPlay) {
        self.hidden = YES;
        [self setTitle:@"\U0000e719" forState:(UIControlStateNormal)];
        [self setTitle:@"\U0000e71a" forState:(UIControlStateSelected)];
        self.titleLabel.font = [KJPlayerPod iconFontOfSize:self.frame.size.width/5*3];
    }
}

@end

@implementation UIButton (KJPlayerAreaInsets)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event{
    UIEdgeInsets touchAreaInsets = self.touchAreaInsets;
    CGRect bounds = self.bounds;
    bounds = CGRectMake(bounds.origin.x - touchAreaInsets.left,
                        bounds.origin.y - touchAreaInsets.top,
                        bounds.size.width + touchAreaInsets.left + touchAreaInsets.right,
                        bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom);
    return CGRectContainsPoint(bounds, point);
}

#pragma mark - associated

- (UIEdgeInsets)touchAreaInsets{
    return [objc_getAssociatedObject(self, @selector(touchAreaInsets)) UIEdgeInsetsValue];
}
- (void)setTouchAreaInsets:(UIEdgeInsets)touchAreaInsets{
    NSValue *value = [NSValue valueWithUIEdgeInsets:touchAreaInsets];
    objc_setAssociatedObject(self, @selector(touchAreaInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma clang diagnostic pop
