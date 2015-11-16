//
//  MusicLyricHelper.h
//  Musicplayer3.7
//
//  Created by 王剑亮 on 15/10/20.
//  Copyright © 2015年 wangjianliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MusicLyricHelper : NSObject
#pragma mark - 获取歌词工具对象
+ (MusicLyricHelper *)sharedMusicLyricHelper;
#pragma mark - 解析歌词 并封装成model对象
- (void)parseLyricWithLyricString:(NSString *)lyricString;

-(NSMutableArray *)dealLyricString:(NSString *)lyric timeArray:(NSMutableArray *)_timeArray wordArray:(NSMutableArray *)_wordArray;


#pragma mark---处理歌词的时间 返回10倍的时间 以秒为单位！
-(int64_t)dealtimeArrayTime:(NSString *)str;

#pragma mark--- 根据字体和长度 获取那个宽度大小
- (CGFloat)stringWidthWithString:(NSString *)str fontSize:(CGFloat)fontSize contentSize:(CGSize)size;

@end
