//
//  AppDelegate.m
//  KJPlayerDemo
//
//  Created by 77。 on 2021/8/8.
//  https://github.com/yangKJ/KJPlayerDemo

#import "AppDelegate.h"
#import <KJPlayer/KJPlayerHeader.h>
#import <KJPlayerDemo-Swift.h>

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
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
#ifdef DEBUG
    // SwiftMonkey随机测试工具
    [self initMonkey];
    // DIDI调试工具
    [[DoraemonManager shareInstance] installWithStartingPosition:CGPointMake(100, 200)];
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
