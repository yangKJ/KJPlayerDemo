//
//  KJBasePlayerLayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  Layer控件基类

#import <QuartzCore/QuartzCore.h>
#import "KJPlayerType.h"
NS_ASSUME_NONNULL_BEGIN

@interface KJBasePlayerLayer : CALayer
@property(nonatomic,strong)UIColor *mainColor;
/// 重置Layer
- (void)kj_setLayerNewFrame:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
