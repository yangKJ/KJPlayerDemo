//
//  KJGCDTimer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/23.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJGCDTimer.h"

@interface KJGCDTimer ()
@property(nonatomic,strong,class)NSMutableDictionary *timers;
@end

@implementation KJGCDTimer
void kGCD_player_async(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        dispatch_async(queue, block);
    }
}
void kGCD_player_main(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        if ([[NSThread currentThread] isMainThread]) {
            dispatch_async(queue, block);
        }else{
            dispatch_sync(queue, block);
        }
    }
}
dispatch_semaphore_t semaphore_;
+ (NSString *)kj_createTimerWithTask:(void(^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async{
    if (!task || start < 0 || (interval <= 0 && repeats)) return nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        semaphore_ = dispatch_semaphore_create(1);
    });
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    NSString *name = [NSString stringWithFormat:@"kPlayer%zd", self.timers.count];
    self.timers[name] = timer;
    dispatch_semaphore_signal(semaphore_);
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeats) [self kj_cancelTimer:name];
    });
    dispatch_resume(timer);
    return name;
}

+ (NSString *)kj_createTimerWithTarget:(id)target selector:(SEL)selector start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async{
    if (!target || !selector) return nil;
    return [self kj_createTimerWithTask:^{
        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selector];
#pragma clang diagnostic pop
        }
    } start:start interval:interval repeats:repeats async:async];
}

+ (void)kj_cancelTimer:(NSString *)name{
    if (name.length == 0) return;
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = self.timers[name];
    if (timer) {
        dispatch_source_cancel(timer);
        [_timers removeObjectForKey:name];
    }
    dispatch_semaphore_signal(semaphore_);
}
+ (void)kj_pauseTimer:(NSString *)name{
    if (name.length == 0) return;
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = self.timers[name];
    if (timer) {
        dispatch_suspend(timer);
    }
    dispatch_semaphore_signal(semaphore_);
}
+ (void)kj_resumeTimer:(NSString *)name{
    if (name.length == 0) return;
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = self.timers[name];
    if (timer) {
        dispatch_resume(timer);
    }
    dispatch_semaphore_signal(semaphore_);
}

#pragma mark - getter/setter
static NSMutableDictionary *_timers;
+ (NSMutableDictionary*)timers{
    if (_timers == nil) {
        _timers = [NSMutableDictionary dictionary];
    }
    return _timers;
}
+ (void)setTimers:(NSMutableDictionary*)timers{
    _timers = timers;
}

@end
