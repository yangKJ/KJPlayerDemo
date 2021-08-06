//
//  KJPlayerStatusLayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  自定义状态栏

#import <QuartzCore/QuartzCore.h>
#import "KJPlayerType.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,KJPlayerStatusBatteryState) {
    KJPlayerStatusBatteryStateNormal = 0,// 正常状态
    KJPlayerStatusBatteryStateCharging,  // 充电状态
};
typedef NS_ENUM(NSInteger,KJPlayerStatusTextStyle) {
    KJPlayerStatusTextStyleHide = 0,// 隐藏电量数字
    KJPlayerStatusTextStyleTop,     // 电量数字显示在顶部
    KJPlayerStatusTextStyleBottom,  // 电量数字显示在底部
};
@interface KJPlayerStatusLayer : CALayer
@property (nonatomic,assign) KJPlayerStatusBatteryState batteryState;
@property (nonatomic,assign) KJPlayerStatusTextStyle textStyle;
@property (nonatomic,assign) float percent;

@end

NS_ASSUME_NONNULL_END
