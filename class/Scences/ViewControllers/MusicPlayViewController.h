//
//  MusicPlayViewController.h
//  MusicPlayer
//
//  Created by 王剑亮 on 15/10/16.
//  Copyright (c) 2015年 魏义涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicModel.h"

@interface MusicPlayViewController : UIViewController


@property (weak, nonatomic) MusicModel * musicModel;

typedef enum {

    Switchsingnext = 0,  //下一个model
    Switchsingprevious   //上一个

}Switchsing;


@property (nonatomic, copy )  MusicModel* (^block) (Switchsing switchtype) ;

@property (nonatomic, copy ) void(^blockbarbtn) (int num);

//单列对象获取
+(instancetype)sharedMusicPlayVC;

- (void)parseLyricCurrent;

@end
