//
//  KJPlayerHintTextLayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  文本提示框

#import <QuartzCore/QuartzCore.h>
#import "KJPlayerType.h"
NS_ASSUME_NONNULL_BEGIN
static NSString * KJPlayerHintPositionTop = @"KJPlayerHintPositionTop";
static NSString * KJPlayerHintPositionCenter = @"KJPlayerHintPositionCenter";
static NSString * KJPlayerHintPositionBottom = @"KJPlayerHintPositionBottom";
static NSString * KJPlayerHintPositionLeftTop = @"KJPlayerHintPositionLeftTop";
static NSString * KJPlayerHintPositionRightTop = @"KJPlayerHintPositionRightTop";
static NSString * KJPlayerHintPositionLeftCenter = @"KJPlayerHintPositionLeftCenter";
static NSString * KJPlayerHintPositionRightCenter = @"KJPlayerHintPositionRightCenter";
static NSString * KJPlayerHintPositionLeftBottom = @"KJPlayerHintPositionLeftBottom";
static NSString * KJPlayerHintPositionRightBottom = @"KJPlayerHintPositionRightBottom";
@interface KJPlayerHintInfo : NSObject
@property (nonatomic,assign) CGFloat maxWidth;
@property (nonatomic,strong) UIColor *background;
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,strong) UIFont *font;
@end
@interface KJPlayerHintTextLayer : CALayer
@property (nonatomic,assign,readonly) CGFloat maxWidth;
/* 设置属性 */
- (void)kj_setFont:(UIFont*)font color:(UIColor*)color;
/* 显示文本框 */
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time max:(float)max position:(id)position playerView:(UIView*)playerView;

@end

NS_ASSUME_NONNULL_END
