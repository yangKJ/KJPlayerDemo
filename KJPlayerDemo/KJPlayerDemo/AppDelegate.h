//
//  AppDelegate.h
//  KJPlayerDemo
//
//  Created by 77。 on 2021/8/8.
//  https://github.com/yangKJ/KJPlayerDemo

#import <UIKit/UIKit.h>
#ifdef DEBUG
#import <SwiftMonkeyPaws/SwiftMonkeyPaws-Swift.h>
#endif

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#ifdef DEBUG
@property (nonatomic, strong) MonkeyPaws *monkeyPaws;
#endif

@end

