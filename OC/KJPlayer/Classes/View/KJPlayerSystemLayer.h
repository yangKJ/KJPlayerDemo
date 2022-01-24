//
//  KJPlayerSystemLayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  音量亮度系统控件

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIkit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJPlayerSystemLayer : CALayer

/// 主色调
@property (nonatomic,strong) UIColor *mainColor;
/// 副色调
@property (nonatomic,strong) UIColor *viceColor;
/// 是否为音量
@property (nonatomic,assign) BOOL isBrightness;
/// 当前值
@property (nonatomic,assign) float value;

@end

NS_ASSUME_NONNULL_END
