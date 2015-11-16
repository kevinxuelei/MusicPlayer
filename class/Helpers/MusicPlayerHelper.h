//
//  MusicPlayerHelper.h
//  MusicPlayer
//
//  Created by 王剑亮 on 15/10/16.
//  Copyright (c) 2015年 魏义涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MusicPlayerHelper : NSObject

#pragma mark--- 播放音乐单列对象
+(instancetype)sharedMusicPlayerHelper;

#pragma mark--- 根据URLstr 播放音乐！
-(void)playBackgroundMusicURLString:(NSString *)URLstr;

#pragma mark--- 开始音乐播放
-(void)playstart;
#pragma mark--- 暂停音乐播放
-(void)playStop;

#pragma mark--- 控制音量的改变
-(void)changeVolume:(CGFloat )num;

#pragma mark--- 控制音乐播放进度的改变！
-(void)changeprogess:(CGFloat)num;


#pragma mark--- 获取时间长度
-(CGFloat)getTimelength;

@property (nonatomic, assign) BOOL isPlayer;


@property (nonatomic, copy) void (^blocktime)(CGFloat time , CGFloat value);

@property (nonatomic, copy) void (^blocknextsing)(void);

@end
