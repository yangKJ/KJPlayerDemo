//
//  KJPlayerPod.m
//  KJPlayer
//
//  Created by yangkejun on 2021/9/24.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerPod.h"
#import <CoreText/CTFontManager.h>

@implementation KJPlayerPod

/// 使用字体图标资源，默认使用`KJPlayerFont.ttf`字体包
/// 关于如何制作并使用字体图标，https://juejin.cn/post/6932301573645139976
/// @param size 字体尺寸
+ (UIFont *)iconFontOfSize:(CGFloat)size{
    return [self iconFontWithName:@"KJPlayerFont" size:size];
}

/// 使用字体资源
/// @param fontName 字体包
/// @param size 字体尺寸
+ (UIFont *)iconFontWithName:(NSString *)fontName size:(CGFloat)size{
    UIFont *font = [UIFont fontWithName:fontName size:size];
    if (font == nil) {
        [self dynamicallyLoadFontNamed:fontName];
        font = [UIFont fontWithName:fontName size:size];
        if (font == nil) font = [UIFont systemFontOfSize:size];
    }
    return font;
}

/// 加载字体资源
/// @param fontfileName 字体资源包名
+ (void)dynamicallyLoadFontNamed:(NSString *)fontfileName{
    NSBundle * bundle = [self acquireBundle];
    fontfileName = [fontfileName stringByAppendingString:@".ttf"];
    NSString *resourcePath = [NSString stringWithFormat:@"%@/%@",bundle.bundlePath,fontfileName];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:resourcePath]];
    if (data) {
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);
    }
}

/// 使用图片资源
/// @param name 图片名
+ (UIImage *)imageNamed:(NSString *)name{
    return [self imageNamed:name ofType:nil];
}

/// 使用图片资源
/// @param name 图片名
/// @param type 图片类型，可为空
+ (UIImage *)imageNamed:(NSString *)name ofType:(nullable NSString *)type{
    NSBundle * bundle = [self acquireBundle];
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:type]];
    }
}

+ (NSBundle *)acquireBundle{
    NSString *mainBundlePath = [NSBundle mainBundle].bundlePath;
    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",mainBundlePath,@"KJPlayer.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    if (bundle == nil) {
        bundlePath = [NSString stringWithFormat:@"%@/%@",
                      mainBundlePath, @"Frameworks/KJPlayer.framework/KJPlayer.bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    return bundle;
}

@end
