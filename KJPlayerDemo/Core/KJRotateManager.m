//
//  KJRotateManager.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/23.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJRotateManager.h"
#import "KJBasePlayerView.h"
//旋转中间控制器
@interface KJRotateViewController : UIViewController
@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientationMask;
@end

@interface KJRotateManager ()
@property(nonatomic,strong,class)UIView *superView;
@property(nonatomic,assign,class)CGRect originalFrame;
@end
@implementation KJRotateManager
/* 切换到全屏 */
+ (void)kj_rotateFullScreenBasePlayerView:(KJBasePlayerView*)baseView{
    self.superView = baseView.superview;
    self.originalFrame = baseView.frame;
    CGRect rectInWindow = [baseView convertRect:baseView.bounds toView:PLAYER_KeyWindow];
    baseView.frame = rectInWindow;
    [baseView removeFromSuperview];
    [PLAYER_KeyWindow addSubview:baseView];
    id<KJPlayerRotateAppDelegate> delegate = (id<KJPlayerRotateAppDelegate>)[[UIApplication sharedApplication] delegate];
    NSAssert([delegate conformsToProtocol:@protocol(KJPlayerRotateAppDelegate)], @"Please see the usage documentation!!!");
    [delegate kj_transmitCurrentRotateOrientation:UIInterfaceOrientationMaskLandscape];
    
    KJRotateViewController *vc = [[KJRotateViewController alloc] init];
    vc.interfaceOrientationMask = UIInterfaceOrientationMaskLandscape;
    UIWindow *videoWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    videoWindow.rootViewController = vc;
    [UIView animateWithDuration:0.3f animations:^{
        baseView.transform = CGAffineTransformMakeRotation(M_PI_2);
        baseView.bounds = [UIScreen mainScreen].bounds;
        baseView.center = baseView.superview.center;
        baseView.isFullScreen = YES;
    } completion:^(BOOL finished) {
        id<KJPlayerRotateAppDelegate> delegate = (id<KJPlayerRotateAppDelegate>)[[UIApplication sharedApplication] delegate];
        [delegate kj_transmitCurrentRotateOrientation:UIInterfaceOrientationMaskPortrait];
    }];
}
/* 切换到小屏 */
+ (void)kj_rotateSmallScreenBasePlayerView:(KJBasePlayerView*)baseView{
    id<KJPlayerRotateAppDelegate> delegate = (id<KJPlayerRotateAppDelegate>)[[UIApplication sharedApplication] delegate];
    NSAssert([delegate conformsToProtocol:@protocol(KJPlayerRotateAppDelegate)], @"Please see the usage documentation!!!");
    [delegate kj_transmitCurrentRotateOrientation:UIInterfaceOrientationMaskPortrait];
    
    KJRotateViewController *vc = [[KJRotateViewController alloc] init];
    vc.interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
    UIWindow *videoWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    videoWindow.rootViewController = vc;
    [PLAYER_KeyWindow addSubview:baseView];
    [UIView animateWithDuration:0.3f animations:^{
        baseView.transform = CGAffineTransformIdentity;
        baseView.frame = self.originalFrame;
        baseView.isFullScreen = NO;
    } completion:^(BOOL finished) {
        [baseView removeFromSuperview];
        [self.superView addSubview:baseView];
    }];
}
/* 切换到浮窗屏 */
+ (void)kj_rotateFloatingWindowBasePlayerView:(KJBasePlayerView*)baseView{
    // TODO:
}

#pragma mark - getter/setter
static UIView *_superView = nil;
+ (UIView*)superView{
    return _superView;
}
+ (void)setSuperView:(UIView *)superView{
    _superView = superView;
}
static CGRect _originalFrame;
+ (CGRect)originalFrame{
    return _originalFrame;
}
+ (void)setOriginalFrame:(CGRect)originalFrame{
    _originalFrame = originalFrame;
}

@end

/* ************************* 黄金分割线 ***************************/

@implementation KJRotateViewController
/// 电池状态栏管理
- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (BOOL)shouldAutorotate{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return self.interfaceOrientationMask;
}

@end
