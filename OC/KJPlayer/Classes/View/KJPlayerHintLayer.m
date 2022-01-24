//
//  KJPlayerHintLayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerHintLayer.h"
#import "KJBasePlayerView.h"
#import "KJPlayerConst.h"

@interface KJPlayerHintLayer ()
@property (nonatomic,assign) KJPlayerVideoScreenState screenState;
@property (nonatomic,strong) CATextLayer *hintTextLayer;
@property (nonatomic,strong) UIColor *hintColor;
@property (nonatomic,strong) UIFont *hintFont;
@property (nonatomic,assign) CGFloat maxWidth;
/// 载体，外界kvc传入
@property (nonatomic,strong) KJBasePlayerView *hintSuperPlayerView;

@end

@implementation KJPlayerHintLayer

- (instancetype)init{
    if (self = [super init]) {
        self.cornerRadius = 7;
        self.maxWidth = 250;
        self.hintFont = [UIFont systemFontOfSize:16];
        self.hintColor = UIColor.whiteColor;
        self.zPosition = KJBasePlayerViewLayerZPositionLoading;
        [self addSublayer:self.hintTextLayer];
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.6].CGColor;
    }
    return self;
}
/// 设置属性或者修改属性
/// @param font 字体类型
/// @param textColor 字体颜色
/// @param background 背景颜色
/// @param maxWidth 最大宽度
- (void)kj_setHintFont:(UIFont *)font
             textColor:(UIColor *)textColor
            background:(UIColor *)background
              maxWidth:(CGFloat)maxWidth{
    if (font) {
        self.hintFont = font;
        self.hintTextLayer.font = (__bridge CFTypeRef _Nullable)(self.hintFont.fontName);
        self.hintTextLayer.fontSize = self.hintFont.pointSize;
    }
    if (textColor) {
        self.hintColor = textColor;
        self.hintTextLayer.foregroundColor = self.hintColor.CGColor;
    }
    if (background) {
        self.backgroundColor = background.CGColor;
    }
    self.maxWidth = maxWidth;
}

#pragma mark - hintText
/// 提示文字
- (void)kj_displayHintText:(id)text{
    [self kj_displayHintText:text max:self.maxWidth];
}
- (void)kj_displayHintText:(id)text max:(float)max{
    [self kj_displayHintText:text time:1.f max:max position:KJPlayerHintPositionCenter];
}
- (void)kj_displayHintText:(id)text position:(id)position{
    [self kj_displayHintText:text time:1.f position:position];
}
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time{
    [self kj_displayHintText:text time:time position:KJPlayerHintPositionCenter];
}
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time position:(id)position{
    [self kj_displayHintText:text time:time max:self.maxWidth position:position];
}
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time max:(float)max position:(id)position{
    kGCD_player_main(^{
        if (CGRectEqualToRect(CGRectZero, self.hintSuperPlayerView.frame)) {
            return;
        }
    });
    [self hintText:text max:max position:position];
    if (self.superlayer == nil) {
        [self.hintSuperPlayerView.layer addSublayer:self];
    }
    
    /// 先取消上次的延时执行
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(kj_hideHintText)
                                               object:nil];
    if (time) {
        [self performSelector:@selector(kj_hideHintText) withObject:nil afterDelay:time];
    }
}
/// 隐藏提示文字
- (void)kj_hideHintText{
    [self removeFromSuperlayer];
}

#pragma mark - private method

/// 显示文本框
/// @param text 文本
/// @param max 最大宽度
/// @param position 显示位置
- (void)hintText:(id)text max:(CGFloat)max position:(id)position {
    NSString * tempText;
    if ([text isKindOfClass:[NSAttributedString class]]) {
        tempText = [text string];
        if (tempText.length == 0) return;
        self.hintTextLayer.string = text;
    } else if ([text isKindOfClass:[NSString class]]) {
        if (((NSString*)text).length == 0) return;
        tempText = text;
        CGFloat lineHeight = self.hintTextLayer.fontSize;
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.maximumLineHeight = lineHeight;
        paragraphStyle.minimumLineHeight = lineHeight;
        NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        [attributes setValue:self.hintFont forKey:NSFontAttributeName];
        [attributes setValue:self.hintColor forKey:NSForegroundColorAttributeName];
        self.hintTextLayer.string = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    } else {
        return;
    }
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary * dict = @{
        NSFontAttributeName : [UIFont fontWithName:self.hintTextLayer.font size:self.hintTextLayer.fontSize]
    };
    CGSize size = [tempText boundingRectWithSize:CGSizeMake(max, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:dict
                                         context:nil].size;
    CGPoint point = CGPointZero;
    CGFloat padding = 20;
    if ([position isKindOfClass:[NSString class]]) {
        CGFloat w = size.width + padding + padding;
        CGFloat h = size.height + padding;
        CGFloat width  = self.hintSuperPlayerView.frame.size.width;
        CGFloat height = self.hintSuperPlayerView.frame.size.height;
        if (self.screenState == KJPlayerVideoScreenStateFullScreen) {
            CGFloat temp = width;
            width = height;
            height = temp;
        }
        if ([position caseInsensitiveCompare:KJPlayerHintPositionCenter] == NSOrderedSame) {
            point = CGPointMake((width-w)/2.f, (height-h)/2.f);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionBottom] == NSOrderedSame) {
            point = CGPointMake((width-w)/2.f, height-padding-h);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionTop] == NSOrderedSame) {
            point = CGPointMake((width-w)/2.f, padding);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionLeftBottom] == NSOrderedSame) {
            point = CGPointMake(padding, height-padding-h);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionRightBottom] == NSOrderedSame) {
            point = CGPointMake(width-w-padding, height-padding-h);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionLeftTop] == NSOrderedSame) {
            point = CGPointMake(padding, padding);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionRightTop] == NSOrderedSame) {
            point = CGPointMake(width-w-padding, padding);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionLeftCenter] == NSOrderedSame) {
            point = CGPointMake(padding, (height-h)/2.f);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionRightCenter] == NSOrderedSame) {
            point = CGPointMake(width-w-padding, (height-h)/2.f);
        }
    } else if ([position isKindOfClass:[NSValue class]]) {
        point = [position CGPointValue];
    } else {
        return;
    }
    self.hintTextLayer.frame = CGRectMake(padding*.5, padding*.5, size.width+padding, 1.5*size.height);
    self.frame = CGRectMake(point.x, point.y, size.width+padding+padding, size.height+padding+3);
}

#pragma mark - lazy

- (CATextLayer *)hintTextLayer{
    if (!_hintTextLayer) {
        _hintTextLayer = [CATextLayer layer];
        _hintTextLayer.font = (__bridge CFTypeRef _Nullable)(self.hintFont.fontName);
        _hintTextLayer.fontSize = self.hintFont.pointSize;
        _hintTextLayer.foregroundColor = self.hintColor.CGColor;
        _hintTextLayer.alignmentMode = kCAAlignmentCenter;
        _hintTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _hintTextLayer.wrapped = YES;
    }
    return _hintTextLayer;
}

@end
