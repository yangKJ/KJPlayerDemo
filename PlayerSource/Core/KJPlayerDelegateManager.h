//
//  KJPlayerDelegateManager.h
//  KJPlayer
//
//  Created by yangkejun on 2021/9/16.
//  https://github.com/yangKJ/KJPlayerDemo
//  委托管理器

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 内核协议方法
struct KJPlayerDelegateAvailable {
    BOOL playerState; // 播放器状态
    BOOL playerCurrentTime; // 当前时间
    BOOL playerVideoTime; // 视频总时长
    BOOL playerLoadProgress; // 加载进度
    BOOL playerVideoSize; // 视频尺寸
    BOOL playerPlayFailed; // 播放错误
};
struct KJPlayerDataSourceAvailable {
    BOOL singleAndDoubleTap; // 单双击手势反馈
};
typedef struct KJPlayerDelegateAvailable KJPlayerDelegateAvailable;
typedef struct KJPlayerDataSourceAvailable KJPlayerDataSourceAvailable;
@protocol KJPlayerDelegate,KJPlayerBaseViewDelegate;
/// 委托管理器
@interface KJPlayerDelegateManager : NSObject

@property (nonatomic, weak) id<KJPlayerDelegate> delegate;
@property (nonatomic, weak) id<KJPlayerBaseViewDelegate> dataSource;

/// 内核壳子委托
/// @param block 回调方法
- (void)kj_performDelegateBlock:(void(^)(id<KJPlayerDelegate> delegate, KJPlayerDelegateAvailable available))block;

/// 基类控件委托
/// @param block 回调方法
- (void)kj_performDataSourceBlock:(void(^)(id<KJPlayerBaseViewDelegate> dataSource, KJPlayerDataSourceAvailable available))block;

@end

NS_ASSUME_NONNULL_END
