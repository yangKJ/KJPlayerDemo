//
//  KJPlayerSystemLayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  音量亮度系统控件

#import "KJBasePlayerLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJPlayerSystemLayer : KJBasePlayerLayer
@property(nonatomic,assign)BOOL isBrightness;
@property(nonatomic,assign)float value;

@end

NS_ASSUME_NONNULL_END
