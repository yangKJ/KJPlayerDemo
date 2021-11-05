//
//  KJRotateManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/23.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  旋转管理，全屏半屏浮窗屏切换

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 必须在Appdelegate当中实现该协议 
@protocol KJPlayerRotateAppDelegate <NSObject>
@required;
/// 传递当前旋转方向
- (void)kj_transmitCurrentRotateOrientation:(UIInterfaceOrientationMask)rotateOrientation;

@end

@class KJBasePlayerView;
@interface KJRotateManager : NSObject

#pragma mark - 切换屏幕相关

/// 切换到全屏
+ (void)kj_rotateFullScreenBasePlayerView:(KJBasePlayerView *)baseView;
/// 切换到小屏 
+ (void)kj_rotateSmallScreenBasePlayerView:(KJBasePlayerView *)baseView;
/// 切换到浮窗屏 
+ (void)kj_rotateFloatingWindowBasePlayerView:(KJBasePlayerView *)baseView;
/// 旋转自动切换屏幕状态 
+ (void)kj_rotateAutoFullScreenBasePlayerView:(KJBasePlayerView *)baseView;

#pragma mark - 操作面板相关

/// 显示操作面板 
+ (void)kj_operationViewDisplayBasePlayerView:(KJBasePlayerView *)baseView;
/// 隐藏操作面板 
+ (void)kj_operationViewHiddenBasePlayerView:(KJBasePlayerView *)baseView;

@end

NS_ASSUME_NONNULL_END
