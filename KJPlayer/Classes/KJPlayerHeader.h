//
//  KJPlayerHeader.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#ifndef KJPlayerHeader_h
#define KJPlayerHeader_h

/* ****************  视图控件UI  ****************/
#if __has_include(<KJPlayer/KJBasePlayerView.h>)
#import <KJPlayer/KJBasePlayerView.h>
#elif __has_include("KJBasePlayerView.h")
#import "KJBasePlayerView.h"
#else
#endif

/* ****************  AVPlayer内核  ****************/
#if __has_include(<KJPlayer/KJAVPlayer.h>)
#import <KJPlayer/KJAVPlayer.h>
#elif __has_include("KJAVPlayer.h")
#import "KJAVPlayer.h"
#else
#endif

/* ****************  AVPlayer内核边下边播边缓存分支  ****************/
#if __has_include(<KJPlayer/KJAVPlayer+KJCache.h>)
#import <KJPlayer/KJAVPlayer+KJCache.h>
#elif __has_include("KJAVPlayer+KJCache.h")
#import "KJAVPlayer+KJCache.h"
#else
#endif

/* ****************  MIDI内核  ****************/
#if __has_include(<KJPlayer/KJMIDIPlayer.h>)
#import <KJPlayer/KJMIDIPlayer.h>
#elif __has_include("KJMIDIPlayer.h")
#import "KJMIDIPlayer.h"
#else
#endif

/* ****************  IJKPlayer内核  ****************/
#if __has_include(<KJPlayer/KJIJKPlayer.h>)
#import <KJPlayer/KJIJKPlayer.h>
#elif __has_include("KJIJKPlayer.h")
#import "KJIJKPlayer.h"
#else
#endif

#endif /* KJPlayerHeader_h */
/*  作者信息
 *  Github地址：https://github.com/yangKJ
 *  简书地址：https://www.jianshu.com/u/c84c00476ab6
 *  博客地址：https://blog.csdn.net/qq_34534179
 *  掘金地址：https://juejin.cn/user/1987535102554472/posts
 *  邮箱地址：ykj310@126.com
 
 * 如果觉得好用,希望您能STAR支持,你的 ⭐️ 是我持续更新的动力!
 *
 *********************************************************************************
 
### 功能区
**动态切换内核，支持边下边播的播放器方案**

* 支持音/视频播放，midi文件播放
* 支持在线播放/本地播放
* 支持后台播放，音频提取播放
* 支持视频边下边播，分片下载播放存储
* 支持断点续载续播，下次直接优先从缓冲读取播放
* 支持缓存管理，清除时间段缓存
* 支持试看，自动跳过片头片尾
* 支持记录上次播放时间
* 支持自动播放，自动连续播放
* 支持随机/重复/顺序播放
* 支持重力感应，全屏/半屏切换
* 支持基本手势操作，进度音量等
* 支持锁定屏幕
* 长按快进快退等操作
* 支持切换不同分辨率视频
* 支持直播流媒体播放
* 持续更新ing...

### 模块使用方案
pod 'KJPlayer' # 播放器功能区
pod 'KJPlayer/AVPlayer # AVPlayer内核和下载分支
pod 'KJPlayer/AVPlayer/AVCore' # AVPlayer内核播放器
pod 'KJPlayer/MIDI' # MIDI内核
pod 'KJPlayer/IJKPlayer' # IJKPlayer内核
 
AVPlaye内核扩展功能
pod 'KJPlayer/AVPlayer/AVDownloader' # 边播边下边存分支
pod 'KJPlayer/RecordTime' # 记忆播放
pod 'KJPlayer/TryTime' # 尝鲜播放
pod 'KJPlayer/SkipTime' # 跳过片头片尾
pod 'KJPlayer/Cache' # 缓存板块
pod 'KJPlayer/Screenshots' # 视频截屏板块
pod 'KJPlayer/BackgroundMonitoring' # 前后台播放

### 文档信息介绍
* 更新日志文档，https://github.com/yangKJ/KJPlayerDemo/blob/master/CHANGELOG.md
* 全屏/半屏使用，https://github.com/yangKJ/KJPlayerDemo/blob/master/Document/旋转方案.md
* 边下边播边存方案，https://github.com/yangKJ/KJPlayerDemo/blob/master/Document/边下边播.md

* 备注：快捷打开浏览器命令，command + shift + 鼠标左键
**********************************************************************************/
