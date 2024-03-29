# KJPlayerProtocol

### KJPlayerDelegate
- **委托代理：**播放器内核相关代理

```
/// 当前播放器状态
/// @param player 播放器内核
/// @param state 播放器状态
- (void)kj_player:(__kindof KJBasePlayer *)player state:(KJPlayerState)state;

/// 播放进度
/// @param player 播放器内核
/// @param currentTime 当前播放时间
- (void)kj_player:(__kindof KJBasePlayer *)player currentTime:(NSTimeInterval)currentTime;

/// 缓存进度
/// @param player 播放器内核
/// @param loadProgress 缓存进度
- (void)kj_player:(__kindof KJBasePlayer *)player loadProgress:(CGFloat)loadProgress;

/// 播放错误
/// @param player 播放器内核
/// @param failed 错误信息
- (void)kj_player:(__kindof KJBasePlayer *)player playFailed:(NSError *)failed;

```

### KJPlayerBaseViewDelegate
- **控件载体协议：**UI相关协议代理

```
/// 单双击手势反馈
/// @param view 播放器控件载体
/// @param tap 是否为单击
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view isSingleTap:(BOOL)tap;

/// 长按手势反馈
/// @param view 播放器控件载体
/// @param longPress 长按手势
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view
                longPress:(UILongPressGestureRecognizer *)longPress;

/// 进度手势反馈
/// @param view 播放器控件载体
/// @param progress 进度范围，-1 到 1
/// @param end 是否结束
/// @return 不替换UI请返回当前时间和总时间
- (nullable NSArray *)kj_basePlayerView:(__kindof KJBasePlayerView *)view
                                progress:(float)progress
                                     end:(BOOL)end;

/// 音量手势反馈
/// @param view 播放器控件载体
/// @param value 音量范围，-1 到 1
/// @return 是否替换自带UI
- (BOOL)kj_basePlayerView:(__kindof KJBasePlayerView *)view volumeValue:(float)value;

/// 亮度手势反馈
/// @param view 播放器控件载体
/// @param value 亮度范围，0 到 1
/// @return 是否替换自带UI
- (BOOL)kj_basePlayerView:(__kindof KJBasePlayerView *)view brightnessValue:(float)value;

/// 按钮事件响应
/// @param view 播放器控件载体
/// @param buttonType 按钮类型，KJPlayerButtonType类型
/// @param button 当前响应按钮
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view
               buttonType:(NSUInteger)buttonType
             playerButton:(__kindof KJPlayerButton *)button;

/// 是否锁屏
/// @param view 播放器控件载体
/// @param locked 是否锁屏
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view locked:(BOOL)locked;

/// 返回按钮响应
/// @param view 播放器控件载体
/// @param clickBack 点击返回
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view clickBack:(BOOL)clickBack;

/// 当前屏幕状态发生改变
/// @param view 播放器控件载体
/// @param screenState 当前屏幕状态
- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view screenState:(KJPlayerVideoScreenState)screenState;

```