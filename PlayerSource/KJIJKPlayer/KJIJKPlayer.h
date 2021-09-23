//
//  KJIJKPlayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/3/1.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  IJKPlayer播放器内核

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

@class IJKFFOptions;
@class IJKFFMoviePlayerController;
@interface KJIJKPlayer : KJBasePlayer

#if __has_include(<IJKMediaFramework/IJKMediaFramework.h>)

@property (nonatomic,strong,readonly) IJKFFMoviePlayerController *player;
@property (nonatomic,strong,readonly) IJKFFOptions *options;

#endif

@end

NS_ASSUME_NONNULL_END
