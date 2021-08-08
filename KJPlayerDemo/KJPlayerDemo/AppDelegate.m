//
//  AppDelegate.m
//  KJPlayerDemo
//
//  Created by 77。 on 2021/8/8.
//  https://github.com/yangKJ/KJPlayerDemo

#import "AppDelegate.h"
#if __has_include(<DoraemonKit/DoraemonManager.h>)
#import <DoraemonKit/DoraemonManager.h>
#endif
#import <KJPlayer/KJPlayerHeader.h>

@interface AppDelegate () <KJPlayerRotateAppDelegate>

@property(nonatomic,assign) UIInterfaceOrientationMask rotateOrientation;

@end

@implementation AppDelegate

#pragma mark - KJPlayerRotateAppDelegate

/// 传递当前旋转方向
- (void)kj_transmitCurrentRotateOrientation:(UIInterfaceOrientationMask)rotateOrientation{
    self.rotateOrientation = rotateOrientation;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (self.rotateOrientation) {
        return self.rotateOrientation;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSDictionary * dict = @{NSFontAttributeName: [UIFont systemFontOfSize:18]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:dict forState:UIControlStateNormal];
    
#ifdef DEBUG
    // DiDi开发工具，默认位置，解决遮挡关键区域减少频繁移动
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGPoint point = CGPointMake(size.width - 58, size.height - 83);
    [[DoraemonManager shareInstance] installWithStartingPosition:point];
#endif
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
