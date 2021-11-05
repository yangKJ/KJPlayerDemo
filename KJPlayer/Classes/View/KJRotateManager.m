//
//  KJRotateManager.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/23.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJRotateManager.h"
#import "KJBasePlayerView.h"

#define kRotate_KeyWindow \
({UIWindow *window;\
if (@available(iOS 13.0, *)) {\
window = [UIApplication sharedApplication].windows.firstObject;\
} else {\
window = [UIApplication sharedApplication].keyWindow;\
}\
window;})

/// 旋转中间控制器
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

// ************************* 黄金分割线 **************************

@interface KJRotateManager ()
@property(nonatomic,assign,class)UIView *tempView;
@property(nonatomic,assign,class)CGRect originalFrame;
@property(nonatomic,strong,class)UIColor *superViewColor;

@end

@implementation KJRotateManager

/// 切换到全屏 
+ (void)kj_rotateFullScreenBasePlayerView:(KJBasePlayerView *)baseView{
    self.originalFrame = baseView.frame;
    self.superViewColor = baseView.superview.backgroundColor;
    baseView.superview.backgroundColor = UIColor.blackColor;
    baseView.layer.zPosition = 1;
    if (self.tempView.superview == nil) {
        [baseView.superview addSubview:self.tempView];
    }
    [baseView.superview bringSubviewToFront:baseView];
    id<KJPlayerRotateAppDelegate> delegate = (id<KJPlayerRotateAppDelegate>)[[UIApplication sharedApplication] delegate];
    NSAssert([delegate conformsToProtocol:@protocol(KJPlayerRotateAppDelegate)], @"Please see the usage documentation!!!");
    [delegate kj_transmitCurrentRotateOrientation:UIInterfaceOrientationMaskLandscape];

    KJRotateViewController *vc = [[KJRotateViewController alloc] init];
    vc.interfaceOrientationMask = UIInterfaceOrientationMaskLandscape;
    UIWindow *videoWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    videoWindow.rootViewController = vc;

    [UIView animateWithDuration:0.3f animations:^{
        baseView.transform = kPlayerDeviceOrientation();
        baseView.bounds = [UIScreen mainScreen].bounds;
        baseView.center = baseView.superview.center;
        baseView.isFullScreen = YES;
    } completion:^(BOOL finished) {
        id<KJPlayerRotateAppDelegate> delegate = (id<KJPlayerRotateAppDelegate>)[[UIApplication sharedApplication] delegate];
        [delegate kj_transmitCurrentRotateOrientation:UIInterfaceOrientationMaskPortrait];
    }];
}
/// 切换到小屏 
+ (void)kj_rotateSmallScreenBasePlayerView:(KJBasePlayerView *)baseView{
    [self.tempView removeFromSuperview];
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
    
    [UIView animateWithDuration:0.3f animations:^{
        baseView.transform = kPlayerDeviceOrientation();
        baseView.frame = self.originalFrame;
        baseView.isFullScreen = NO;
    } completion:^(BOOL finished) {
        
    }];
}
/// 切换到浮窗屏 
+ (void)kj_rotateFloatingWindowBasePlayerView:(KJBasePlayerView *)baseView{
    // TODO:
}
/// 旋转自动切换屏幕状态 
+ (void)kj_rotateAutoFullScreenBasePlayerView:(KJBasePlayerView *)baseView{
    if (baseView.lockButton.isLocked) return;
    switch ((UIInterfaceOrientation)[UIDevice currentDevice].orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            baseView.isFullScreen = NO;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            if (baseView.isFullScreen) {
                [UIView animateWithDuration:0.5f animations:^{
                    baseView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                }];
            } else {
                baseView.isFullScreen = YES;
            }
            break;
        case UIInterfaceOrientationLandscapeRight:
            if (baseView.isFullScreen) {
                [UIView animateWithDuration:0.5f animations:^{
                    baseView.transform = CGAffineTransformMakeRotation(M_PI_2);
                }];
            } else {
                baseView.isFullScreen = YES;
            }
            break;
        default:
            break;
    }
}

#pragma mark - 操作面板相关

/// 显示操作面板 
+ (void)kj_operationViewDisplayBasePlayerView:(KJBasePlayerView *)baseView{
    baseView.topView.alpha = 0;
    baseView.bottomView.alpha = 0;
    [UIView animateWithDuration:0.3f animations:^{
        baseView.topView.alpha = 1;
        baseView.bottomView.alpha = 1;
        baseView.topView.hidden = NO;
        baseView.bottomView.hidden = NO;
        baseView.lockButton.hidden = NO;
        if (baseView.screenState == KJPlayerVideoScreenStateFullScreen) {
            baseView.backButton.hidden = baseView.fullScreenHiddenBackButton;
        } else if (baseView.smallScreenHiddenBackButton == NO) {
            baseView.backButton.hidden = NO;
        }
    } completion:^(BOOL finished) {
        if (baseView.autoHideTime) {
            [baseView.class cancelPreviousPerformRequestsWithTarget:baseView
                                                           selector:@selector(kj_hiddenOperationView)
                                                             object:nil];
            [baseView performSelector:@selector(kj_hiddenOperationView)
                           withObject:nil
                           afterDelay:baseView.autoHideTime];
        }
    }];
}
/// 隐藏操作面板 
+ (void)kj_operationViewHiddenBasePlayerView:(KJBasePlayerView *)baseView{
//    CGFloat y1 = self.topView.frame.origin.y;
//    CGFloat y2 = self.bottomView.frame.origin.y;
    [UIView animateWithDuration:0.5f animations:^{
//        if (self.screenState == KJPlayerVideoScreenStateFullScreen) {
//            self.topView.frame = CGRectMake(self.topView.frame.origin.x, -self.topView.frame.size.height, self.topView.frame.size.width, self.topView.frame.size.height);
//            self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, y2+self.bottomView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
//        } else {
        baseView.topView.hidden = YES;
        baseView.bottomView.hidden = YES;
        baseView.lockButton.hidden = YES;
        if (baseView.screenState == KJPlayerVideoScreenStateFullScreen) {
            baseView.backButton.hidden = baseView.isHiddenBackButton;
        }else if (baseView.smallScreenHiddenBackButton) {
            baseView.backButton.hidden = YES;
        }
//        }
    } completion:^(BOOL finished) {
//        if (self.screenState == KJPlayerVideoScreenStateFullScreen) {
//            self.topView.hidden = YES;
//            self.bottomView.hidden = YES;
//        }
//        self.topView.frame = CGRectMake(self.topView.frame.origin.x, y1, self.topView.frame.size.width, self.topView.frame.size.height);
//        self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, y2, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
    }];
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
static UIView *_tempView = nil;
+ (UIView *)tempView{
    if (!_tempView) {
        _tempView = [UIView new];
        _tempView.backgroundColor = UIColor.blackColor;
        _tempView.frame = [UIScreen mainScreen].bounds;
        _tempView.layer.zPosition = 0;
    }
    return _tempView;
}
+ (void)setTempView:(UIView *)tempView{
    _tempView = tempView;
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
    } else {
        result = vc;
    }
    return result;
}
// 获取当前的旋转状态
NS_INLINE CGAffineTransform kPlayerDeviceOrientation(void){
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    }else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

@end
