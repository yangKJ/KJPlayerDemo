//
//  KJPlayerHintLayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  文本提示框

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIkit.h>

NS_ASSUME_NONNULL_BEGIN
/// 显示位置，支持自定义Point
static NSString * KJPlayerHintPositionTop         = @"KJPlayerHintPositionTop";
static NSString * KJPlayerHintPositionCenter      = @"KJPlayerHintPositionCenter";
static NSString * KJPlayerHintPositionBottom      = @"KJPlayerHintPositionBottom";
static NSString * KJPlayerHintPositionLeftTop     = @"KJPlayerHintPositionLeftTop";
static NSString * KJPlayerHintPositionRightTop    = @"KJPlayerHintPositionRightTop";
static NSString * KJPlayerHintPositionLeftCenter  = @"KJPlayerHintPositionLeftCenter";
static NSString * KJPlayerHintPositionRightCenter = @"KJPlayerHintPositionRightCenter";
static NSString * KJPlayerHintPositionLeftBottom  = @"KJPlayerHintPositionLeftBottom";
static NSString * KJPlayerHintPositionRightBottom = @"KJPlayerHintPositionRightBottom";

@interface KJPlayerHintLayer : CALayer

/// 设置属性或者修改属性
/// @param font 字体类型，默认16号字体
/// @param textColor 字体颜色，默认白色
/// @param background 背景颜色，默认黑色透明度0.6
/// @param maxWidth 最大宽度，默认250px
- (void)kj_setHintFont:(nullable UIFont *)font
             textColor:(nullable UIColor *)textColor
            background:(nullable UIColor *)background
              maxWidth:(CGFloat)maxWidth;

/// 支持富文本提示的文本框
/// @param text 提示内容，支持富文本
- (void)kj_displayHintText:(id)text;

/// 支持富文本提示的文本框
/// @param text 提示内容，支持富文本
/// @param max 最大宽度
- (void)kj_displayHintText:(id)text max:(float)max;

/// 支持富文本提示的文本框
/// @param text 提示内容，支持富文本
/// @param position 显示位置，支持自定义Point
- (void)kj_displayHintText:(id)text position:(id)position;

/// 支持富文本提示的文本框
/// @param text 提示内容，支持富文本
/// @param time 展示时间，零秒表示不自动消失
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time;

/// 支持富文本提示的文本框
/// @param text 提示内容，支持富文本
/// @param time 展示时间，零秒表示不自动消失
/// @param position 显示位置，支持自定义Point
- (void)kj_displayHintText:(id)text
                      time:(NSTimeInterval)time
                  position:(id)position;

/// 支持富文本提示的文本框
/// @param text 提示内容，支持富文本
/// @param time 展示时间，零秒表示不自动消失
/// @param max 最大宽度
/// @param position 显示位置，支持自定义Point
- (void)kj_displayHintText:(id)text
                      time:(NSTimeInterval)time
                       max:(float)max
                  position:(id)position;

/// 隐藏提示文字文本框
- (void)kj_hideHintText;

@end

NS_ASSUME_NONNULL_END
