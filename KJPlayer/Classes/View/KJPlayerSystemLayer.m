//
//  KJPlayerSystemLayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerSystemLayer.h"
#import <MediaPlayer/MPVolumeView.h>
#import "KJPlayerType.h"

@interface KJPlayerSystemLayer ()
@property (nonatomic,strong) UISlider *systemVolumeSlider;

@end

@implementation KJPlayerSystemLayer
- (void)dealloc{
    if (_systemVolumeSlider) {
        [self.systemVolumeSlider removeFromSuperview];
        _systemVolumeSlider = nil;
    }
}
- (instancetype)init{
    if (self = [super init]) {
        self.cornerRadius = 7;
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8].CGColor;
        self.zPosition = KJBasePlayerViewLayerZPositionDisplayLayer;
//        self.shouldRasterize = YES;
    }
    return self;
}
- (void)setValue:(float)value{
    _value = MIN(MAX(0, value), 1);
    if (self.isBrightness) {
        [UIScreen mainScreen].brightness = _value;
    } else {
        [self.systemVolumeSlider setValue:_value animated:NO];
    }
    [self setNeedsDisplay];
}

#pragma mark - draw

- (void)drawInContext:(CGContextRef)context{
    CGFloat width = self.frame.size.width;
    CGFloat y = self.frame.size.height / 2;
    CGFloat sp = width/8.0;
    CGFloat mark = self.frame.size.height-sp;
    UIGraphicsPushContext(context);
    
    CGFloat h = self.frame.size.height/4*3;
    CGFloat w = mark/2;
    CGFloat line = mark/10;
    CGFloat _sp = sp/2;
    if (self.isBrightness) {
        [self.mainColor set];
        CGContextAddArc(context, w+_sp, y, mark/4, 0, 2*M_PI, 1);
        CGContextFillPath(context);
        [self.mainColor set];
        CGContextSetLineWidth(context, line*2);
        for (int i = 0; i < 12; i++) {
            float angle_start = radians(i*30);
            float angle_end = radians((i+1)*30-15);
            CGContextAddArc(context, w+_sp, y, mark/2, angle_start, angle_end, 0);
            CGContextStrokePath(context);
        }
    } else {
        [self.mainColor set];
        CGContextSetLineWidth(context, line);
        CGContextAddArc(context, w+_sp, h/5*3, w-line, 0, M_PI, 0);
        CGContextMoveToPoint(context, w+_sp, h/5*3+w-line);
        CGContextAddLineToPoint(context, w+_sp, h-line/2+_sp/2);
        CGContextMoveToPoint(context, mark/4+_sp, h-line+_sp/2);
        CGContextAddLineToPoint(context, mark/4*3+_sp, h-line+_sp/2);
        CGContextStrokePath(context);
        
        CGContextAddArc(context, w+_sp, w, mark/4, 0, M_PI, 1);
        CGContextAddArc(context, w+_sp, h/5*3, mark/4, M_PI, 0, 1);
        CGContextMoveToPoint(context, mark/4*3+_sp, w);
        CGContextAddLineToPoint(context, mark/4*3+_sp, h-mark/4*3);
        CGContextFillPath(context);
    }
    
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextSetStrokeColorWithColor(context, self.mainColor.CGColor);
    CGContextMoveToPoint(context, sp+mark, y);
    CGContextAddLineToPoint(context, width-sp, y);
    CGContextSetLineWidth(context, 3.5f);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, self.viceColor.CGColor);
    CGContextMoveToPoint(context, sp+mark, y);
    CGContextAddLineToPoint(context, self.value*(width-mark-2*sp) + sp + mark, y);
    CGContextSetLineWidth(context, 4.0f);
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}
//计算度转弧度
static inline float radians(double degrees) {
    return degrees * M_PI / 180;
}

#pragma mark - lazy

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

@end
