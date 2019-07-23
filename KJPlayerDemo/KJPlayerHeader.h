//
//  KJPlayerHeader.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//

#ifndef KJPlayerHeader_h
#define KJPlayerHeader_h

/** 作者信息
 *  Github地址：https://github.com/yangKJ
 *  简书地址：https://www.jianshu.com/u/c84c00476ab6
 *  博客地址：https://blog.csdn.net/qq_34534179
 
 ------------- 本人其他库 -------------
 播放器 - KJPlayer是一款视频播放器，AVPlayer的封装，继承UIView
 pod 'KJPlayer'  # 播放器功能区
 pod 'KJPlayer/KJPlayerView'  # 自带展示界面
 - 支持播放网络和本地视频、播放多种格式
 - 视频可以边下边播，把播放器播放过的数据流缓存到本地，下次直接从缓冲读取播放
 - 支持拖动、手势快进倒退、增大减小音量、重力感应切换横竖屏等等
 
 实用又方便的Category和一些自定义控件
 pod 'KJEmitterView'
 pod 'KJEmitterView/Function'#
 pod 'KJEmitterView/Control' # 自定义控件
 
 轮播图 - 支持缩放 多种pagecontrol 支持继承自定义样式 自带网络加载和缓存
 pod 'KJBannerView'  # 轮播图，网络图片加载
 
 菜单控件 - 下拉控件 选择控件
 pod 'KJMenuView' # 菜单控件
 
 加载Loading - 多种样式供选择
 pod 'KJLoadingAnimation' # 加载控件
 
 
 ####版本更新日志:
 
 #### Add 1.0.2
 1.完善 KJPlayerView 展示界面
 2.修改bug
 
 #### Add 1.0.0
 1.第一次提交项目

 */

/** 功能区
 *  支持播放网络和本地视频、播放多种格式
 *  视频可以边下边播，把播放器播放过的数据流缓存到本地
 *  下次直接优先从缓冲读取播放
 */
#import "KJPlayer.h"

#endif /* KJPlayerHeader_h */
