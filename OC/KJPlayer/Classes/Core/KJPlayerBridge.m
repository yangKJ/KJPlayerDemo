//
//  KJPlayerBridge.m
//  KJPlayer
//
//  Created by yangkejun on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerBridge.h"
#import "KJBasePlayer.h"

@implementation KJPlayerBridge

/// 万能回调响应方法
/// @param index 协定使用
/// @param withBlock 回调响应
- (void)kj_anyArgumentsIndex:(NSInteger)index withBlock:(KJPlayerAnyBlock)withBlock{
    __kindof KJBasePlayer * basePlayer = self.kAcceptBasePlayer();
    switch (index) {
        case 520:{ // 视频截图，`KJScreenshotsManager`
            id target = [[NSClassFromString(@"KJScreenshotsManager") alloc] init];
            SEL sel = NSSelectorFromString(@"kj_screenshotsIMP:object:otherObject:withBlock:");
            if ([target respondsToSelector:sel]) {
                IMP imp = [target methodForSelector:sel];
                void (* tempFunc)(id, SEL, __kindof KJBasePlayer *, id, id, KJPlayerAnyBlock) = (void *)imp;
                tempFunc(target, sel, basePlayer, self.anyObject, self.anyOtherObject, withBlock);
            } else {
                withBlock ? withBlock(nil) : nil;
            }
        } break;
        case 521:{ // 存储缓存数据，`KJBasePlayer+KJCache`
            SEL sel = NSSelectorFromString(@"kj_saveCacheIMP:otherObject:withBlock:");
            if ([basePlayer respondsToSelector:sel]) {
                IMP imp = [basePlayer methodForSelector:sel];
                void (* tempFunc)(id, SEL, id, id, KJPlayerAnyBlock) = (void *)imp;
                tempFunc(basePlayer, sel, self.anyObject, self.anyOtherObject, withBlock);
            }
        } break;
        default:break;
    }
}

/// 万能读取开关信息
/// @param index 协定使用
/// @return 返回读取开关信息
- (bool)kj_readStatus:(NSInteger)index{
    __kindof KJBasePlayer * basePlayer = self.kAcceptBasePlayer();
    bool(^kRead)(NSString *) = ^bool(NSString * method){
        SEL sel = NSSelectorFromString(method);
        if ([basePlayer respondsToSelector:sel]) {
            IMP imp = [basePlayer methodForSelector:sel];
            bool (* tempFunc)(id, SEL) = (void *)imp;
            return tempFunc(basePlayer, sel);
        }
        return false;
    };
    bool read = false;
    switch (index) {
        case 520: // 读取是否开启缓存资源，`KJBasePlayer+KJCache`
            read = kRead(@"kj_readCacheIMP");
            break;
        case 521: // 读取是否为本地资源，`KJBasePlayer+KJCache`
            read = kRead(@"kj_readLocalityIMP");
            break;
        default:break;
    }
    return read;
}

#pragma mark - imp method

/// 构建方法
/// @param method 方法名
- (void)kj_methodIMP:(NSString *)method{
    __kindof KJBasePlayer * basePlayer = self.kAcceptBasePlayer();
    SEL sel = NSSelectorFromString(method);
    if ([basePlayer respondsToSelector:sel]) {
        IMP imp = [basePlayer methodForSelector:sel];
        void (* tempFunc)(id, SEL) = (void *)imp;
        tempFunc(basePlayer, sel);
    }
}

/// 构建一个需要返回bool类型方法
/// @param method 方法名
/// @return 返回布尔值
- (BOOL)kj_boolMethodIMP:(NSString *)method{
    __kindof KJBasePlayer * basePlayer = self.kAcceptBasePlayer();
    SEL sel = NSSelectorFromString(method);
    if ([basePlayer respondsToSelector:sel]) {
        IMP imp = [basePlayer methodForSelector:sel];
        BOOL (* tempFunc)(id, SEL) = (void *)imp;
        return tempFunc(basePlayer, sel);
    }
    return NO;
}

/// 构建需传递一个参数方法
/// @param method 方法名
/// @param object 参数
/// @return 返回该方法处理之后的对象
- (id)kj_methodIMP:(NSString *)method object:(id)object{
    id tempObject = nil;
    __kindof KJBasePlayer * basePlayer = self.kAcceptBasePlayer();
    SEL sel = NSSelectorFromString(method);
    if ([basePlayer respondsToSelector:sel]) {
        IMP imp = [basePlayer methodForSelector:sel];
        id (* tempFunc)(id, SEL, id) = (void *)imp;
        tempObject = tempFunc(basePlayer, sel, object);
    }
    return tempObject;
}

#pragma mark - bridge method

/// 播放器状态改变
/// @param state 播放器状态
- (void)kj_changePlayerState:(KJPlayerState)state{
    __kindof KJBasePlayer * basePlayer = self.kAcceptBasePlayer();
    void(^kMethodIMP)(NSString *) = ^(NSString * method){
        SEL sel = NSSelectorFromString(method);
        if ([basePlayer respondsToSelector:sel]) {
            IMP imp = [basePlayer methodForSelector:sel];
            void (* tempFunc)(id, SEL, KJPlayerState) = (void *)imp;
            tempFunc(basePlayer, sel, state);
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
    __kindof KJBasePlayer * basePlayer = self.kAcceptBasePlayer();
    BOOL(^kMethodIMP)(NSString *) = ^BOOL(NSString * method){
        SEL sel = NSSelectorFromString(method);
        if ([basePlayer respondsToSelector:sel]) {
            IMP imp = [basePlayer methodForSelector:sel];
            BOOL (* tempFunc)(id, SEL, NSTimeInterval) = (void *)imp;
            return tempFunc(basePlayer, sel, time);
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

#pragma mark - special bridge method

/// 验证是否存在本地缓存
- (void)kj_verifyCacheVideoURL{
    // 缓存管理，`KJBasePlayer+KJCache`
    self.anyObject = [self kj_methodIMP:@"kj_cacheIMP:" object:self.anyObject];
}

/// 初始化时刻注册后台监听
/// @param monitoring 前后台监听
- (void)kj_backgroundMonitoring:(void(^)(BOOL isBackground, BOOL isPlaying))monitoring{
    __kindof KJBasePlayer * basePlayer = self.kAcceptBasePlayer();
    // 前后台管理，`KJBasePlayer+KJBackgroundMonitoring`
    SEL sel = NSSelectorFromString(@"kj_backgroundMonitoringIMP:");
    if ([basePlayer respondsToSelector:sel]) {
        IMP imp = [basePlayer methodForSelector:sel];
        void (* tempFunc)(id, SEL, void(^)(BOOL, BOOL)) = (void *)imp;
        tempFunc(basePlayer, sel, monitoring);
    }
}

@end
