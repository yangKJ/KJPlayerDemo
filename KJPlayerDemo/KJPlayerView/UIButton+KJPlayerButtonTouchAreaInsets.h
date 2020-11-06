//
//  UIButton+KJPlayerButtonTouchAreaInsets.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2020/1/6.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  改变UIButton的响应区域 - 扩大Button点击域

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (KJPlayerButtonTouchAreaInsets)
/// 设置按钮额外热区 - 扩大按钮点击域
@property (nonatomic, assign) UIEdgeInsets touchAreaInsets;

@end

NS_ASSUME_NONNULL_END
