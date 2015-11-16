//
//  MusicListTableViewController.m
//  MusicPlayer
//
//  Created by lanou3g on 15/10/15.
//  Copyright (c) 2015年 魏义涛. All rights reserved.
//

#import "MusicListTableViewController.h"
#import "Urls.h"
#import "MusicModel.h"
#import "MusicListCell.h"
#import "MyURLTools.h"
#import "MBProgressHUD.h"
#import "MusicPlayViewController.h"
#import "DataBasehandle.h"
#import "MJRefresh.h"

static NSInteger currenti;

@interface MusicListTableViewController ()


@property (nonatomic, strong)  UIActivityIndicatorView *activity;;

//存放所有的music对象
@property (nonatomic, strong) NSMutableArray *allMusicModelsArray;

@property (strong, nonatomic) IBOutlet UITableView *MusicTableView;

@property (nonatomic,retain) MBProgressHUD * hud;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *playingbarbtn;


@end

@implementation MusicListTableViewController

#define KMusicDataHelper [MyURLTools shardMyURLTools]
#define KMusicplayerVC   [MusicPlayViewController sharedMusicPlayVC]
- (void)viewDidLoad {
    [super viewDidLoad];
    
    MusicModel * model = [[MusicModel alloc] init];
    DataBasehandle *db = [DataBasehandle sharedDataBasehandle];
    [db createtableName:@"Music" Model:model];
    self.allMusicModelsArray = [db selectAllModel];
    
    self.allMusicModelsArray = [db selectFromAttributeName:@"picUrl" ValueStr:@"http://p4.music.126.net/CvMh65aoJi0yz3QbbInhfQ==/7828522790653022.jpg"];
    
    //加载图标
    [self p_setupProgressHud];
    if (self.allMusicModelsArray.count == 0)
    {
        //    1.网络请求
        __weak MusicListTableViewController * listVC = self;
        listVC.allMusicModelsArray = [NSMutableArray array];
        [KMusicDataHelper JsondateTools:kMusicListUrl JsonDataType:JsondataTypeArray ExplainBlock:^(id explainData)
         {
             //遍历数组 将有效信息封装成model对象
             for (NSDictionary * dic in explainData)
             {
                 //使用KVC封装model对象
                 MusicModel * music = [[MusicModel alloc] init];
                 [music setValuesForKeysWithDictionary:dic];
                 [listVC.allMusicModelsArray addObject:music];
             }
         }
                          CompleteBlock:^
         {
             //菊花图标隐藏！！！
             [listVC.hud hide:YES];
             //刷新表示图 由主线程来做
             [listVC.tableView reloadData];
             
             //保存模型
             [listVC savemodel];
         }];
    }else
    {
         //加载图标隐藏
         [_hud hide:YES];
    
    }
    
    //backgroundView设置tableView上的背景图片
    UIImageView *backView = [[UIImageView alloc] init];
    backView.image = [UIImage imageNamed:@"1.jpg"];
    backView.backgroundColor = [UIColor redColor];
    _MusicTableView.backgroundView = backView;
    
    self.navigationController.navigationBar.translucent = NO;
    //self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    //传递回来 那个播放状态
    MusicPlayViewController *vc = [MusicPlayViewController sharedMusicPlayVC];
    vc.blockbarbtn = ^(int num){
     
        if(num == 0)
        {
               _playingbarbtn.title = @"正在播放";
        }else
        {
              _playingbarbtn.title = @"停止播放";
        }

    };

    
    MusicListTableViewController *VC = self;
    //上拉刷新:
    [self.tableView addHeaderWithCallback:^{
        if (VC->isReshing) {
            return;
        }
        VC->isReshing = YES;
        VC->_currentPage = 1;
        //根据页码拼接网址进行请求数据
        VC->isReshing = NO;
        [VC.tableView headerEndRefreshing];
    }];
    //下拉加载:
    [self.tableView addFooterWithCallback:^{
        if (VC->isReshing) {
            return;
        }
        VC->isLoading = YES;
        VC->_currentPage++;
        //根据现在的页码进行拼接网址请求数据加载
        VC->isLoading = NO;
        [VC.tableView footerEndRefreshing];
    }];
    
    
    
    

}

#pragma mark---  保存模型数据
-(void)savemodel
{
    
    MusicModel * model = [[MusicModel alloc] init];
    DataBasehandle *db = [DataBasehandle sharedDataBasehandle];
    [db createtableName:@"Music" Model:model];
    
    for (int i = 0; i < _allMusicModelsArray.count; i++) {
        
        [db insertIntoTableModel:_allMusicModelsArray[i]];
    }
}

-(void)p_setupProgressHud{
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.frame = self.view.bounds;
    self.hud.minSize = CGSizeMake(100, 100);
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"loading";
    [self.hud show:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 实现协议的方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#pragma mark - warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#pragma mark - warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    
    
    return self.allMusicModelsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"musicCell" forIndexPath:indexPath];
    
    //根据indexPath获取，model对象
    MusicModel * music = self.allMusicModelsArray[indexPath.row];
    
    //清除cell上的背景颜色
    cell.backgroundColor = [UIColor clearColor];
    [cell binModel:music];
    
    
    return cell;
}

- (IBAction)jumpNext:(UIBarButtonItem *)sender {
    
    MusicPlayViewController *vc = [MusicPlayViewController sharedMusicPlayVC];
    vc.musicModel = self.allMusicModelsArray[currenti];
    [self.navigationController showViewController:vc sender:nil];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    MusicPlayViewController *vc = [MusicPlayViewController sharedMusicPlayVC];
    
    vc.musicModel = self.allMusicModelsArray[indexPath.row];
    
    __block MusicListTableViewController *pself = self ;
    
    //保存下个页面的模型的数组位置
    currenti  = indexPath.row;
    //上一首下一首初始化
    vc.block = ^ MusicModel* (Switchsing switchtype)
    {
        if( (currenti >= 0)  && (currenti < pself.allMusicModelsArray.count - 1))
        {
            if (switchtype == Switchsingnext)
            {
                return pself.allMusicModelsArray[++currenti];
            }
            else if (switchtype == Switchsingprevious)
            {
                if ( currenti != 0 )
                {
                    return pself.allMusicModelsArray[--currenti];
                }else
                {
                  return pself.allMusicModelsArray[0];
                }
                
            }else
            {
                return pself.allMusicModelsArray[0];
            }
            
        }else
        {
            currenti = 0;
            return pself.allMusicModelsArray[0];
        }


    };
    
    
    [self.navigationController showViewController:vc sender:self];


}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
