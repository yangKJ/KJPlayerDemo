//
//  KJPlayerViewModel.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/24.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerViewModel.h"

@implementation KJPlayerViewModel
- (instancetype)init{
    if (self = [super init]) {
        /// 默认标清，无则流畅，再无则高清
        self.priorityType = KJPlayerViewModelPriorityTypeCIF;
    }
    return self;
}
@end
