//
//  KJPlayerOperationView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerOperationView.h"
#import "KJBasePlayerView.h"
#import "KJPlayerPod.h"

@interface KJPlayerOperationView ()
@property (nonatomic,strong) UIButton *fullButton;
@property (nonatomic,assign) CGRect lastRect;

@end

@implementation KJPlayerOperationView
/// 初始化 
- (instancetype)initWithFrame:(CGRect)frame operationType:(KJPlayerOperationViewType)operationType{
    if (self = [super initWithFrame:frame]) {
        self.lastRect = frame;
        CGFloat height = frame.size.height;
        if (operationType == KJPlayerOperationViewTypeTop) {
            self.backgroundColor = [self kj_gradientColor:[UIColor.blackColor colorWithAlphaComponent:0.8],
                                    [UIColor.blackColor colorWithAlphaComponent:0.],nil](CGSizeMake(1, height));
        } else {
            self.backgroundColor = [self kj_gradientColor:[UIColor.blackColor colorWithAlphaComponent:0.],
                                    [UIColor.blackColor colorWithAlphaComponent:0.8],nil](CGSizeMake(1, height));
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-height, 0, height, height)];
            self.fullButton = button;
            [button addTarget:self action:@selector(fullItemClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"\U0000e627" forState:(UIControlStateNormal)];
            [button setTitleColor:self.mainColor forState:(UIControlStateNormal)];
            button.titleLabel.font = [KJPlayerPod iconFontOfSize:height/5*2];
            [self addSubview:button];
        }
        self.layer.zPosition = KJBasePlayerViewLayerZPositionInteraction;
        self.userInteractionEnabled = YES;
    }
    return self;
}
- (void)fullItemClick:(UIButton*)sender{
    KJPlayerView *view = (KJPlayerView *)self.superview;
    view.isFullScreen = !view.isFullScreen;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if (CGRectEqualToRect(self.lastRect, self.frame)) {
        return;
    }
    self.lastRect = self.frame;
    if (_fullButton) {
        CGFloat height = self.frame.size.height;
        self.fullButton.frame = CGRectMake(self.frame.size.width-height, 0, height, height);
        self.fullButton.titleLabel.font = [UIFont fontWithName:@"KJPlayerfont" size:height/5*2];
    }
    if (self.kVideoOperationViewChanged) {
        self.kVideoOperationViewChanged(self);
    }
}

/// 渐变色
/// @param color 不定参数颜色
- (UIColor * (^)(CGSize))kj_gradientColor:(UIColor *)color,...{
    NSMutableArray * colors = [NSMutableArray arrayWithObjects:(id)color.CGColor,nil];
    va_list args;UIColor * arg;
    va_start(args, color);
    while ((arg = va_arg(args, UIColor *))) {
        [colors addObject:(id)arg.CGColor];
    }
    va_end(args);
    return ^UIColor * (CGSize size){
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)colors, NULL);
        CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(size.width, size.height), 0);
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorspace);
        UIGraphicsEndImageContext();
        return [UIColor colorWithPatternImage:image];
    };
}

@end
