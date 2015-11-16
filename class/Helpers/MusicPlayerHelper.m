//
//  MusicPlayerHelper.m
//  MusicPlayer
//
//  Created by 王剑亮 on 15/10/16.
//  Copyright (c) 2015年 魏义涛. All rights reserved.
//

#import "MusicPlayerHelper.h"
#import <AVFoundation/AVFoundation.h>
#define MyLog(...)  NSLog(__VA_ARGS__)
@interface MusicPlayerHelper ()
{


}
@property (nonatomic, copy) NSTimer *timer;

@property (nonatomic, strong) AVPlayer *avplayer;


@end

@implementation MusicPlayerHelper
#pragma mark--- 歌曲时间长度
static CGFloat timelength = 1.0;
#pragma mark--- 播放音乐单列对象

+(instancetype)sharedMusicPlayerHelper
{
    static MusicPlayerHelper *playerHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        playerHelper = [[MusicPlayerHelper alloc] init];
        
    });

    return playerHelper;
}

#pragma mark--- 懒加载 重写getter方法

-(AVPlayer *)avplayer
{
    if ( !_avplayer) {
    
        _avplayer = [[AVPlayer alloc] init];
         _timer =  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(addtime ) userInfo:nil  repeats:YES];
    }
    
    return _avplayer;

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextsing) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

//音乐播放完 进行下一曲的播放！
-(void)nextsing
{
   self.blocknextsing();
}

#pragma mark--- 获取时间长度
-(CGFloat)getTimelength
{
    //获取当前音乐的时间长度！！！！
    CGFloat second;
    AVPlayerItem *currentItem = [_avplayer currentItem];
    if (currentItem.duration.timescale != 0)
    {
        second =(CGFloat)((CGFloat)currentItem.duration.value/(CGFloat)currentItem.duration.timescale) ;
    }else
    {
        second = timelength;
    }
    return second;
}

#pragma mark--- 没面检测一下 当前的时间
-(void)addtime
{

     //播放不同的歌曲 一下获取最新的时间长度
     timelength = [self getTimelength];
     MyLog(@"alltime = %d分：%d秒 .%d秒",(int)timelength/60, (int)timelength%60 ,(int)((timelength -(CGFloat)(int)timelength)*100));
    
    //这里获取当前状态的运行时间  之后判断是不是停止 就行了！！！！ 停止这个很重要！
    CGFloat current =(CGFloat)((CGFloat)_avplayer.currentTime.value/(CGFloat)_avplayer.currentTime.timescale);
    
    MyLog(@"currenttime = %d分：%d秒 .%d秒",(int)current/60, (int)current%60 ,(int)((current -(CGFloat)(int)current)*100));
    
    //把当前时间 传递到上一个界面
    self.blocktime( current ,(CGFloat)(current /timelength) );
    
//    //当前播放时间结束了 进行下一首播放
//    
//    if ( (current < timelength) &&  (current > timelength-0.2))
//    {
//        self.blocknextsing();
//    }

}

#pragma mark--- 根据URLstr 播放音乐！

-(void)playBackgroundMusicURLString:(NSString *)URLstr
{

    //根据urlStr创建 avplayer要播放的item
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:URLstr]];
    //    传入新的就进行替换
    [self.avplayer replaceCurrentItemWithPlayerItem:item];


    MyLog(@"歌曲总时间 == %d",_avplayer.currentItem.duration.timescale);
    //kvo观察avplayer
    
    //监听播放状态
    [self.avplayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    if (self.avplayer.status == AVPlayerStatusReadyToPlay)
    {
     [self playstart];
     MyLog(@"avPlayer正在工作 继续播放！");
    }
 
    //监听播放的状态！
    [self.avplayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    return;
}


-(void)dealloc
{
 [self.avplayer removeObserver:self forKeyPath:@"status"];

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    
    if (self.avplayer.status == AVPlayerStatusReadyToPlay)
    {

            
            MyLog(@"播放状态改变 可以播放音乐 开始播放");
            [self playstart];


    }

}

#pragma mark--- 判断音乐播放
-(void)playstart
{
     [_timer setFireDate:[NSDate distantPast]];//定时器运行！
    
    MyLog(@"time = %d分：%d秒 ",(int)timelength/60, (int)timelength%60 );

    if (_isPlayer == NO) {
       
        _isPlayer = YES;
    }
    [_avplayer play];    
    

}

#pragma mark--- 暂停音乐
-(void)playStop
{
    
    [_timer setFireDate:[NSDate distantFuture]];//定时器停止！
    if (_isPlayer == YES)
    {
        _isPlayer = NO;
    }
    [_avplayer pause];

}


-(void)changeVolume:(CGFloat )num
{
    _avplayer.volume = num;

}

-(void)changeprogess:(CGFloat)num
{
     int64_t value = num * timelength*_avplayer.currentTime.timescale;
    //正传 时间变换
    CMTime slidertime = CMTimeMake(value, _avplayer.currentTime.timescale);
    
    MyLog(@"value = %lld",value);
    
    [_avplayer seekToTime:slidertime completionHandler:^(BOOL finished) {
        
        self.blocktime( (CGFloat)( _avplayer.currentTime.value/_avplayer.currentTime.timescale) , num);
    }];

}

@end
