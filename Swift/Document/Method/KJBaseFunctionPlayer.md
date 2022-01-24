# KJBaseFunctionPlayer

- **播放器协议：**所有播放器壳子都是基于该基础做处理，提取公共部分

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