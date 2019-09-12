//
//  KJLightView.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/23.
//  Copyright © 2019 杨科军. All rights reserved.
//  亮度View

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJLightView : UIView
/** 给显示亮度的view添加毛玻璃效果 */
@property (nonatomic,strong) UIVisualEffectView *effectView;

//记录触摸开始亮度
@property (nonatomic,assign) CGFloat touchBeginLightValue;
//是否改变亮度
@property (nonatomic,assign) BOOL changeLightValue;

/// 设置数据
- (void)kj_updateLightValue:(CGFloat)value;


@end

NS_ASSUME_NONNULL_END
