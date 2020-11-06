//
//  KJPlayerViewModel.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/24.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger,KJPlayerViewModelPriorityType) {
    KJPlayerViewModelPriorityTypeSD  = 0, //流畅
    KJPlayerViewModelPriorityTypeCIF = 1, //标清
    KJPlayerViewModelPriorityTypeHD  = 2, //高清
};
static NSString * const _Nonnull KJPlayerViewModelPriorityTypeStringMap[] = {
    [KJPlayerViewModelPriorityTypeSD]  = @"流畅",
    [KJPlayerViewModelPriorityTypeCIF] = @"标清",
    [KJPlayerViewModelPriorityTypeHD]  = @"高清",
};

@interface KJPlayerViewModel : NSObject
@property(nonatomic,strong) NSString *name; /// 标题
@property(nonatomic,strong) NSString *coverIamge; /// 封面标题

/// 优先播放视频类型 默认标清，无则流畅，再无则高清
@property(nonatomic,assign) KJPlayerViewModelPriorityType priorityType;

/* *************** 视频清晰度相关 *****************/
@property(nonatomic,strong) NSString *sd; /// 流畅
@property(nonatomic,strong) NSString *cif;/// 标清
@property(nonatomic,strong) NSString *hd; /// 高清

@end

NS_ASSUME_NONNULL_END
