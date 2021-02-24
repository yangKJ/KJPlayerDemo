//
//  KJPlayerLoadingLayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  加载动画

#import <QuartzCore/QuartzCore.h>
#import "KJPlayerType.h"
NS_ASSUME_NONNULL_BEGIN

@interface KJPlayerLoadingLayer : CAShapeLayer
@property (nonatomic,assign) KJPlayerVideoScreenState screenState;
/* 圆圈加载动画 */
- (void)kj_setAnimationSize:(CGSize)size color:(UIColor*)color;
/// 重置尺寸
- (void)kj_setLayerNewFrame:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
