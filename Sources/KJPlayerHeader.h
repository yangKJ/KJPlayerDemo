//
//  KJPlayerHeader.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#ifndef KJPlayerHeader_h
#define KJPlayerHeader_h

/* ****************  视图控件UI  ****************/
#if __has_include(<KJPlayer/KJBasePlayerView.h>)
#import <KJPlayer/KJBasePlayerView.h>
#elif __has_include("KJBasePlayerView.h")
#import "KJBasePlayerView.h"
#else
#endif

/* ****************  AVPlayer内核  ****************/
#if __has_include(<KJPlayer/KJAVPlayer.h>)
#import <KJPlayer/KJAVPlayer.h>
#elif __has_include("KJAVPlayer.h")
#import "KJAVPlayer.h"
#else
#endif

/* ****************  AVPlayer内核边下边播边缓存分支  ****************/
#if __has_include(<KJPlayer/KJAVPlayer+KJCache.h>)
#import <KJPlayer/KJAVPlayer+KJCache.h>
#elif __has_include("KJAVPlayer+KJCache.h")
#import "KJAVPlayer+KJCache.h"
#else
#endif

/* ****************  MIDI内核  ****************/
#if __has_include(<KJPlayer/KJMIDIPlayer.h>)
#import <KJPlayer/KJMIDIPlayer.h>
#elif __has_include("KJMIDIPlayer.h")
#import "KJMIDIPlayer.h"
#else
#endif

/* ****************  IJKPlayer内核  ****************/
#if __has_include(<KJPlayer/KJIJKPlayer.h>)
#import <KJPlayer/KJIJKPlayer.h>
#elif __has_include("KJIJKPlayer.h")
#import "KJIJKPlayer.h"
#else
#endif

#endif /* KJPlayerHeader_h */
