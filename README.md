# KJPlayer

🎸 - 好消息，**音视频播放器**翻天覆地大改版2.0～

### <a id="功能介绍"></a>功能介绍
**动态切换内核，支持边下边播的播放器方案**   

* 支持音/视频播放，midi文件播放  
* 支持在线播放/本地播放
* 支持后台播放，音频提取播放  
* 支持视频边下边播，分片下载播放存储
* 支持断点续载续播，下次直接优先从缓冲读取播放
* 支持缓存管理，清除时间段缓存
* 支持试看，自动跳过片头片尾
* 支持记录上次播放时间
* 支持自动播放，自动连续播放
* 支持随机/重复/顺序播放
* 支持重力感应，全屏/半屏切换
* 支持基本手势操作，进度音量等
* 支持锁定屏幕
* 长按快进快退等操作
* 支持倍速播放
* 支持切换不同分辨率视频  
* 支持直播流媒体播放  
* 持续更新ing...

----------------------------------------
> 视频支持格式：mp4、m3u8、wav、avi  
> 音频支持格式：midi、mp3、

----------------------------------------

### <a id="效果图"></a>效果图
| <img src="Document/AAA.png" width="300" align="center" /> | <img src="Document/XXX.png" width="300" align="center" /> |
| --- | --- |

### KJBaseFunctionPlayer
- [**播放器内核协议**](Document/Method/KJBaseFunctionPlayer.md)：所有播放器壳子都是基于该基础做处理，提取公共部分

### KJBaseUIPlayer
- [**播放器UI视图协议**](Document/Method/KJBaseUIPlayer.md)：播放器UI相关协议

### KJBasePlayerView
- [**播放器视图基类**](Document/Method/KJBasePlayerView.md)：只要子控件没有涉及到手势交互，我均采用Layer的方式来处理，然后根据`zPosition`来区分控件的上下层级关系

### KJPlayerProtocol
- [**播放器代理**](Document/Method/KJPlayerProtocol.md)：主要包含两部分**内核** 和 **基类视图**
  - **KJPlayerDelegate**：播放器内核代理方法
  - **KJPlayerBaseViewDelegate**：播放器UI控件相关代理方法

### KJPlayerType
- 枚举文件夹和公共方法管理

### DBPlayerData
- [**数据库工具**](Document/Method/DBPlayerData.md)：主要包含两部分**数据库模型** 和 **数据库工具**

### KJResourceLoader
- 中间桥梁作用，把网络请求缓存到本地的临时数据传递给播放器

### KJPlayer
- [**AVPlayer播放器内核**](Document/Method/AVPlayer.md)：基于系统播放器`AVFoundation`封装播放内核
- [**边下边播边存**](Document/边下边播.md)：基于`AVAssetResourceLoaderDelegate`实现边下边播边存方案

**AVPlayer播放工作流程：**  

- 获取视频类型，根据网址来确定，目前没找到更好的方式（知道的朋友可以指点一下）
- 处理视频，这里才用队列组来处理，子线程处理解决第一次加载卡顿问题
- 处理视频链接地址，这里分两种情况，
  - 使用缓存就从缓存当中读取
  - 获取数据库当中的数据
- 判断地址是否可用，添加下载和播放桥梁
- 播放准备操作设置`playerItem`，然后初始化`player`，添加时间观察者处理播放
- 处理视频状态，kvo监听播放器五种状态 
  - `status`：监听播放器状态 
  - `loadedTimeRanges`：监听播放器缓冲进度 
  - `presentationSize`：监听视频尺寸  
  - `playbackBufferEmpty`：监听缓存不够的情况
  - `playbackLikelyToKeepUp`：监听缓存足够  

> 大致流程就差不多这样子，Demo也写的很详细，可以自己去看看🎷

### CocoaPods使用方法
- **公共播放器功能区**

```
pod 'KJPlayer'
```
- **AVPlayer内核播放器 和 边播边下边存分支**

```
pod 'KJPlayer/AVPlayer # 内核和下载分支
pod 'KJPlayer/AVPlayer/AVCore' # 内核
pod 'KJPlayer/AVPlayer/AVDownloader' # 边下边播
```
- **MIDI内核**

```
pod 'KJPlayer/MIDI'
```
- **IJKPlayer内核**

```
pod 'KJPlayer/IJKPlayer'
```

### <a id="更新日志"></a>更新日志
> **[更新日志](CHANGELOG.md)**

#### **总结：先把基本的壳子完善，后面再慢慢来补充其他的内核，如若觉得有帮助请帮忙点个星，有什么问题和需求也可以Issues**

### 关于作者
- 🎷**邮箱地址：[ykj310@126.com](ykj310@126.com) 🎷**
- 🎸**GitHub地址：[yangKJ](https://github.com/yangKJ) 🎸**
- 🎺**掘金地址：[茶底世界之下](https://juejin.cn/user/1987535102554472/posts) 🎺**
- 🚴🏻**简书地址：[77___](https://www.jianshu.com/u/c84c00476ab6) 🚴🏻**

#### 救救孩子吧，谢谢各位老板～～～～

-----
