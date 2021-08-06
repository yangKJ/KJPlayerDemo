# KJPlayer

好消息，音视频播放器重新大改版2.0～

### <a id="功能介绍"></a>功能介绍
动态切换内核，支持边下边播的播放器方案   

* 支持音/视频播放，midi文件播放  
* 支持在线播放/本地播放
* 支持后台播放，音频提取播放  
* 支持视频边下边播，分片下载播放存储
* 支持断点续载续播，下次直接优先从缓冲读取播放
* 支持缓存管理，清除时间段缓存
* 支持试看，自动跳过片头
* 支持记录上次播放时间
* 支持自动播放，自动连续播放
* 支持随机/重复/顺序播放
* 支持重力感应，全屏/半屏切换
* 支持基本手势操作，进度音量等
* 支持切换不同分辨率视频  
* 支持直播流媒体播放  
* 持续更新ing...

----------------------------------------
> 视频支持格式：mp4、m3u8、wav、avi  
> 音频支持格式：midi、mp3、

----------------------------------------

### <a id="使用方法"></a>Pod使用方法
```
pod 'KJPlayer' # 播放器功能区
pod 'KJPlayer/AVPlayer' # AVPlayer内核播放器
pod 'KJPlayer/AVDownloader'  # AVPlayer附加边播边下边存分支 
pod 'KJPlayer/MIDI' # midi内核
pod 'KJPlayer/IJKPlayer' # ijkplayer内核
```

