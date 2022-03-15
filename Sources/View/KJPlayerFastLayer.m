//
//  KJPlayerFastLayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerFastLayer.h"
#import "KJPlayerConst.h"

@interface KJPlayerFastLayer ()
@property(nonatomic,strong)CATextLayer *textLayer;
@property(nonatomic,assign)float value;
@property(nonatomic,assign)float time;

@end

@implementation KJPlayerFastLayer

- (instancetype)init{
    if (self = [super init]) {
        self.cornerRadius = 7;
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8].CGColor;
        self.zPosition = KJBasePlayerViewLayerZPositionDisplayLayer;
        [self addSublayer:self.textLayer];
//        self.shouldRasterize = YES;
    }
    return self;
}
/// 设置数据
- (void)kj_updateFastValue:(CGFloat)value totalTime:(CGFloat)time{
    self.value = MIN(MAX(0, value), time);
    self.time = time;
    self.textLayer.string = [NSString stringWithFormat:@"%@ / %@", kPlayerConvertTime(self.value), kPlayerConvertTime(self.time)];
    [self setNeedsDisplay];
}

#pragma mark - draw

- (void)drawInContext:(CGContextRef)context{
    CGFloat width = self.frame.size.width;
    CGFloat y = self.frame.size.height / 4 * 3;
    CGFloat sp = width/8.0;
    UIGraphicsPushContext(context);
    
    CGContextSetStrokeColorWithColor(context, self.mainColor.CGColor);
    CGContextMoveToPoint(context, sp, y);
    CGContextAddLineToPoint(context, width-sp, y);
    CGContextSetLineWidth(context, 3.5f);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, self.viceColor.CGColor);
    CGContextMoveToPoint(context, sp, y);
    CGContextAddLineToPoint(context, self.value/self.time*(width-2*sp) + sp, y);
    CGContextSetLineWidth(context, 4.0f);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}

#pragma mark - lazy

- (CATextLayer *)textLayer{
    if (!_textLayer) {
        CATextLayer *layer = [CATextLayer layer];
        layer.fontSize = 14;
        layer.contentsScale = [UIScreen mainScreen].scale;
        layer.font = (__bridge CFTypeRef)(@"HiraKakuProN-W3");
        layer.alignmentMode = @"center";
        _textLayer = layer;
    }
    return _textLayer;
}

@end
