//
//  KJPlayerFastLayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  快进快退进度控件

#import <QuartzCore/QuartzCore.h>
#import "KJPlayerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJPlayerFastLayer : CALayer
@property (nonatomic,strong) UIColor *mainColor;
@property (nonatomic,strong) UIColor *viceColor;
/// 设置数据
- (void)kj_updateFastValue:(CGFloat)value TotalTime:(CGFloat)time;

@end

NS_ASSUME_NONNULL_END
