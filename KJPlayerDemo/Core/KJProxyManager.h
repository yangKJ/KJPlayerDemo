//
//  KJProxyManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/23.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  解决强引用问题

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJProxyManager : NSProxy
/// 解决强引用问题
+ (instancetype)kj_proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
