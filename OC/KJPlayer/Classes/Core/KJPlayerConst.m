//
//  KJPlayerConst.m
//  KJPlayer
//
//  Created by 77。 on 2021/9/3.
//  https://github.com/yangKJ/KJPlayerDemo

#ifndef __KJPlayerConst__M__
#define __KJPlayerConst__M__

#import <CommonCrypto/CommonDigest.h>
#import "KJPlayerType.h"

/// 缓存相关信息通知
NSNotificationName const kPlayerFileHandleInfoNotification = @"kPlayerFileHandleInfoNotification";
/// 缓存相关信息接收key
NSNotificationName const kPlayerFileHandleInfoKey = @"kPlayerFileHandleInfoKey";
/// 错误信息CODE通知
NSNotificationName const kPlayerErrorCodeNotification = @"kPlayerErrorCodeNotification";
/// 错误信息CODE接收key
NSNotificationName const kPlayerErrorCodekey = @"kPlayerErrorCodekey";
/// 错误信息通知
NSNotificationName const kPlayerErrorNotification = @"kPlayerErrorNotification";
/// 错误信息接收key
NSNotificationName const kPlayerErrorkey = @"kPlayerErrorkey";
/// 控件位置和大小发生改变信息通知
NSNotificationName const kPlayerBaseViewChangeNotification = @"kPlayerBaseViewNotification";
/// 控件位置和大小发生改变key
NSNotificationName const kPlayerBaseViewChangeKey = @"kPlayerBaseViewKey";

// 子线程
void kGCD_player_async(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    } else {
        dispatch_async(queue, block);
    }
}
// 主线程
void kGCD_player_main(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    } else if ([[NSThread currentThread] isMainThread]) {
        dispatch_async(queue, block);
    } else {
        dispatch_sync(queue, block);
    }
}
/// 根据链接获取Asset类型
KJPlayerAssetType kPlayerVideoAesstType(NSURL * videoURL){
    if (videoURL == nil) return KJPlayerAssetTypeNONE;
    if (videoURL.pathExtension.length) {
        if ([videoURL.pathExtension containsString:@"m3u8"] ||
            [videoURL.pathExtension containsString:@"ts"]) {
            return KJPlayerAssetTypeHLS;
        } else {
            return KJPlayerAssetTypeFILE;
        }
    }
    NSArray * array = [videoURL.path componentsSeparatedByString:@"."];
    if (array.count == 0) {
        return KJPlayerAssetTypeNONE;
    } else if ([array.lastObject containsString:@"m3u8"] ||
               [array.lastObject containsString:@"ts"]) {
        return KJPlayerAssetTypeHLS;
    } else {
        return KJPlayerAssetTypeFILE;
    }
}
// 网址转义，中文空格字符解码
NSURL * kPlayerURLCharacters(NSString * urlString){
    NSString * encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [NSURL URLWithString:encodedString];
}
// 哈西加密
NSString * kPlayerSHA512String(NSString * string){
    const char * cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData * data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
    return [NSString stringWithString:output];
}
// 文件名
NSString * kPlayerIntactName(NSURL * url){
    return kPlayerSHA512String(url.resourceSpecifier ?: url.absoluteString);
}
// 设置时间显示
NSString * kPlayerConvertTime(CGFloat second){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    if (second / 3600 >= 1) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    } else {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:second]];
}
// 隐士调用
void kPlayerPerformSel(id target, NSString * selName){
    SEL sel = NSSelectorFromString(selName);
    if ([target respondsToSelector:sel]) {
        IMP imp = [target methodForSelector:sel];
        void (* tempFunc)(id target, SEL) = (void *)imp;
        tempFunc(target, sel);
    }
}

#endif
