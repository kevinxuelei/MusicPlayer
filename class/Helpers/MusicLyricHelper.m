//
//  MusicLyricHelper.m
//  Musicplayer3.7
//
//  Created by 王剑亮 on 15/10/20.
//  Copyright © 2015年 wangjianliang. All rights reserved.
//

#import "MusicLyricHelper.h"

#define MyLog(...)  NSLog(__VA_ARGS__)
@implementation MusicLyricHelper

#pragma mark - 获取歌词工具对象
+ (MusicLyricHelper *)sharedMusicLyricHelper
{
    static MusicLyricHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[MusicLyricHelper alloc] init];
    });
    return helper;
}
#pragma mark - 解析歌词 并封装成model对象
- (void)parseLyricWithLyricString:(NSString *)lyricString
{
    NSLog(@"%@", lyricString);
}


-(NSMutableArray *)dealLyricString:(NSString *)lyric timeArray:(NSMutableArray *)_timeArray wordArray:(NSMutableArray *)_wordArray
{
    
    NSMutableArray *array = [NSMutableArray array];
    
    if (_timeArray.count != 0)
    { //防止重复添加歌词
        [_timeArray removeAllObjects];
        [ _wordArray removeAllObjects ];
        
    }else
    {
        _wordArray = [NSMutableArray array];
        _timeArray = [NSMutableArray array];
    }
    
    NSArray *sepArray = [lyric componentsSeparatedByString:@"["];
    for (int i = 1; i < sepArray.count; i ++)
    {
        NSArray *arr = [sepArray[i] componentsSeparatedByString:@"]"];
        [_timeArray addObject:arr[0]];
        [_wordArray addObject:arr[1]];
    }
    
    MyLog(@"%@",_timeArray);
    MyLog(@"%@",_wordArray);

    [array addObject:_timeArray];
    [array addObject:_wordArray];
    
    return array;

}


#pragma mark---处理歌词的时间 返回10倍的时间 以秒为单位！
-(int64_t)dealtimeArrayTime:(NSString *)str
{
    
    //解决 奇妙能力那首歌曲 歌曲时间的BUG！
    if( [[str  substringWithRange:NSMakeRange(0,1)]  isEqualToString:@"0"])
    {
        int fen = [str  substringWithRange:NSMakeRange(0,2)].intValue;
        int miao = [str substringWithRange:NSMakeRange(3,2)].intValue;
        int dian1 = [str substringWithRange:NSMakeRange(6,1)].intValue;
        int64_t lyrcitime = (fen *600 +miao*10  + dian1);
        return lyrcitime;
        
    }else
    {
        return 0.0;
    }
    
}


- (CGFloat)stringWidthWithString:(NSString *)str fontSize:(CGFloat)fontSize contentSize:(CGSize)size
{
    //    第一个参数 代表最大的范围
    //    第二个参数 代表 是否考虑字体、字号
    //    第三个参数 代表使用什么字体、字号
    //    第四个参数 用不到 所以基本为nil
    CGRect stringRect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    
    return stringRect.size.width;
}


@end
