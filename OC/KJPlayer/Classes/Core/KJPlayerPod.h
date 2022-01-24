//
//  KJPlayerPod.h
//  KJPlayer
//
//  Created by yangkejun on 2021/9/24.
//  https://github.com/yangKJ/KJPlayerDemo
//  组件化资源工具，使用Pod资源包

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJPlayerPod : NSObject

/// 使用字体图标资源，默认使用`KJPlayerFont.ttf`字体包
/// 关于如何制作并使用字体图标，https://juejin.cn/post/6932301573645139976
/// @param size 字体尺寸
+ (UIFont *)iconFontOfSize:(CGFloat)size;

/// 使用字体资源
/// @param fontName 字体包
/// @param size 字体尺寸
+ (UIFont *)iconFontWithName:(NSString *)fontName size:(CGFloat)size;

/// 使用图片资源
/// @param name 图片名
+ (UIImage *)imageNamed:(NSString *)name;

/// 使用图片资源
/// @param name 图片名
/// @param type 图片类型，可为空
+ (UIImage *)imageNamed:(NSString *)name ofType:(nullable NSString *)type;

@end

NS_ASSUME_NONNULL_END
