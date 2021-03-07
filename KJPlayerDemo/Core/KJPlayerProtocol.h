//
//  KJPlayerProtocol.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/3/1.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  播放器委托协议相关

#import "KJPlayerType.h"

/// 播放相关委托代理
@class KJBasePlayer;
@protocol KJPlayerDelegate <NSObject>
@optional;
/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state;
/* 播放进度 */
- (void)kj_player:(KJBasePlayer*)player currentTime:(NSTimeInterval)time;
/* 缓存进度 */
- (void)kj_player:(KJBasePlayer*)player loadProgress:(CGFloat)progress;
/* 播放错误 */
- (void)kj_player:(KJBasePlayer*)player playFailed:(NSError*)failed;

@end

/// 控件相关委托代理
@class KJBasePlayerView,KJPlayerButton;
@protocol KJPlayerBaseViewDelegate <NSObject>
@optional;
/* 单双击手势反馈 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view isSingleTap:(BOOL)tap;
/* 长按手势反馈 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view longPress:(UILongPressGestureRecognizer*)longPress;
/* 进度手势反馈，不替换UI请返回当前时间和总时间，范围-1 ～ 1 */
- (NSArray*)kj_basePlayerView:(KJBasePlayerView*)view progress:(float)progress end:(BOOL)end;
/* 音量手势反馈，是否替换自带UI，范围0 ～ 1 */
- (BOOL)kj_basePlayerView:(KJBasePlayerView*)view volumeValue:(float)value;
/* 亮度手势反馈，是否替换自带UI，范围0 ～ 1 */
- (BOOL)kj_basePlayerView:(KJBasePlayerView*)view brightnessValue:(float)value;
/* 是否锁屏，根据KJPlayerButton的type来确定当前按钮类型 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view PlayerButton:(KJPlayerButton*)button;

@end
