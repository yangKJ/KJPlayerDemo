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
PLAYER_COMMON_PROPERTY PLAYER_COMMON_UI_PROPERTY
- (instancetype)init{
    if (self = [super init]) {
        self.speed = 1.;
        self.autoPlay = YES;
        self.timeSpace = 1.;
    }
    return self;
}
- (void)dealloc {
    [self kj_stop];
}
#pragma mark - setter/getter
- (void)setVideoURL:(NSURL*)videoURL{
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
    if (_musicPlayer == nil) return NO;
    Boolean xxxxx = NO;
    MusicPlayerIsPlaying(_musicPlayer, &xxxxx);
    return xxxxx;
}

#pragma mark - public method
/* 准备播放 */
- (void)kj_play{
    MusicPlayerStart(_musicPlayer);
}
/* 重播 */
- (void)kj_replay{
    [self kj_play];
}
/* 继续 */
- (void)kj_resume{
    if (![self isPlaying] && _musicPlayer) MusicPlayerStart(_musicPlayer);
    [self startGraph];
}
/* 暂停 */
- (void)kj_pause{
    if ([self isPlaying]) MusicPlayerStop(_musicPlayer);
    [self stopGraph];
}
/* 停止 */
- (void)kj_stop{
    [self stopGraph];
    MusicPlayerStop(_musicPlayer);
    DisposeMusicPlayer(_musicPlayer);
    DisposeMusicSequence(sequence);
    DisposeAUGraph(graph);
    _musicPlayer = nil;
}
/* 快进或快退 */
- (void (^)(NSTimeInterval,void (^_Nullable)(BOOL)))kVideoAdvanceAndReverse{
    return ^(NSTimeInterval seconds,void (^xxblock)(BOOL)){
        MusicTimeStamp time = seconds;
        SInt32 xx = MusicPlayerSetTime(self->_musicPlayer, time);
        if (xxblock) xxblock(xx>=0);
    };
}

#pragma mark - private method
- (void)createGraph {
    if (_musicPlayer) [self kj_stop];
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
