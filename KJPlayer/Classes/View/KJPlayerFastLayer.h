//
//  KJPlayerFastLayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  快进快退进度控件

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIkit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJPlayerFastLayer : CALayer

/// 主色调
@property (nonatomic,strong) UIColor *mainColor;
/// 副色调
@property (nonatomic,strong) UIColor *viceColor;

/// 设置数据
/// @param value 当前值
/// @param time 总时间
- (void)kj_updateFastValue:(CGFloat)value totalTime:(CGFloat)time;

@end

NS_ASSUME_NONNULL_END
