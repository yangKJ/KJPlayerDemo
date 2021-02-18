//
//  KJBasePlayerView.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  播放器视图基类，播放器控件父类

#import <UIKit/UIKit.h>
#import "KJPlayerType.h"
NS_ASSUME_NONNULL_BEGIN
/* 控件位置和大小发生改变信息通知 */
extern NSString *kPlayerBaseViewChangeNotification;
/* 缓存相关信息接收key */
extern NSString *kPlayerBaseViewChangeKey;
@interface KJBasePlayerView : UIImageView

@end

NS_ASSUME_NONNULL_END
