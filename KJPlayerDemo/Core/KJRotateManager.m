//
//  KJRotateManager.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/23.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJRotateManager.h"
#define kRotate_KeyWindow \
({UIWindow *window;\
if (@available(iOS 13.0, *)) {\
window = [UIApplication sharedApplication].windows.firstObject;\
}else{\
window = [UIApplication sharedApplication].keyWindow;\
}\
window;})
//旋转中间控制器
@interface KJRotateViewController : UIViewController
@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientationMask;
@end
@implementation KJRotateViewController
- (BOOL)shouldAutorotate{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return self.interfaceOrientationMask;
}
@end

/* ************************* 黄金分割线 ***************************/

@interface KJRotateManager ()
@property(nonatomic,assign,class)CGRect originalFrame;
@property(nonatomic,strong,class)UIColor *superViewColor;
@end
@implementation KJRotateManager
/* 切换到全屏 */
+ (void)kj_rotateFullScreenBasePlayerView:(UIView*)baseView{
    self.originalFrame = baseView.frame;
    self.superViewColor = baseView.superview.backgroundColor;
    baseView.superview.backgroundColor = UIColor.blackColor;
    baseView.layer.zPosition = 1;
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
        [baseView setValue:@(YES) forKey:@"isFullScreen"];
    } completion:^(BOOL finished) {
        id<KJPlayerRotateAppDelegate> delegate = (id<KJPlayerRotateAppDelegate>)[[UIApplication sharedApplication] delegate];
        [delegate kj_transmitCurrentRotateOrientation:UIInterfaceOrientationMaskPortrait];
    }];
}
/* 切换到小屏 */
+ (void)kj_rotateSmallScreenBasePlayerView:(UIView*)baseView{
    baseView.superview.backgroundColor = self.superViewColor;
    baseView.layer.zPosition = 0;
    _superViewColor = nil;
    id<KJPlayerRotateAppDelegate> delegate = (id<KJPlayerRotateAppDelegate>)[[UIApplication sharedApplication] delegate];
    NSAssert([delegate conformsToProtocol:@protocol(KJPlayerRotateAppDelegate)], @"Please see the usage documentation!!!");
    [delegate kj_transmitCurrentRotateOrientation:UIInterfaceOrientationMaskPortrait];
    
    KJRotateViewController *vc = [[KJRotateViewController alloc] init];
    vc.interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
    UIWindow *videoWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    videoWindow.rootViewController = vc;
    baseView.transform = CGAffineTransformIdentity;
    baseView.frame = self.originalFrame;
    [baseView setValue:@(NO) forKey:@"isFullScreen"];
}
/* 切换到浮窗屏 */
+ (void)kj_rotateFloatingWindowBasePlayerView:(UIView*)baseView{
    // TODO:
}

#pragma mark - getter/setter
static CGRect _originalFrame;
+ (CGRect)originalFrame{
    return _originalFrame;
}
+ (void)setOriginalFrame:(CGRect)originalFrame{
    _originalFrame = originalFrame;
}
static UIColor *_superViewColor = nil;
+ (UIColor *)superViewColor{
    return _superViewColor;
}
+ (void)setSuperViewColor:(UIColor *)superViewColor{
    _superViewColor = superViewColor;
}
+ (UIViewController*)topViewController{
    UIViewController *result = nil;
    UIWindow * window = kRotate_KeyWindow;
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    if ([vc isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)vc;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        result = nav.childViewControllers.lastObject;
    }else if ([vc isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)vc;
        result = nav.childViewControllers.lastObject;
    }else{
        result = vc;
    }
    return result;
}

@end
