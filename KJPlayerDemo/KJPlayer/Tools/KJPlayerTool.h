//
//  KJPlayerTool.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/21.
//  Copyright © 2019 杨科军. All rights reserved.
//  播放器的相关工具

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#pragma mark ********** 3.弱引用   *********
#define PLAYER_WEAKSELF __weak typeof(self) weakself = self
@interface KJPlayerTool : NSObject

/// 判断是否含有视频轨道（判断视频是否可以正常播放）
+ (BOOL)kj_playerHaveTracksWithURL:(NSURL*)url;

/// 判断是否是URL
+ (BOOL)kj_playerIsURL:(NSURL*)url;

/// Block 同步执行 判断当前URL是否可用
+ (BOOL)kj_playerValidateUrl:(NSURL*)url;

/// MD5加密
+ (NSString*)kj_playerMD5WithString:(NSString*)string;

/// 根据 URL 得到完整路径
+ (NSString*)kj_playerGetIntegrityPathWithUrl:(NSURL*)url;

// 获取视频第一帧图片
+ (UIImage*)kj_playerFristImageWithURL:(NSURL*)url;
    
// 获取视频总时间
+ (NSInteger)kj_playerVideoTotalTimeWithURL:(NSURL*)url;

// 获取当前的旋转状态
+ (CGAffineTransform)kj_playerCurrentDeviceOrientation;

/// 设置时间显示
+ (NSString *)kj_playerConvertTime:(CGFloat)second;

@end

NS_ASSUME_NONNULL_END