### <a id="更新日志"></a>更新日志
> **[更新日志](https://github.com/yangKJ/KJPlayerDemo/blob/master/CHANGELOG.md)**

### <a id="效果图"></a>效果图
横屏展示效果图：

![](https://upload-images.jianshu.io/upload_images/1933747-3d64de1b9d073891.png)

竖屏目前展示效果：

![](https://upload-images.jianshu.io/upload_images/1933747-537dbd09082b0153.jpeg)

## 模块介绍
### KJBaseFunctionPlayer播放器协议
所有播放器壳子都是基于该基础做处理，提取公共部分

|   API & Property   |  类型  |  功能  | 
| ---- | :----: | ---- |
| delegate | Property | 委托代理 |
| requestHeader | Property | 视频请求头 |
| roregroundResume | Property | 返回前台继续播放 |
| backgroundPause | Property | 进入后台暂停播放 |
| autoPlay | Property | 是否开启自动播放 |
| speed | Property | 播放速度 |
| volume | Property | 播放音量 |
| cacheTime | Property | 缓存达到多少秒才能播放 |
| skipHeadTime | Property | 跳过片头 |
| timeSpace | Property | 时间刻度 |
| kVideoTotalTime | Property | 获取视频总时长 |
| kVideoURLFromat | Property | 获取视频格式 |
| kVideoTryLookTime | Property | 免费试看时间和试看结束回调 |
| videoURL | Property | 视频地址 |
| localityData | Property | 是否为本地资源 |
| isPlaying | Property | 是否正在播放 |
| currentTime | Property | 当前播放时间 |
| ecode | Property | 播放失败 |
| kVideoAdvanceAndReverse | Property | 快进或快退 |
| shared | Property | 单例属性 |
| kj_sharedInstance | Instance | 创建单例 |
| kj_attempDealloc | Instance | 销毁单例 |
| kj_play | Instance | 准备播放 |
| kj_replay | Instance | 重播 |
| kj_resume | Instance | 继续 |
| kj_pause | Instance | 暂停 |
| kj_stop | Instance | 停止 |

#### KJPlayerDelegate委托代理
```
/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state;
/* 播放进度 */
- (void)kj_player:(KJBasePlayer*)player currentTime:(NSTimeInterval)time;
/* 缓存进度 */
- (void)kj_player:(KJBasePlayer*)player loadProgress:(CGFloat)progress;
/* 播放错误 */
- (void)kj_player:(KJBasePlayer*)player playFailed:(NSError*)failed;
```

### KJBaseUIPlayer播放器协议
播放器UI相关协议

|   API & Property   |  类型  |  功能  | 
| ---- | :----: | ---- |
| playerView | Property | 播放器载体 |
| background | Property | 背景颜色 |
| placeholder | Property | 占位图 |
| videoGravity | Property | 视频显示模式 |
| kVideoSize | Property | 获取视频尺寸大小 |
| kVideoTimeScreenshots | Property | 获取当前截屏 |

### KJBasePlayerView播放器视图基类，播放器控件父类
只要子控件没有涉及到手势交互，我均采用Layer的方式来处理，然后根据`zPosition`来区分控件的上下层级关系

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
#### KJPlayerBaseViewDelegate控件载体协议
```
/* 单双击手势反馈 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view isSingleTap:(BOOL)tap;
/* 长按手势反馈 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view longPress:(UILongPressGestureRecognizer*)longPress;
/* 进度手势反馈，不替换UI请返回当前时间和总时间，范围-1 ～ 1 */
- (NSArray*)kj_basePlayerView:(KJBasePlayerView*)view progress:(float)progress end:(BOOL)end;
/* 音量手势反馈，是否替换自带UI，范围0 ～ 1 */
- (BOOL)kj_basePlayerView:(KJBasePlayerView*)view volumeValue:(float)value;
/* 亮度手势反馈，是否替换自带UI，范围0 ～ 1 */
- (BOOL)kj_basePlayerView:(KJBasePlayerView*)view brightnessValue:(float)value;

```

### KJPlayerType
枚举文件夹和公共方法管理

- KJPlayerState：播放器状态
- KJPlayerCustomCode：错误code
- KJPlayerGestureType：手势操作
- KJPlayerPlayType：播放类型
- KJPlayerDeviceDirection：手机方向
- KJPlayerVideoGravity：播放器充满类型
- KJPlayerVideoFromat：视频格式

### DBPlayerDataManager
主要包括两部分，数据库模型和增删改查等工具    
**数据库结构**

![](https://upload-images.jianshu.io/upload_images/1933747-c1463d2d3ec4f2c4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/600)

```
/// 主键ID，视频链接去除SCHEME然后MD5
@property (nonatomic,retain) NSString * dbid;
/// 视频链接
@property (nonatomic,retain) NSString * videoUrl;
/// 存储时间戳
@property (nonatomic,assign) int64_t saveTime;
/// 沙盒地址
@property (nonatomic,retain) NSString * sandboxPath;
/// 视频格式
@property (nonatomic,retain) NSString * videoFormat;
/// 视频内容长度
@property (nonatomic,assign) int64_t videoContentLength;
/// 视频已下载完成
@property (nonatomic,assign) Boolean videoIntact;
/// 视频数据
@property (nonatomic,retain) NSData * videoData;
/// 视频上次播放时间
@property (nonatomic,assign) int64_t videoPlayTime;
```
**数据库工具**

|  方法  |  功能  | 
| ---- | ---- |
| kj_insertData:Data: | 插入数据，重复数据替换处理 |
| kj_deleteData: | 删除数据 |
| kj_addData: | 新添加数据 |
| kj_updateData:Data: | 更新数据 |
| kj_checkData: | 查询数据，传空传全部数据 |
| kj_checkAppointDatas | 指定条件查询 |

### KJResourceLoader
中间桥梁作用，把网络请求缓存到本地的临时数据传递给播放器

### KJPlayer - AVPlayer播放器内核
**工作流程：**  

- 1、获取视频类型，根据网址来确定，目前没找到更好的方式（知道的朋友可以指点一下）
- 2、处理视频，这里才用队列组来处理，子线程处理解决第一次加载卡顿问题
- 3、处理视频链接地址，这里分两种情况，
    - 使用缓存就从缓存当中读取
    - 获取数据库当中的数据
- 4、判断地址是否可用，添加下载和播放桥梁
- 5、播放准备操作设置`playerItem`，然后初始化`player`，添加时间观察者处理播放
- 6、处理视频状态，kvo监听播放器五种状态 
    - `status`：监听播放器状态 
    - `loadedTimeRanges`：监听播放器缓冲进度 
    - `presentationSize`：监听视频尺寸  
    - `playbackBufferEmpty`：监听缓存不够的情况
    - `playbackLikelyToKeepUp`：监听缓存足够  

大致流程就差不多这样子，Demo也写的很详细，可以自己去看看

#### **总结：先把基本的壳子完善，后面再慢慢来补充其他的内核，如若觉得有帮助请帮忙点个星，有什么问题和需求也可以Issues**
**也可以通过以下方式联系我，邮箱地址：ykj310@126.com**

### 关于作者
- 🎷**邮箱地址：[ykj310@126.com](ykj310@126.com) 🎷**
- 🎸**GitHub地址：[yangKJ](https://github.com/yangKJ) 🎸**
- 🎺**掘金地址：[茶底世界之下](https://juejin.cn/user/1987535102554472/posts) 🎺**
- 🚴🏻**简书地址：[77___](https://www.jianshu.com/u/c84c00476ab6) 🚴🏻**

#### 救救孩子吧，谢谢各位老板～～～～

-----
