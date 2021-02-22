//
//  KJPlayerFastLayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  快进快退进度控件

#import "KJBasePlayerLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJPlayerFastLayer : KJBasePlayerLayer
/// 设置数据
- (void)kj_updateFastValue:(CGFloat)value TotalTime:(CGFloat)time;

@end

NS_ASSUME_NONNULL_END
