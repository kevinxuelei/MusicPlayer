//
//  MusicListTableViewController.h
//  MusicPlayer
//
//  Created by lanou3g on 15/10/15.
//  Copyright (c) 2015年 魏义涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicListTableViewController : UITableViewController
{
    __block BOOL isReshing;
    __block BOOL isLoading;
    __block NSInteger _currentPage;
}
@end
