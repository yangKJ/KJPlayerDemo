//
//  KJBasePlayerView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayerView.h"
NSString *kPlayerBaseViewChangeNotification = @"kPlayerBaseViewNotification";
NSString *kPlayerBaseViewChangeKey = @"kPlayerBaseViewKey";
@implementation KJBasePlayerView
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}


#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"] || [keyPath isEqualToString:@"bounds"] || [keyPath isEqualToString:@"center"]){
        if ([object valueForKeyPath:keyPath] != [NSNull null]){
            [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerBaseViewChangeNotification object:self userInfo:@{kPlayerBaseViewChangeKey:[object valueForKeyPath:keyPath]}];
//            if (self.kBasePlayerViewFrameChanged) {
//                self.kBasePlayerViewFrameChanged(self, [[object valueForKeyPath:keyPath] CGRectValue]);
//            }
        }
    }
}

@end
