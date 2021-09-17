//
//  KJPlayerDelegateManager.m
//  KJPlayer
//
//  Created by yangkejun on 2021/9/16.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerDelegateManager.h"
#import "KJPlayerProtocol.h"

@interface KJPlayerDelegateManager ()

@property (nonatomic, strong, readonly) dispatch_queue_t accessQueue;
@property (atomic, assign, readwrite) KJPlayerDelegateAvailable delegateMethod;
@property (atomic, assign, readwrite) KJPlayerDataSourceAvailable dataSourceMethod;

@end

@implementation KJPlayerDelegateManager
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

- (instancetype)init{
    if (self = [super init]) {
        _accessQueue = dispatch_queue_create("ykj.player.access", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (id<KJPlayerDelegate>)delegate{
    __block id<KJPlayerDelegate> delegate = nil;
    dispatch_sync(self.accessQueue, ^{
        delegate = self->_delegate;
    });
    return delegate;
}
- (void)setDelegate:(id<KJPlayerDelegate>)delegate{
    dispatch_barrier_async(self.accessQueue, ^{
        self->_delegate = delegate;
        self.delegateMethod = (KJPlayerDelegateAvailable) {
            .playerState = [delegate respondsToSelector:@selector(kj_player:state:)],
        };
    });
}

- (id<KJPlayerBaseViewDelegate>)dataSource{
    __block id<KJPlayerBaseViewDelegate> dataSource = nil;
    dispatch_sync(self.accessQueue, ^{
        dataSource = self->_dataSource;
    });
    return dataSource;
}
- (void)setDataSource:(id<KJPlayerBaseViewDelegate>)dataSource{
    dispatch_barrier_async(self.accessQueue, ^{
        self->_dataSource = dataSource;
        self.dataSourceMethod = (KJPlayerDataSourceAvailable) {
            .singleAndDoubleTap = [dataSource respondsToSelector:@selector(kj_basePlayerView:isSingleTap:)],
        };
    });
}

/// 内核壳子委托
/// @param block 回调方法
- (void)kj_performDelegateBlock:(void(^)(id<KJPlayerDelegate>, KJPlayerDelegateAvailable))block{
    __block __strong id<KJPlayerDelegate> delegate = nil;
    __block KJPlayerDelegateAvailable availableMethods = {};
    dispatch_sync(self.accessQueue, ^{
        delegate = self->_delegate;
        availableMethods = self.delegateMethod;
    });
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        block(delegate, availableMethods);
    }];
}

/// 基类控件委托
/// @param block 回调方法
- (void)kj_performDataSourceBlock:(void(^)(id<KJPlayerBaseViewDelegate>, KJPlayerDataSourceAvailable))block{
    __block __strong id<KJPlayerBaseViewDelegate> dataSource = nil;
    __block KJPlayerDataSourceAvailable availableMethods = {};
    dispatch_sync(self.accessQueue, ^{
        dataSource = self->_dataSource;
        availableMethods = self.dataSourceMethod;
    });
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        block(dataSource, availableMethods);
    }];
}

@end
