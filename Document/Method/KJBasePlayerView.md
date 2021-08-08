# KJBasePlayerView
- **播放器视图基类**：只要子控件没有涉及到手势交互，我均采用Layer的方式来处理，然后根据`zPosition`来区分控件的上下层级关系

```
/* 委托代理 */
@property (nonatomic,weak) id <KJPlayerBaseViewDelegate> delegate;
/* 主色调，默认白色 */
@property (nonatomic,strong) UIColor *mainColor;
/* 副色调，默认红色 */
@property (nonatomic,strong) UIColor *viceColor;
/* 支持手势，支持多枚举 */
@property (nonatomic,assign) KJPlayerGestureType gestureType;
/* 长按执行时间，默认1秒 */
@property (nonatomic,assign) NSTimeInterval longPressTime;
/* 操作面板自动隐藏时间，默认2秒然后为零表示不隐藏 */
@property (nonatomic,assign) NSTimeInterval autoHideTime;
/* 操作面板高度，默认60px */
@property (nonatomic,assign) CGFloat operationViewHeight;
/* 当前操作面板状态 */
@property (nonatomic,assign,readonly) BOOL displayOperation;
/* 隐藏操作面板时是否隐藏返回按钮，默认yes */
@property (nonatomic,assign) BOOL isHiddenBackButton;
/* 小屏状态下是否显示返回按钮，默认yes */
@property (nonatomic,assign) BOOL smallScreenHiddenBackButton;
/* 全屏状态下是否显示返回按钮，默认no */
@property (nonatomic,assign) BOOL fullScreenHiddenBackButton;
/* 是否为全屏，名字别乱改后面kvc有使用 */
@property (nonatomic,assign) BOOL isFullScreen;
/* 当前屏幕状态，名字别乱改后面kvc有使用 */
@property (nonatomic,assign,readonly) KJPlayerVideoScreenState screenState;

#pragma mark - 控件
/* 快进快退进度控件 */
@property (nonatomic,strong) KJPlayerFastLayer *fastLayer;
/* 音量亮度控件 */
@property (nonatomic,strong) KJPlayerSystemLayer *vbLayer;
/* 加载动画层 */
@property (nonatomic,strong) KJPlayerLoadingLayer *loadingLayer;
/* 文本提示框 */
@property (nonatomic,strong) KJPlayerHintTextLayer *hintTextLayer;
/* 顶部操作面板 */
@property (nonatomic,strong) KJPlayerOperationView *topView;
/* 底部操作面板 */
@property (nonatomic,strong) KJPlayerOperationView *bottomView;

#pragma mark - method
/* 隐藏操作面板，是否隐藏返回按钮 */
- (void)kj_hiddenOperationView;
/* 显示操作面板 */
- (void)kj_displayOperationView;

```
