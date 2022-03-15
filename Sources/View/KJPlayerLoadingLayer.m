//
//  KJPlayerLoadingLayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerLoadingLayer.h"
#import "KJBasePlayerView.h"
#import "KJPlayerConst.h"

@interface KJPlayerLoadingLayer ()
/// 载体，外界kvc传入
@property (nonatomic, strong) KJBasePlayerView * loadSuperPlayerView;

@end

@implementation KJPlayerLoadingLayer

- (instancetype)init{
    if (self = [super init]) {
        self.zPosition = KJBasePlayerViewLayerZPositionLoading;
    }
    return self;
}
/// 圆圈加载动画 
- (void)kj_setAnimationSize:(CGSize)size color:(UIColor*)color{
    CGFloat beginTime = 0.5;
    CGFloat strokeStartDuration = 1.2;
    CGFloat strokeEndDuration = 0.7;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat lineWidth = 2.f;
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.byValue = @(M_PI * 2);
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.duration = strokeEndDuration;
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.4:0.0:0.2:1.0];
    strokeEndAnimation.fromValue = @(0);
    strokeEndAnimation.toValue = @(1);
    
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.duration = strokeStartDuration;
    strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.4:0.0:0.2:1.0];
    strokeStartAnimation.fromValue = @(0);
    strokeStartAnimation.toValue = @(1);
    strokeStartAnimation.beginTime = beginTime;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[rotationAnimation, strokeEndAnimation, strokeStartAnimation];
    groupAnimation.duration = strokeStartDuration + beginTime;
    groupAnimation.repeatCount = INFINITY;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.fillMode = kCAFillModeForwards;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(width/2.f,height/2.f)
                    radius:width/2.f
                startAngle:-M_PI/2.f
                  endAngle:M_PI + M_PI/2.f
                 clockwise:YES];
    self.fillColor = nil;
    self.strokeColor = color.CGColor;
    self.lineWidth = lineWidth;
    self.backgroundColor = nil;
    self.path = path.CGPath;
    self.frame = CGRectMake(0, 0, width, height);
    [self addAnimation:groupAnimation forKey:@"animation"];
}

#pragma mark - Animation

/// 圆圈加载动画
- (void)kj_startAnimation{
    kGCD_player_main(^{
        if (CGRectEqualToRect(CGRectZero, self.loadSuperPlayerView.frame)) {
            return;
        }
    });
    if (self.superlayer == nil) {
        [self.loadSuperPlayerView.layer addSublayer:self];
    }
}

/// 停止动画
- (void)kj_stopAnimation{
    [UIView animateWithDuration:1.f animations:^{
        [self removeFromSuperlayer];
    }];
}

@end
