//
//  KJPlayerConst.h
//  KJPlayer
//
//  Created by 77。 on 2021/9/3.
//  https://github.com/yangKJ/KJPlayerDemo
//  常量和常用方法汇总

#ifndef __KJPlayerConst__H__
#define __KJPlayerConst__H__

#import <Foundation/Foundation.h>
#import "KJPlayerType.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - constant notification

/// 缓存相关信息通知
UIKIT_EXTERN NSNotificationName const kPlayerFileHandleInfoNotification;
/// 缓存相关信息接收key
UIKIT_EXTERN NSNotificationName const kPlayerFileHandleInfoKey;
/// 错误信息CODE通知
UIKIT_EXTERN NSNotificationName const kPlayerErrorCodeNotification;
/// 错误信息CODE接收key
UIKIT_EXTERN NSNotificationName const kPlayerErrorCodekey;
/// 错误信息通知
UIKIT_EXTERN NSNotificationName const kPlayerErrorNotification;
/// 错误信息接收key
UIKIT_EXTERN NSNotificationName const kPlayerErrorkey;
/// 控件位置和大小发生改变信息通知
UIKIT_EXTERN NSNotificationName const kPlayerBaseViewChangeNotification;
/// 控件位置和大小发生改变key
UIKIT_EXTERN NSNotificationName const kPlayerBaseViewChangeKey;

#pragma mark - function method

/// 子线程
/// @param block 回调方法
extern void kGCD_player_async(dispatch_block_t _Nonnull block);

/// 主线程
/// @param block 回调方法
extern void kGCD_player_main(dispatch_block_t _Nonnull block);

/// 根据链接获取Asset类型
/// @param videoURL 链接地址
extern KJPlayerAssetType kPlayerVideoAesstType(NSURL * videoURL);

/// 网址转义，中文空格字符解码
/// @param urlString 视频地址
extern NSURL * kPlayerURLCharacters(NSString * urlString);

/// 哈希加密
/// @param string 加密内容
extern NSString * kPlayerSHA512String(NSString * string);

/// 文件名
/// @param url 视频链接
extern NSString * kPlayerIntactName(NSURL * url);

/// 设置时间显示
/// @param second 时间
extern NSString * kPlayerConvertTime(CGFloat second);

/// 隐士调用
/// @param target 实例
/// @param selName 方法名
extern void kPlayerPerformSel(id target, NSString * selName);

NS_ASSUME_NONNULL_END

#endif
