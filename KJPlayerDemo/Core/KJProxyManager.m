//
//  KJProxyManager.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/23.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJProxyManager.h"
@interface KJProxyManager ()
@property(nonatomic,weak)id target;/// 消息转发的对象
@end

@implementation KJProxyManager
+ (instancetype)kj_proxyWithTarget:(id)target{
    KJProxyManager *proxy = [KJProxyManager alloc];
    proxy.target = target;
    return proxy;
}
- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel{
    if (self.target) {
        return [self.target methodSignatureForSelector:sel];
    }else{
        return [super methodSignatureForSelector:sel];
    }
}
- (void)forwardInvocation:(NSInvocation*)invocation{
    SEL sel = [invocation selector];
    if ([self.target respondsToSelector:sel]) {
        [invocation invokeWithTarget:self.target];
    }
}
- (BOOL)respondsToSelector:(SEL)aSelector{
    return [self.target respondsToSelector:aSelector];
}

@end
