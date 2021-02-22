//
//  KJBasePlayerLayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/21.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayerLayer.h"

@implementation KJBasePlayerLayer
- (instancetype)init{
    if (self = [super init]) {
        self.cornerRadius = 7;
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8].CGColor;
        self.zPosition = KJBasePlayerViewLayerZPositionThird;
    }
    return self;
}
/// 重置Layer
- (void)kj_setLayerNewFrame:(CGRect)rect{
    self.frame = rect;
//    self.position = CGPointMake(self.position.y, self.position.x);
}

@end
