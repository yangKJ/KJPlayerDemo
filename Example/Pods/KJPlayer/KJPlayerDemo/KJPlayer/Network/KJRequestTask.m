//
//  KJPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJRequestTask.h"
#import <AVFoundation/AVFoundation.h>
#import "KJPlayerTool.h"

@interface KJRequestTask ()<NSURLConnectionDataDelegate, AVAssetResourceLoaderDelegate>{
    BOOL _once; // 网络超时，重连一次
}
@property (nonatomic,strong) NSURL *url;  /// 视频地址
@property (nonatomic,assign) NSUInteger videoLength; /// 视频长度
@property (nonatomic,assign) NSUInteger currentOffset;
@property (nonatomic,assign) NSUInteger downLoadOffset; ///
@property (nonatomic,assign) BOOL completeLoad; /// 是否下载完成

@property (nonatomic,strong) NSMutableArray *taskTemps;
@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSString *tempPath; /// 临时缓存文件路径
@property (nonatomic,strong) NSFileHandle *fileHandle; /// 此类主要是对文件内容进行读取和写入操作

@end

@implementation KJRequestTask
#pragma mark - init methods
- (void)config{
    _once = NO;
    self.completeLoad = NO;
    self.downLoadOffset = 0;
    self.videoLength = 0;
}
- (instancetype)init{
    if (self == [super init]) {
        [self config];
        self.taskTemps = [NSMutableArray array];
        /// 临时缓存文件
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        self.tempPath = [document stringByAppendingPathComponent:@"videoTemp.mp4"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_tempPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_tempPath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:_tempPath contents:nil attributes:nil];
        } else {
            [[NSFileManager defaultManager] createFileAtPath:_tempPath contents:nil attributes:nil];
        }
    }
    return self;
}

#pragma mark - public methods
- (void)kj_startLoadWithUrl:(NSURL*)url Offset:(NSUInteger)offset{
    self.url = url;
    self.currentOffset = offset;
    
    /// 如果建立第二次请求，先移除原来文件，再创建新的
    if (self.taskTemps.count >= 1) {
        [[NSFileManager defaultManager] removeItemAtPath:_tempPath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:_tempPath contents:nil attributes:nil];
    }
    
    [self config];
    [self kStartUrlRequestWithOffset:offset];
}
/// 取消
- (void)kj_cancelLoading{
    /// 取消网络请求
    [self.connection cancel];
}
- (void)kj_continueLoading{
    _once = YES;
    [self kStartUrlRequestWithOffset:self.downLoadOffset];
}

- (void)kj_clearCurrentLoadDatas{
    [self kj_cancelLoading];
    /// 移除文件
    [[NSFileManager defaultManager] removeItemAtPath:_tempPath error:nil];
}
#pragma mark - privately methods
/// 开始网络请求
- (void)kStartUrlRequestWithOffset:(NSUInteger)offset{
    [self kj_cancelLoading]; /// 先取消上一次操作
    
    /// 1.确定请求路径
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self.url resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    /// 2.创建一个请求对象  设置请求体（Data） 设置请求超时
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[components URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    /// 3.设置请求头
    if (offset > 0 && self.videoLength > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",(unsigned long)offset, (unsigned long)self.videoLength - 1] forHTTPHeaderField:@"Range"];
    }
    /* 4.创建NSURLConnection对象并设置代理
     设置代理的第二种方式：
     第一个参数：请求对象
     第二个参数：谁成为NSURLConnetion对象的代理
     第三个参数：是否马上发送网络请求，如果该值为YES则立刻发送，如果为NO则不会发送网路请求
     */
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
    /// 调用该方法控制网络请求的发送
    [self.connection start];
}


#pragma mark - NSURLConnectionDataDelegate
/*
 1.当接收到服务器响应的时候调用
 第一个参数connection：监听的是哪个NSURLConnection对象
 第二个参数response：接收到的服务器返回的响应头信息
 */
- (void)connection:(nonnull NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response{
    _completeLoad = NO;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *dic = (NSDictionary *)[httpResponse allHeaderFields] ;
    NSString *content = [dic valueForKey:@"Content-Range"];
    NSArray *array = [content componentsSeparatedByString:@"/"];
    NSString *length = array.lastObject;
    
    NSUInteger videoLength;
    if ([length integerValue] == 0) {
        videoLength = (NSUInteger)httpResponse.expectedContentLength;
    } else {
        videoLength = [length integerValue];
    }
    
    self.videoLength = videoLength;
    
    !self.kRequestTaskDidReceiveVideoLengthBlcok?:self.kRequestTaskDidReceiveVideoLengthBlcok(self,self.videoLength);
    
    [self.taskTemps addObject:connection];
    /// 打开一个文件准备写入
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_tempPath];
}
/*
 2.当接收到数据的时候调用，该方法会被调用多次
 第一个参数connection：监听的是哪个NSURLConnection对象
 第二个参数data：本次接收到的服务端返回的二进制数据（可能是片段）
 */
- (void)connection:(nonnull NSURLConnection *)connection didReceiveData:(nonnull NSData *)data{
    [self.fileHandle seekToEndOfFile];/// 跳到文件末尾
    [self.fileHandle writeData:data]; /// 写入数据
    self.downLoadOffset += data.length;
    
    !self.kRequestTaskDidReceiveDataBlcok?:self.kRequestTaskDidReceiveDataBlcok(self,data);
}
/*
 3.当服务端返回的数据接收完毕之后会调用
 通常在该方法中解析服务器返回的数据
 */
-(void)connectionDidFinishLoading:(nonnull NSURLConnection *)connection{
    BOOL isSuccess = NO;
    if (self.taskTemps.count < 2) {
        _completeLoad = YES;
        /// 获取完整路径
        NSString *movePath = [KJPlayerTool kj_playerGetIntegrityPathWithUrl:self.url];
        /// 保存数据
        isSuccess = [[NSFileManager defaultManager] copyItemAtPath:_tempPath toPath:movePath error:nil];
        if (isSuccess) [self.fileHandle closeFile]; /// 关闭写入 输入文件
    }
    
    !self.kRequestTaskDidFinishLoadingAndSaveFileBlcok?:self.kRequestTaskDidFinishLoadingAndSaveFileBlcok(self,isSuccess);
}
/*
 4.当请求错误的时候调用（比如请求超时）
 第一个参数connection：NSURLConnection对象
 第二个参数：网络请求的错误信息，如果请求失败，则error有值
 请求超时：-1001
 找不到服务器：-1003
 服务器内部错误：-1004
 网络中断：-1005
 无网络连接：-1009
 */
- (void)connection:(nonnull NSURLConnection *)connection didFailWithError:(nonnull NSError *)error{
    if (error.code == -1001 && !_once) { // 网络超时，重连一次
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self kj_continueLoading];
        });
        return;
    }
    
    !self.kRequestTaskdidFailWithErrorCodeBlcok?:self.kRequestTaskdidFailWithErrorCodeBlcok(self,error.code);
}

@end
