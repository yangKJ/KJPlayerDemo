# KJPlayer

好消息，音视频播放器重新大改版2.0.0～

### <a id="功能介绍"></a>功能介绍
动态切换内核，支持边下边播的播放器方案   

* 支持音/视频播放，midi文件播放  
* 支持在线播放/本地播放
* 支持后台播放，音频提取播放  
* 支持视频边下边播，把播放器播放过的数据流缓存到本地
* 支持断点续载续播，下次直接优先从缓冲读取播放
* 支持缓存管理，清除时间段缓存
* 支持试看，自动跳过片头
* 支持记录上次播放时间
* 支持自动播放，自动连续播放
* 支持随机/重复/顺序播放
* 支持重力感应，全屏/半屏切换
* 支持基本手势操作，进度音量等
* 支持切换不同分辨率视频

----------------------------------------
> 视频支持格式：mp4、m3u8、wav、avi  
> 音频支持格式：midi、mp3、

----------------------------------------

### <a id="使用方法"></a>Pod使用方法
```
pod 'KJPlayer' # 播放器功能区
pod 'KJPlayer/KJPlayerView' # 自带展示界面
```

### <a id="更新日志"></a>更新日志
> **[更新日志](https://github.com/yangKJ/KJPlayerDemo/blob/master/CHANGELOG.md)**

### <a id="效果图"></a>效果图
横屏展示效果图：
![培训活动-视频全屏](https://upload-images.jianshu.io/upload_images/1933747-3d64de1b9d073891.png)

竖屏目前展示效果：
![WechatIMG10.jpeg](https://upload-images.jianshu.io/upload_images/1933747-537dbd09082b0153.jpeg)

## 模块介绍
### KJBasePlayer播放器协议
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

#### KJPlayerDelegate委托代理
```
/* 当前播放器状态 */
- (void)kj_player:(KJCommonPlayer*)player state:(KJPlayerState)state;
/* 播放进度 */
- (void)kj_player:(KJCommonPlayer*)player currentTime:(NSTimeInterval)time;
/* 缓存进度 */
- (void)kj_player:(KJCommonPlayer*)player loadProgress:(CGFloat)progress;
/* 播放错误 */
- (void)kj_player:(KJCommonPlayer*)player playFailed:(NSError*)failed;
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

### DBPlayerDataInfo
主要包括两部分，数据库模型和增删改查等工具    
**数据库结构**

![](https://upload-images.jianshu.io/upload_images/1933747-c1463d2d3ec4f2c4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/600)

```
dbid：唯一id，视频链接去除scheme然后md5
videoUrl：视频链接  
saveTime：存储时间戳
sandboxPath：沙盒地址
videoFormat：视频格式
videoTime：视频时间
videoData：视频数据
```
**数据库工具**

|  方法  |  功能  | 
| ---- | ---- |
| kj_insertData:Data: | 插入数据，重复数据替换处理 |
| kj_deleteData: | 删除数据 |
| kj_addData: | 新添加数据 |
| kj_updateData:Data: | 更新数据 |
| kj_checkData: | 查询数据，传空传全部数据 |
| kCheckAppointDatas | 指定条件查询 |

### KJDownloader
*  网络请求数据，并把数据写入到 NSDocumentDirectory
*  如果数据完整，则把数据缓存到指定的路径，储存起来
*  如果不完整，则采用归档方式存储，下次继续加载
 
核心功能其实就是实现`NSURLSessionDelegate`协议方法

接收到数据的时刻写入`NSFileHandle`当中

```
[self.writeHandle seekToFileOffset:range.location];
[self.writeHandle writeData:data];
self.writeBytes += data.length;
```
接收完成，数据完整将数据移动到指定路径，

```
[[NSFileManager defaultManager] moveItemAtPath:_tempPath toPath:self.savePath error:nil];
```
同时存储信息在数据库当中

```
[DBPlayerDataInfo kj_insertData:self.fileName Data:^(DBPlayerData * _Nonnull data) {
    data.dbid = weakself.fileName;
    data.videoUrl = weakself.videoURL.absoluteString;
    data.videoFormat = weakself.format;
    data.sandboxPath = [weakself.fileName stringByAppendingString:weakself.format];
    data.saveTime = NSDate.date.timeIntervalSince1970;
}];
```

### KJResourceLoader
中间桥梁作用，把网络请求缓存到本地的临时数据传递给播放器

### KJPlayer - AVPlayer播放器内核
工作流程：  
1、获取视频格式，根据网址来确定，目前没找到更好的方式（知道的朋友可以指点一下）

```
NS_INLINE KJPlayerVideoFromat kPlayerFromat(NSURL *url){
    if (url == nil) return KJPlayerVideoFromat_none;
    if (url.pathExtension.length) {
        return kPlayerVideoURLFromat(url.pathExtension);
    }
    NSArray * array = [url.path componentsSeparatedByString:@"."];
    if (array.count == 0) {
        return KJPlayerVideoFromat_none;
    }else{
        return kPlayerVideoURLFromat(array.lastObject);
    }
}
```

2、处理视频，这里才用队列组来处理，子线程处理解决第一次加载卡顿问题

```
dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if ([weakself kj_dealVideoURL:&tempURL]) {
        if (![tempURL.absoluteString isEqualToString:self->_videoURL.absoluteString]) {
            self->_videoURL = tempURL;
            [weakself kj_initPreparePlayer];
        }else{
            [weakself kj_playerReplay];
        }
    }
});
```

3、处理视频链接地址，这里分两种情况，使用缓存就从缓存当中读取

```
NSString *dbid = kPlayerIntactName(*videoURL);
NSArray<DBPlayerData*>*temps = [DBPlayerDataInfo kj_checkData:dbid];
if (temps.count) {
    NSString * path = kPlayerIntactSandboxPath(temps.firstObject.sandboxPath);
    self.localityData = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (self.localityData) {
        self.progress = 1.0;
        *videoURL = [NSURL fileURLWithPath:path];
    }else{
        [DBPlayerDataInfo kj_deleteData:dbid];
    }
}
```
4、判断地址是否可用，添加下载和播放桥梁

```
PLAYER_WEAKSELF;
if (!kPlayerHaveTracks(*videoURL, ^(AVURLAsset * asset) {
    weakself.totalTime = ceil(asset.duration.value/asset.duration.timescale);
    kGCD_player_main(^{
        if (weakself.kVideoTotalTime) weakself.kVideoTotalTime(weakself.totalTime);
    });
    if (weakself.useCacheFunction && !weakself.localityData) {
        weakself.state = KJPlayerStateBuffering;
        weakself.loadState = KJPlayerLoadStateNone;
        NSURL * tempURL = weakself.connection.kj_createSchemeURL(*videoURL);
        weakself.asset = [AVURLAsset URLAssetWithURL:tempURL options:weakself.requestHeader];
        [weakself.asset.resourceLoader setDelegate:weakself.connection queue:dispatch_get_main_queue()];
    }else{
        weakself.asset = asset;
    }
}, self.requestHeader)) {
    self.ecode = KJPlayerCustomCodeVideoURLFault;
    self.state = KJPlayerStateFailed;
    [self kj_destroyPlayer];
    return NO;
}
```

5、播放准备操作，设置`playerItem`，然后初始化`player`，添加时间观察，处理播放

```
if (weakself.currentTime >= weakself.totalTime) {
    [weakself.player pause];
    weakself.state = KJPlayerStatePlayFinished;
    if ([weakself.delegate respondsToSelector:@selector(kj_player:currentTime:totalTime:)]) {
        [weakself.delegate kj_player:weakself currentTime:weakself.totalTime totalTime:weakself.totalTime];
    }
    weakself.currentTime = 0;
}else if (weakself.userPause == NO && weakself.buffered) {
    weakself.state = KJPlayerStatePlaying;
    if ([weakself.delegate respondsToSelector:@selector(kj_player:currentTime:totalTime:)]) {
        [weakself.delegate kj_player:weakself currentTime:weakself.currentTime totalTime:weakself.totalTime];
    }
}
if (weakself.currentTime > weakself.tryTime && weakself.tryTime) {
    if (!weakself.tryLooked) {
        weakself.tryLooked = YES;
        if (weakself.tryTimeBlock) weakself.tryTimeBlock(true);
    }
    [weakself kj_playerPause];
}else{
    weakself.tryLooked = NO;
}
```

6、处理视频状态，kvo监听播放器五种状态 
 
- `status`：播放器状态  
- `loadedTimeRanges`：监听播放器的下载进度 
- `presentationSize`：获取播放视频尺寸  
- `playbackBufferEmpty`：监听播放器在缓冲数据的状态  
- `playbackLikelyToKeepUp`：是否在播放  

大致流程就差不多这样子，Demo也写的很详细，可以自己去看看

### KJMidiPlayer - 播放midi文件的壳子

<p align="left">
<img src="https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1590984664032&di=f75bbfdf1c76e20749fd40be9c784738&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20181208%2F2e9d5c7277094ace8e7385e018ccc2d4.jpeg" width="777" hspace="1px">
</p>

#### **总结：先把基本的壳子完善，后面再慢慢来补充其他的内核，如若觉得有帮助请帮忙点个星，有什么问题和需求也可以Issues**
也可以通过以下方式联系我，邮箱地址：ykj310@126.com

**[Github地址](https://github.com/yangKJ) 、[简书地址](https://www.jianshu.com/u/c84c00476ab6) 、[博客地址](https://blog.csdn.net/qq_34534179)、[掘金地址](https://juejin.cn/user/1987535102554472/posts)**
