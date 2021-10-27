//
//  KJPlayerStatusLayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerStatusLayer.h"
@interface KJPlayerStatusLayer (){
    CGFloat lineWidth;
    CGFloat widthEdge;
}
@end

@implementation KJPlayerStatusLayer
- (instancetype)init{
    if (self = [super init]) {
        lineWidth = self.frame.size.width/50;
        widthEdge = self.frame.size.width/50;
        self.zPosition = KJBasePlayerViewLayerZPositionDisplayLayer;
    }
    return self;
}
#pragma mark - draw
- (void)drawInContext:(CGContextRef)ctx{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    UIColor *lineColor = PLAYER_UIColorFromHEXA(0x666666,1);
    UIColor *fillColor = PLAYER_UIColorFromHEXA(0x666666,1);
    UIColor *borderColor = PLAYER_UIColorFromHEXA(0xAAAAAA,1);
    CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    //外框
    float offsetY;
    if (_textStyle == KJPlayerStatusTextStyleTop) {
        offsetY = height/20;
    }else if (_textStyle == KJPlayerStatusTextStyleBottom) {
        offsetY = -height/20;
    } else {
        offsetY = 0;
    }
    //外框高度
    float heightY = width/2.5;
    CGContextAddRoundRect(ctx, CGRectMake(widthEdge, height * 0.5 - (width/2.5)/2 + offsetY, width * 0.9 - widthEdge,heightY), kCGPathStroke, widthEdge * 2);
    
    //电池头
    CGContextAddRoundRect(ctx, CGRectMake(width * 0.9, height /2 - (width/6)/2 + offsetY, width * 0.08 - widthEdge, width/6), kCGPathFillStroke, widthEdge);
    if (_percent > 0.75) {
        fillColor = PLAYER_UIColorFromHEXA(0x49a6f6,0.8);
    }else if (_percent <= 0.75 && _percent > 0.5) {
        fillColor = PLAYER_UIColorFromHEXA(0x89d146,0.8);//绿色
    }else if (_percent <= 0.5 && _percent > 0.8) {
        fillColor = PLAYER_UIColorFromHEXA(0xFFBA57,0.8);//橙黄色
    }else {
        fillColor = PLAYER_UIColorFromHEXA(0xF25E5E,0.8);//红色
    }
    CGContextSetStrokeColorWithColor(ctx, fillColor.CGColor);
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    CGContextSetLineWidth(ctx, 0);
    //内矩形
    float innerHeight = width/2.5 - widthEdge * 2 - lineWidth*2;
    float innerWidth = (width * 0.9 - widthEdge - widthEdge * 2 - lineWidth * 2) * _percent;
    float innercornerRadius = MIN(innerWidth * 0.5, widthEdge * 2);
    CGContextAddRoundRect(ctx, CGRectMake(widthEdge + lineWidth + widthEdge, height * 0.5 - (width/2.5 - widthEdge * 2)/2 + widthEdge + offsetY, innerWidth, innerHeight), kCGPathFillStroke, innercornerRadius);

    //闪电
    if(_batteryState == 1) {
        UIColor *aColor = fillColor;
        UIColor *alineColor = borderColor;
        CGContextSetLineJoin(ctx, kCGLineJoinMiter);
        CGContextSetLineWidth(ctx, lineWidth/2);
        CGContextSetStrokeColorWithColor(ctx, alineColor.CGColor);
        CGContextSetFillColorWithColor(ctx, aColor.CGColor);
        CGContextMoveToPoint(ctx,width/2 + widthEdge * 2 - widthEdge,height * 0.5 - (width/2.5 - widthEdge * 2)/2 + widthEdge + offsetY);
        CGContextAddLineToPoint(ctx, width/2 - widthEdge*4 - widthEdge, height/2  + widthEdge + offsetY);
        CGContextAddLineToPoint(ctx, width/2 - widthEdge, height/2 + widthEdge + offsetY);
        CGContextAddLineToPoint(ctx, width/2 - widthEdge* 2 - widthEdge, height * 0.5 + (width/2.5 - widthEdge * 2)/2 - widthEdge + offsetY);
        CGContextAddLineToPoint(ctx, width/2 + widthEdge * 4 - widthEdge, height/2 - widthEdge + offsetY);
        CGContextAddLineToPoint(ctx, width/2 - widthEdge, height * 0.5 - widthEdge + offsetY);
        CGContextClosePath(ctx);
        CGContextDrawPath(ctx, kCGPathFillStroke);
    }
    
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    NSString *string = [NSString stringWithFormat:@"%0.0f%%",_percent * 100];
    float textHeight = width/4;
    UIFont *font = [UIFont fontWithName:@"Arial" size:textHeight];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    CGRect iRect = CGRectZero;
    if (_textStyle == KJPlayerStatusTextStyleTop) {
        iRect = CGRectMake(0, height/2 + offsetY - heightY/2 - textHeight - lineWidth, width, textHeight);
    }else if (_textStyle == KJPlayerStatusTextStyleTop) {
        iRect = CGRectMake(0, height/2 + offsetY + heightY/2, width, textHeight);
    } else {
        iRect = CGRectMake(0, height/2 + offsetY - heightY/2, width, textHeight);
    }
    NSDictionary *dict = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:fillColor};
    [string drawInRect:iRect withAttributes:dict];
}

void CGContextAddRoundRect(CGContextRef context,CGRect rect,CGPathDrawingMode mode,CGFloat radius){
    float x1=rect.origin.x;
    float y1=rect.origin.y;
    float x2=x1+rect.size.width;
    float y2=y1;
    float x3=x2;
    float y3=y1+rect.size.height;
    float x4=x1;
    float y4=y3;
    CGContextMoveToPoint(context, x1, y1+radius);
    CGContextAddArcToPoint(context, x1, y1, x1+radius, y1, radius);
    
    CGContextAddArcToPoint(context, x2, y2, x2, y2+radius, radius);
    CGContextAddArcToPoint(context, x3, y3, x3-radius, y3, radius);
    CGContextAddArcToPoint(context, x4, y4, x4, y4-radius, radius);
    
    CGContextClosePath(context);
    CGContextDrawPath(context, mode);
}

#pragma mark - getter/setter
- (void)setPercent:(float)percent {
    _percent = percent;
    [self setNeedsDisplay];
}
- (void)setTextStyle:(KJPlayerStatusTextStyle)textStyle {
    _textStyle = textStyle;
    [self setNeedsDisplay];
}
- (void)setBatteryState:(KJPlayerStatusBatteryState)batteryState {
    _batteryState = batteryState;
    [self setNeedsDisplay];
}


@end
