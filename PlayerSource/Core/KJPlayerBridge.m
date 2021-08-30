//
//  KJPlayerBridge.m
//  KJPlayer
//
//  Created by yangkejun on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerBridge.h"
#import "KJBasePlayer.h"

@interface KJPlayerBridge ()
/// 当前内核
@property (nonatomic, strong) __kindof KJBasePlayer * basePlayer;

@end

@implementation KJPlayerBridge

/// 初始化
/// @param basePlayer 当前内核
+ (instancetype)createBridgeWithBasePlayer:(__kindof KJBasePlayer *)basePlayer{
    @synchronized (self) {
        KJPlayerBridge * bridge = [[KJPlayerBridge alloc] init];
        bridge.basePlayer = basePlayer;
        return bridge;
    }
}

/// 万能回调响应方法
/// @param index 协定使用
/// @param withBlock 回调响应
- (void)kj_anyArgumentsIndex:(NSInteger)index withBlock:(KJPlayerAnyBlock)withBlock{
    switch (index) {
        case 0:{ // 视频截图
            id target = [[NSClassFromString(@"KJScreenshotsManager") alloc] init];
            SEL sel = NSSelectorFromString(@"kj_screenshotsIMP:object:otherObject:withBlock:");
            if ([target respondsToSelector:sel]) {
                IMP imp = [target methodForSelector:sel];
                void (* tempFunc)(id, SEL, __kindof KJBasePlayer *, id, id, KJPlayerAnyBlock) = (void *)imp;
                tempFunc(target, sel, self.basePlayer, self.anyObject, self.anyOtherObject, withBlock);
            } else {
                withBlock ? withBlock(nil) : nil;
            }
        } break;
        default:break;
    }
}

#pragma mark - imp method

/// 构建方法
/// @param method 方法名
- (void)kj_methodIMP:(NSString *)method{
    SEL sel = NSSelectorFromString(method);
    if ([self.basePlayer respondsToSelector:sel]) {
        IMP imp = [self.basePlayer methodForSelector:sel];
        void (* tempFunc)(id, SEL) = (void *)imp;
        tempFunc(self.basePlayer, sel);
    }
}

/// 构建一个需要返回bool类型方法
/// @param method 方法名
/// @return 返回布尔值
- (BOOL)kj_boolMethodIMP:(NSString *)method{
    SEL sel = NSSelectorFromString(method);
    if ([self.basePlayer respondsToSelector:sel]) {
        IMP imp = [self.basePlayer methodForSelector:sel];
        BOOL (* tempFunc)(id, SEL) = (void *)imp;
        return tempFunc(self.basePlayer, sel);
    }
    return NO;
}

/// 构建需传递一个参数方法
/// @param method 方法名
/// @param object 参数
/// @return 返回该方法处理之后的对象
- (id)kj_methodIMP:(NSString *)method object:(id)object{
    id tempObject = nil;
    SEL sel = NSSelectorFromString(method);
    if ([self.basePlayer respondsToSelector:sel]) {
        IMP imp = [self.basePlayer methodForSelector:sel];
        id (* tempFunc)(id, SEL, id) = (void *)imp;
        tempObject = tempFunc(self.basePlayer, sel, object);
    }
    return tempObject;
}

#pragma mark - bridge method

/// 播放器开始准备时刻并验证网址是否一致
- (BOOL)kj_verifyCacheWithVideoURL{
    // 缓存管理，`KJBasePlayer+KJCache`
    NSURL * __autoreleasing tempURL = [self kj_methodIMP:@"kj_cacheIMP:" object:(NSURL *)self.anyObject];
    
    return [((NSURL *)self.anyObject).absoluteString isEqualToString:tempURL.absoluteString];
}

/// 播放器状态改变
/// @param state 播放器状态
- (void)kj_changePlayerState:(KJPlayerState)state{
    void(^kMethodIMP)(NSString *) = ^(NSString * method){
        SEL sel = NSSelectorFromString(method);
        if ([self.basePlayer respondsToSelector:sel]) {
            IMP imp = [self.basePlayer methodForSelector:sel];
            void (* tempFunc)(id, SEL, KJPlayerState) = (void *)imp;
            tempFunc(self.basePlayer, sel, state);
        }
    };
    
    // 心跳相关操作，`KJBasePlayer+KJPingTimer`
    kMethodIMP(@"kj_pingTimerIMP:");
}

/// 开始播放时刻，准备功能处理
- (BOOL)kj_beginFunction{
    // 记录播放，`KJBasePlayer+KJRecordTime`
    if ([self kj_boolMethodIMP:@"kj_recordLastTimePlayIMP"]) {
        return YES;
    }
    // 跳过播放，`KJBasePlayer+KJSkipTime`
    if ([self kj_boolMethodIMP:@"kj_skipTimePlayIMP"]) {
        return YES;
    }
    return NO;
}

/// 播放中，功能处理
/// @param time 当前播放时间
- (BOOL)kj_playingFunction:(NSTimeInterval)time{
    BOOL(^kMethodIMP)(NSString *) = ^BOOL(NSString * method){
        SEL sel = NSSelectorFromString(method);
        if ([self.basePlayer respondsToSelector:sel]) {
            IMP imp = [self.basePlayer methodForSelector:sel];
            BOOL (* tempFunc)(id, SEL, NSTimeInterval) = (void *)imp;
            return tempFunc(self.basePlayer, sel, time);
        }
        return NO;
    };
    
    // 尝试观看，`KJBasePlayer+KJTryTime`
    if (kMethodIMP(@"kj_tryTimePlayIMP:")) {
        return YES;
    }
    return NO;
}

/// 内核销毁时刻
- (void)kj_playerDealloc{
    // 记录播放时间，`KJBasePlayer+KJRecordTime`
    [self kj_methodIMP:@"kj_recordTimeSaveIMP"];
}

/// 初始化时刻注册后台监听
/// @param monitoring 前后台监听
- (void)kj_initBackgroundMonitoring:(void(^)(BOOL isBackground, BOOL isPlaying))monitoring{
    SEL sel = NSSelectorFromString(@"kj_backgroundMonitoringIMP:");
    if ([self.basePlayer respondsToSelector:sel]) {
        IMP imp = [self.basePlayer methodForSelector:sel];
        void (* tempFunc)(id, SEL, void(^)(BOOL, BOOL)) = (void *)imp;
        tempFunc(self.basePlayer, sel, monitoring);
    }
}

@end
