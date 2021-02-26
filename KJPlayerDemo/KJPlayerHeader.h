//
//  KJPlayerHeader.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#ifndef KJPlayerHeader_h
#define KJPlayerHeader_h
/*  作者信息
 *  Github地址：https://github.com/yangKJ
 *  简书地址：https://www.jianshu.com/u/c84c00476ab6
 *  博客地址：https://blog.csdn.net/qq_34534179
 *  掘金地址：https://juejin.cn/user/1987535102554472/posts
 *  邮箱地址：ykj310@126.com
 
 * 如果觉得好用,希望您能Star支持,你的 ⭐️ 是我持续更新的动力!
 *
 *********************************************************************************
 
### 功能区
* 支持音/视频播放，midi文件播放
* 支持在线播放/本地播放
* 支持后台播放，音频提取播放
* 支持视频边下边播，把播放器播放过的数据流缓存到本地
* 支持断点续载续播，下次直接优先从缓冲读取播放
* 支持缓存管理，清除时间段缓存
* 支持试看，自动跳过片头
* 支持记录上次播放时间
* 支持自动播放，自动连续播放
* 支持随机/重复/顺序播放
* 支持重力感应，全屏/半屏切换
* 支持基本手势操作，进度音量等
* 支持切换不同分辨率视频

### 文档信息介绍
* 全屏/半屏使用，https://github.com/yangKJ/KJPlayerDemo/blob/master/Document/旋转方案.md
* 边下边播边存方案，https://github.com/yangKJ/KJPlayerDemo/blob/master/Document/边下边播.md

* 备注：快捷打开浏览器命令，command + shift + 鼠标左键
**********************************************************************************/

/* ****************  AVPlayer内核  ****************/
#if __has_include(<KJPlayer/KJPlayer.h>)
#import <KJPlayer/KJPlayer.h>
#elif __has_include("KJPlayer.h")
#import "KJPlayer.h"
#else
#endif

/* ****************  MIDI内核  ****************/
#if __has_include(<KJPlayer/KJMidiPlayer.h>)
#import <KJPlayer/KJMidiPlayer.h>
#elif __has_include("KJMidiPlayer.h")
#import "KJMidiPlayer.h"
#else
#endif

#endif /* KJPlayerHeader_h */
