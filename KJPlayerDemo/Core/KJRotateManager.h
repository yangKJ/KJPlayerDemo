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
/* 必须在Appdelegate当中实现该协议 */
@protocol KJPlayerRotateAppDelegate <NSObject>
/* 传递当前旋转方向 */
- (void)kj_transmitCurrentRotateOrientation:(UIInterfaceOrientationMask)rotateOrientation;
@end

@interface KJRotateManager : NSObject
/* 切换到全屏 */
+ (void)kj_rotateFullScreenBasePlayerView:(UIView*)baseView;
/* 切换到小屏 */
+ (void)kj_rotateSmallScreenBasePlayerView:(UIView*)baseView;
/* 切换到浮窗屏 */
+ (void)kj_rotateFloatingWindowBasePlayerView:(UIView*)baseView;

@end

NS_ASSUME_NONNULL_END
