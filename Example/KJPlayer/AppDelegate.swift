//
//  AppDelegate.swift
//  KJPlayer
//
//  Created by 77。 on 2021/8/8.
//  https://github.com/yangKJ/KJPlayerDemo

import UIKit
import KJPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

// MARK: KJPlayerRotateAppDelegate
extension AppDelegate: KJPlayerRotateAppDelegate {
    
    static var orientationKey: String = "orientationKey"
    public var orientation: UIInterfaceOrientationMask? {
        get {
            return objc_getAssociatedObject(self, &AppDelegate.orientationKey) as? UIInterfaceOrientationMask
        }
        set {
            objc_setAssociatedObject(self, &AppDelegate.orientationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 当前屏幕方向响应
    /// - Parameter rotateOrientation: 屏幕方向
    func kj_transmitCurrentRotateOrientation(_ rotateOrientation: UIInterfaceOrientationMask) {
        self.orientation = rotateOrientation
    }
    
    /// 屏幕方向响应
    /// - Parameters:
    ///   - application: 应用程序
    ///   - window: 窗口
    /// - Returns: 当前屏幕方向
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard (self.orientation != nil) else {
            return .portrait
        }
        return self.orientation!
    }
    
}
