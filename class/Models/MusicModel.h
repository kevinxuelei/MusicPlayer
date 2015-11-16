//
//  MusicModel.h
//  MusicPlayer
//
//  Created by lanou3g on 15/10/15.
//  Copyright (c) 2015年 魏义涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicModel : NSObject
//歌曲网址
@property (nonatomic, copy) NSString * mp3Url;
//
@property (nonatomic, copy) NSString * ID;
//歌曲名
@property (nonatomic, copy) NSString * name;
//图片网址
@property (nonatomic, copy) NSString * picUrl;

@property (nonatomic, copy) NSString * blurPicUrl;

@property (nonatomic, copy) NSString * album;
//歌手名
@property (nonatomic, copy) NSString * singer;
//歌曲时长
@property (nonatomic, copy) NSString * duration;

@property (nonatomic, copy) NSString * artists_name;
//歌词
@property (nonatomic, copy) NSString * lyric;


@end
