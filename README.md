# KJPlayer
KJPlayer是一款视频播放器，AVPlayer的封装，继承UIView

----------------------------------------
### 本人其他库
```
播放器 - KJPlayer是一款视频播放器，AVPlayer的封装，继承UIView
pod 'KJPlayer'  # 播放器功能区
pod 'KJPlayer/KJPlayerView'  # 自带展示界面
- 支持播放网络和本地视频、播放多种格式
- 视频可以边下边播，把播放器播放过的数据流缓存到本地，下次直接从缓冲读取播放
- 支持拖动、手势快进倒退、增大减小音量、重力感应切换横竖屏等等

实用又方便的Category和一些自定义控件
pod 'KJEmitterView'
pod 'KJEmitterView/Function'#
pod 'KJEmitterView/Control' # 自定义控件

轮播图 - 支持缩放 多种pagecontrol 支持继承自定义样式 自带网络加载和缓存
pod 'KJBannerView'  # 轮播图，网络图片加载

菜单控件 - 下拉控件 选择控件
pod 'KJMenuView' # 菜单控件

加载Loading - 多种样式供选择
pod 'KJLoadingAnimation' # 加载控件

Github地址：https://github.com/yangKJ
简书地址：https://www.jianshu.com/u/c84c00476ab6
博客地址：https://blog.csdn.net/qq_34534179

```

### 框架整体介绍
* [功能介绍](#功能介绍)
* [使用方法(支持cocoapods/carthage安装)](#使用方法)
* [更新日志](#更新日志)
* [效果图](#效果图)

### <a id="功能介绍"></a>功能介绍
- [x] 支持播放网络和本地视频
- [x] 支持播放多种格式mp4、m3u8、3gp、mov等等
- [x] 视频可以边下边播，把播放器播放过的数据流缓存到本地，下次直接从缓冲读取播放
- [x] 支持拖动、手势快进倒退、增大减小音量等等
- [x] 支持重力感应切换横竖屏

###
下载完Demo请执行`carthage update --platform iOS`

### Feature

> 如果您在使用中有好的需求及建议，或者遇到什么bug，欢迎随时issue，我会及时的回复

### <a id="使用方法(支持cocoapods/carthage安装)"></a>Pod使用方法
```
pod 'KJPlayer'  # 播放器功能区
pod 'KJPlayer/KJPlayerView'  # 自带展示界面
```

### <a id="更新日志"></a>更新日志


### KJPlayer

- KJPlayerTool：主要提供一些播放器的工具  判断是否含有视频轨道  获取视频第一帧图片和总时长等等
- KJRequestTask：网络缓存类   网络请求结束的时候，如果数据完整，则把数据缓存到指定的路径，储存起来，如果不完整，则删除缓存的临时文件数据
- KJPlayerURLConnection：网络和Player的中转类   把网络请求缓存到本地的临时数据`offset`和`videoLength`传递给播放器

#### 功能区
```
UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16)];
view.backgroundColor = UIColor.cyanColor;
[self.view addSubview:view];

NSURL *url = [NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"];

KJPlayer *player = [KJPlayer sharedInstance];
player.playerDelegate = self;
AVPlayerLayer *playerLayer = [player kj_playWithUrl:url];
[player kj_seekToTime:player.videoTotalTime - 10];
playerLayer.frame = view.bounds;
[view.layer addSublayer:playerLayer];
```
#####委托代理
```
#pragma mark - KJPlayerDelegate
- (void)kj_player:(nonnull KJPlayer *)player LoadedProgress:(CGFloat)loadedProgress LoadComplete:(BOOL)complete SaveSuccess:(BOOL)saveSuccess {
//    NSLog(@"Load:%.2f==%d==%d",loadedProgress,complete,saveSuccess);
}

- (void)kj_player:(nonnull KJPlayer *)player Progress:(CGFloat)progress CurrentTime:(CGFloat)currentTime DurationTime:(CGFloat)durationTime {
NSLog(@"Time:%.2f==%.2f==%.2f",progress,currentTime,durationTime);
}

- (void)kj_player:(nonnull KJPlayer *)player State:(KJPlayerState)state ErrorCode:(KJPlayerErrorCode)errorCode {
NSLog(@"State:%ld==%ld",state,errorCode);
}
```
