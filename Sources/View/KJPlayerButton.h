//
//  KJPlayerButton.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import <UIKit/UIKit.h>
#import "KJRotateManager.h"

NS_ASSUME_NONNULL_BEGIN
/// 按钮类型
typedef NS_ENUM(NSUInteger, KJPlayerButtonType) {
    KJPlayerButtonTypeBack = 0,/// 返回按钮
    KJPlayerButtonTypeLock = 1,/// 锁屏按钮
    KJPlayerButtonTypeCenterPlay = 2,/// 中间播放按钮
};
/// 播放按钮状态
typedef NS_ENUM(NSUInteger, KJPlayerPlayButtonType) {
    KJPlayerPlayButtonTypePlaying,/// 播放中
    KJPlayerPlayButtonTypePausing,/// 暂停
    KJPlayerPlayButtonTypeReplay, /// 播放结束，重播
};
@interface KJPlayerButton : UIButton

/// 主色调
@property (nonatomic,strong) UIColor *mainColor;
/// 按钮类型 
@property (nonatomic,assign) KJPlayerButtonType type;
/// 中间播放按钮状态
@property (nonatomic,assign) KJPlayerPlayButtonType playType;
/// 是否为锁屏状态
@property (nonatomic,assign) BOOL isLocked;
/// 隐藏锁屏按钮 
- (void)kj_hiddenLockButton;

@end

NS_ASSUME_NONNULL_END
