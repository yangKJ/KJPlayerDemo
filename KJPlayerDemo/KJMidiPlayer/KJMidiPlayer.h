//
//  KJMidiPlayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/2.
//  Copyright © 2021 杨科军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KJPlayerPlayHandle.h"
#import "KJPlayerType.h"
NS_ASSUME_NONNULL_BEGIN

@interface KJMidiPlayer : NSObject<KJPlayerPlayHandle>
@property (nonatomic,assign,readonly) MusicPlayer musicPlayer;

@end

NS_ASSUME_NONNULL_END
