//
//  MyLable.h
//  MusicPlay
//
//  Created by 王剑亮 on 15/10/19.
//  Copyright © 2015年 wangjianliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyLable : UILabel

@property (nonatomic, assign) CGFloat time;
@property (nonatomic, assign) CGFloat length;
@property (nonatomic, assign) NSTimer *timer;
-(void)start;
@end
