//
//  MyLable.m
//  MusicPlay
//
//  Created by 王剑亮 on 15/10/19.
//  Copyright © 2015年 wangjianliang. All rights reserved.
//

#import "MyLable.h"
#import <Foundation/Foundation.h>
#import "MusicLyricHelper.h"
#define MyLog(...)  NSLog(__VA_ARGS__)
#define kMusicLyricHelper  [MusicLyricHelper sharedMusicLyricHelper]
@interface MyLable ()
{
    int currenti;

    CGFloat posx ;


}

@property (nonatomic, strong)  UILabel *lable123;



@end

@implementation MyLable

- (instancetype)init
{
    self = [super init];
    if (self) {

        [self change];
        currenti = 0;
        //计算一下偏移量
        CGFloat movex = [UIScreen mainScreen].bounds.size.width - [kMusicLyricHelper stringWidthWithString:self.text fontSize:20 contentSize:CGSizeMake(1000, 40)];
        posx = movex/2;
        
        _timer = nil;

    }
    return self;
}

-(void)change
{

    if (currenti == 0)
    {
        _lable123 = [[UILabel alloc] init];
        _lable123.textColor = [UIColor greenColor];
        _lable123.font = self.font;
        _lable123.text = [self.text substringWithRange:NSMakeRange(0,1)];
        //计算一下偏移量
        CGFloat movex = [UIScreen mainScreen].bounds.size.width - [kMusicLyricHelper stringWidthWithString:self.text fontSize:20 contentSize:CGSizeMake(1000, 40)];
        posx = movex/2;
        _lable123.frame = CGRectMake(posx-20, 0,20, self.frame.size.height);
        [self addSubview:_lable123];
    }
    if (currenti == _length)
    {
        [_timer setFireDate:[NSDate distantFuture]]; //定时器暂停！图片停止旋
        _timer = nil;
        return ;
    }
    
    _lable123.text = [self.text substringWithRange:NSMakeRange(currenti,1)];
    
[UIView animateWithDuration:_time/(_length+2) animations:^{
    
    //第一次不管怎么样都是0 第二次开始计算偏移量
    if (currenti == 0) {
        CGFloat movex = [UIScreen mainScreen].bounds.size.width - [kMusicLyricHelper stringWidthWithString:self.text fontSize:20 contentSize:CGSizeMake(1000, 40)];
        posx = movex/2;
    }else
    {

      NSString *str  = [self.text substringWithRange:NSMakeRange(currenti-1,1)];
        
      CGFloat addposx = [kMusicLyricHelper stringWidthWithString:str fontSize:20 contentSize:CGSizeMake(1000, 40)];
        posx += addposx;
    }
    _lable123.frame = CGRectMake(posx, 0, 20, self.frame.size.height);
  

    
}];

 currenti++;
    
}



-(void)start
{
    //必须在这里初始化！！！！
    
    //计算一下偏移量
    CGFloat movex = [UIScreen mainScreen].bounds.size.width - [kMusicLyricHelper stringWidthWithString:self.text fontSize:20 contentSize:CGSizeMake(1000, 40)];
    posx = movex/2;
    currenti = 0;

    _timer =  [NSTimer scheduledTimerWithTimeInterval:_time/_length target:self selector:@selector(change ) userInfo:nil  repeats:YES];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
