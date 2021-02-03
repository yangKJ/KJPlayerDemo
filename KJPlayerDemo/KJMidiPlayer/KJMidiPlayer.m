//
//  KJMidiPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/2.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJMidiPlayer.h"
@interface KJMidiPlayer()
@property (nonatomic,assign) MusicPlayer musicPlayer;
@property (nonatomic,assign) NSTimeInterval currentTime,totalTime;
@end
@implementation KJMidiPlayer{
    AUGraph graph; /// 音频处理图
    AUNode sourceNode; /// 输入节点
    AUNode destNode; /// 输出节点
    AudioUnit remoteIOUnit;/// 属性值的音频单元
    MusicSequence sequence;/// 音乐序列
}
PLAYER_COMMON_PROPERTY PLAYER_SHARED
- (void)dealloc {
    [self kj_playerStop];
}
#pragma mark - setter/getter
- (void)setVideoURL:(NSURL *)videoURL{
    _videoURL = videoURL;
    [self createGraph];
    [self loadAudioUnitSetProperty];
    [self loadMusicSequenceFileWithURL:videoURL];
}
- (void)setSpeed:(float)speed{
    _speed = speed;
    if (_musicPlayer) MusicPlayerSetPlayRateScalar(_musicPlayer,speed);
}
- (BOOL)isPlaying{
    Boolean xxxxx = NO;
    MusicPlayerIsPlaying(_musicPlayer, &xxxxx);
    return xxxxx;
}

#pragma mark - public method
/* 准备播放 */
- (void)kj_playerPlay{
    MusicPlayerStart(_musicPlayer);
}
/* 重播 */
- (void)kj_playerReplay{
    [self kj_playerPlay];
}
/* 继续 */
- (void)kj_playerResume{
    if (![self isPlaying] && _musicPlayer) MusicPlayerStart(_musicPlayer);
    [self startGraph];
}
/* 暂停 */
- (void)kj_playerPause{
    if ([self isPlaying]) MusicPlayerStop(_musicPlayer);
    [self stopGraph];
}
/* 停止 */
- (void)kj_playerStop{
    [self stopGraph];
    MusicPlayerStop(_musicPlayer);
    DisposeMusicPlayer(_musicPlayer);
    DisposeMusicSequence(sequence);
    DisposeAUGraph(graph);
    _musicPlayer = nil;
}
/* 设置开始播放时间 */
- (void)kj_playerSeekTime:(NSTimeInterval)seconds completionHandler:(void(^_Nullable)(BOOL finished))completionHandler{
    MusicTimeStamp time = seconds;
    SInt32 xx = MusicPlayerSetTime(_musicPlayer, time);
    if (completionHandler) completionHandler(xx>=0);
}
#pragma mark - private method
- (void)createGraph {
    if (_musicPlayer) [self kj_playerStop];
    NewAUGraph(&graph);

    AudioComponentDescription sourceNodeDes;
    sourceNodeDes.componentType = kAudioUnitType_MusicDevice;
    sourceNodeDes.componentSubType = kAudioUnitSubType_Sampler;
    sourceNodeDes.componentManufacturer = kAudioUnitManufacturer_Apple;
    AUGraphAddNode(graph, &sourceNodeDes, &sourceNode);
    
    AudioComponentDescription destNodeDes;
    destNodeDes.componentType = kAudioUnitType_Output;
    destNodeDes.componentSubType = kAudioUnitSubType_RemoteIO;
    destNodeDes.componentManufacturer = kAudioUnitManufacturer_Apple;
    AUGraphAddNode(graph, &destNodeDes, &destNode);
    
    AUGraphOpen(graph);
    AUGraphNodeInfo(graph, sourceNode, NULL, &remoteIOUnit);
    AUGraphConnectNodeInput(graph, sourceNode, 0, destNode, 0);
    AUGraphInitialize(graph);
    
    [self startGraph];
}

- (void)loadAudioUnitSetProperty{
    NSURL *bankURL = [[NSBundle mainBundle] URLForResource:@"KJMidiSource.bundle/instrument" withExtension:@"dls"];
    AUSamplerInstrumentData data;
    data.fileURL        = (__bridge CFURLRef)bankURL;
    data.instrumentType = kInstrumentType_DLSPreset;
    data.bankMSB        = kAUSampler_DefaultMelodicBankMSB;
    data.bankLSB        = kAUSampler_DefaultBankLSB;
    data.presetID       = 0;
    AudioUnitSetProperty(remoteIOUnit, kAUSamplerProperty_LoadInstrument, kAudioUnitScope_Global, 0, &data, sizeof(data));
}

- (void)loadMusicSequenceFileWithURL:(NSURL*)fileURL{
    NewMusicSequence(&sequence);
    MusicSequenceFileLoad(sequence,
                          (__bridge CFURLRef)fileURL,
                          kMusicSequenceFile_MIDIType,
                          kMusicSequenceLoadSMF_ChannelsToTracks);
    MusicSequenceSetAUGraph(sequence, graph);
    
    NewMusicPlayer(&_musicPlayer);
    MusicPlayerSetSequence(_musicPlayer, sequence);
    MusicPlayerPreroll(_musicPlayer);
    
    MusicTimeStamp time;
    MusicPlayerGetTime(_musicPlayer, &time);
    self.totalTime = time;
    NSLog(@"totalTime:%.2f",time);
}
/// 开启音频处理图
- (void)startGraph{
    if (graph && ![self isPlaying]) AUGraphStart(graph);
}
/// 停止音频处理图
- (void)stopGraph{
    if (graph && [self isPlaying]) AUGraphStop(graph);
}


@end
