//
//  KJPlayerHintTextLayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerHintTextLayer.h"

@interface KJPlayerHintTextLayer()
@property (nonatomic,strong) CATextLayer *hintTextLayer;
@property (nonatomic,strong) UIColor *hintTextColor;
@property (nonatomic,strong) UIFont *hintFont;
@end
@implementation KJPlayerHintTextLayer
- (instancetype)init{
    if (self = [super init]) {
        self.cornerRadius = 7;
        self.zPosition = KJBasePlayerViewLayerZPositionLoading;
    }
    return self;
}
/* 设置属性 */
- (void)kj_setFont:(UIFont*)font color:(UIColor*)color{
    self.hintFont = font;
    self.hintTextColor = color;
    CATextLayer * textLayer = [CATextLayer layer];
    textLayer.font = (__bridge CFTypeRef _Nullable)(font.fontName);
    textLayer.fontSize = font.pointSize;
    textLayer.foregroundColor = color.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.wrapped = YES;
    self.hintTextLayer = textLayer;
    [self addSublayer:textLayer];
}

/* 显示文本框 */
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time max:(float)max position:(id)position playerView:(UIView*)playerView{
    NSString *tempText;
    if ([text isKindOfClass:[NSAttributedString class]]){
        tempText = [text string];
        if (tempText.length == 0) return;
        self.hintTextLayer.string = text;
    }else if ([text isKindOfClass:[NSString class]]){
        if (((NSString*)text).length == 0) return;
        tempText = text;
        CGFloat lineHeight = self.hintTextLayer.fontSize;
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.maximumLineHeight = lineHeight;
        paragraphStyle.minimumLineHeight = lineHeight;
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        [attributes setValue:self.hintFont forKey:NSFontAttributeName];
        [attributes setValue:self.hintTextColor forKey:NSForegroundColorAttributeName];
        self.hintTextLayer.string = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }else{
        return;
    }
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont fontWithName:self.hintTextLayer.font size:self.hintTextLayer.fontSize]};
    CGSize size = [tempText boundingRectWithSize:CGSizeMake(max, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    CGPoint point = CGPointZero;
    CGFloat padding = 20;
    if ([position isKindOfClass:[NSString class]]) {
        CGFloat w = size.width + padding + padding;
        CGFloat h = size.height + padding;
        CGFloat w2 = playerView.frame.size.width;
        CGFloat h2 = playerView.frame.size.height;
        if ([position caseInsensitiveCompare:KJPlayerHintPositionCenter] == NSOrderedSame) {
            point = CGPointMake((w2-w)/2.f, (h2-h)/2.f);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionBottom] == NSOrderedSame) {
            point = CGPointMake((w2-w)/2.f, h2-padding-h);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionTop] == NSOrderedSame) {
            point = CGPointMake((w2-w)/2.f, padding);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionLeftBottom] == NSOrderedSame) {
            point = CGPointMake(padding, h2-padding-h);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionRightBottom] == NSOrderedSame) {
            point = CGPointMake(w2-w-padding, h2-padding-h);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionLeftTop] == NSOrderedSame) {
            point = CGPointMake(padding, padding);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionRightTop] == NSOrderedSame) {
            point = CGPointMake(w2-w-padding, padding);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionLeftCenter] == NSOrderedSame) {
            point = CGPointMake(padding, (h2-h)/2.f);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionRightCenter] == NSOrderedSame) {
            point = CGPointMake(w2-w-padding, (h2-h)/2.f);
        }
    }else if ([position isKindOfClass:[NSValue class]]) {
        point = [position CGPointValue];
    }else{
        return;
    }
    self.hintTextLayer.frame = CGRectMake(padding*.5, padding*.5, size.width+padding, 1.5*size.height);
    self.frame = CGRectMake(point.x, point.y, size.width+padding+padding, size.height+padding+3);
}

@end
