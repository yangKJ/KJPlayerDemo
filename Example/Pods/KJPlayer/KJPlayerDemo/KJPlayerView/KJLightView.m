//
//  KJLightView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/23.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJLightView.h"
#import "KJPlayerViewConfiguration.h"

@implementation KJLightView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        [self kSetUI];
        //        //设置屏幕常亮
        //        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    return self;
}

- (void)kSetUI{
    self.backgroundColor = UIColor.redColor;
//    self.effectView.frame = self.bounds;
}
- (CGFloat)touchBeginLightValue{
    return [UIScreen mainScreen].brightness; /// 当前亮度
}
- (void)setChangeLightValue:(BOOL)changeLightValue{
    _changeLightValue = changeLightValue;
    if (changeLightValue) {
        [UIView animateWithDuration:0.3 animations:^{
            self.hidden = !changeLightValue;
        }];
    }else{
        self.hidden = !changeLightValue;
    }
}
/// 设置数据
- (void)kj_updateLightValue:(CGFloat)value{
    /// 判断控制一下, 不能超出 0~1
    value = MAX(0, value);
    value = MIN(value, 1);
    /// 改变屏幕亮度
    [UIScreen mainScreen].brightness = value;
//    if (value>0) {
//        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//            self.effectView.alpha = 0.0;
//        } completion:nil];
//    }else{
//        self.effectView.alpha = 1.0;
//    }
}

@end
