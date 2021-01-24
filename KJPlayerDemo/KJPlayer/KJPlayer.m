//
//  KJPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayer.h"

@implementation KJPlayer
static KJPlayer *_instance = nil;
static dispatch_once_t playerOnceToken;
+ (instancetype)kj_shareInstance{
    dispatch_once(&playerOnceToken, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}
/// 销毁单例
+ (void)kj_attempDealloc{
    playerOnceToken = 0;
    _instance = nil;
}

@end
