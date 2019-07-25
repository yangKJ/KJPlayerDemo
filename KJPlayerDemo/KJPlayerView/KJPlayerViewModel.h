//
//  KJPlayerViewModel.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/24.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJPlayerViewModel : NSObject

@property(nonatomic,strong) NSString *name; /// 标题
@property(nonatomic,strong) NSString *coverIamge; /// 封面标题

/***************** 视频清晰度相关 *****************/
@property(nonatomic,strong) NSString *fluencyDefinition; /// 流畅
@property(nonatomic,strong) NSString *standardDefinition;/// 标清
@property(nonatomic,strong) NSString *highDefinition; /// 高清
@property(nonatomic,strong) NSString *superDefinition;/// 超清 720
@property(nonatomic,strong) NSString *HDDefinition; /// 1080

@end

NS_ASSUME_NONNULL_END
