//
//  KJPlayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  AVPlayer播放器内核

#import <Foundation/Foundation.h>
#import "KJBasePlayer.h"
NS_ASSUME_NONNULL_BEGIN
@interface KJPlayer : NSObject<KJBasePlayer>
@property (nonatomic,strong,readonly) AVPlayerLayer *playerLayer;
@property (nonatomic,strong,readonly) AVPlayerItem *playerItem;
@property (nonatomic,strong,readonly) AVPlayer *player;
@property (nonatomic,strong,readonly) AVURLAsset *asset;

@end

NS_ASSUME_NONNULL_END
