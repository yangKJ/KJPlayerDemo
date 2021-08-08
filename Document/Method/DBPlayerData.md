# DBPlayerDataManager

主要包括两部分，数据库模型和增删改查等工具    

**数据库结构**

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
