//
//  MusicPlayViewController.m
//  MusicPlayer
//
//  Created by 王剑亮 on 15/10/16.
//  Copyright (c) 2015年 魏义涛. All rights reserved.
//

#import "MusicPlayViewController.h"
#import "MusicPlayerHelper.h"
#import "UIImageView+WebCache.h"
#import "MyLable.h"
#import "MusicLyricHelper.h"
#define MyLog(...)  NSLog(__VA_ARGS__)
#define kMusicPlayerHelper  [MusicPlayerHelper sharedMusicPlayerHelper]
#define kMusicLyricHelper  [MusicLyricHelper sharedMusicLyricHelper]
#pragma mark---  旋转角度控制
static int Rotationi = 0;
#pragma mark--- 旋转时间
static float RotationTime = 0.2;
#pragma mark--- 歌词滑动时候传递的标志
static BOOL lyricLbaleOk = YES;
#pragma mark--- 定义向上的偏移量
static int upMove = 0;
static int currentupomove;
static int oldupomove ;

#pragma mark--- buttonstart i;
static int buttonstarti = 0;

#pragma mark--- 偏移坐标
static CGFloat posY = 0;

#pragma mark--- 滑动判断标志
static BOOL huadong = YES;

@interface MusicPlayViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *startbutton;
@property (nonatomic, strong)  NSTimer *timer;
@property (strong, nonatomic) IBOutlet UIImageView *myimageView;
@property (strong, nonatomic) IBOutlet UILabel *Vomulelable;
@property (strong, nonatomic) IBOutlet UILabel *progessLable;
@property (strong, nonatomic) IBOutlet UISlider *progessslider;
@property (strong, nonatomic) IBOutlet UIScrollView *LyricScrollView;

@property (strong, nonatomic) IBOutlet UIView *beijingView;


@property (nonatomic, copy) NSMutableArray *wordArray;
@property (nonatomic, copy) NSMutableArray *timeArray;

@end

@implementation MusicPlayViewController

#pragma mark ------  单列对象获取
+(instancetype)sharedMusicPlayVC
{
    static MusicPlayViewController *vc = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        
        if (vc == nil)
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            vc = [storyBoard instantiateViewControllerWithIdentifier:@"MusicPlay"];
        }
        
    });
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //开启图片圆形
    //当使用 可视化布局的时候 提前布局！
    [_myimageView layoutIfNeeded];
    _myimageView.layer.cornerRadius = (CGFloat)_myimageView.frame.size.width/2.0;
    _myimageView.layer.masksToBounds = YES;
    
    //必须在这里初始化！！！！
    _timer =  [NSTimer scheduledTimerWithTimeInterval:RotationTime target:self selector:@selector(addtime ) userInfo:nil  repeats:YES];
    
    //显示进度条！
    [self changeprogessline];
    //_LyricScrollView 的一些设置
    _LyricScrollView.delegate = self;
    
    huadong = YES;
    
    UIImageView *myImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    myImageView.image = [UIImage imageNamed:@"beijing1"];
    [self.beijingView addSubview:myImageView];
    [self.beijingView sendSubviewToBack:myImageView];
    
}

#pragma mark--- 显示滑动的地方！
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"正在滚动中");
    int num = _LyricScrollView.contentOffset.y / 40;
    NSLog(@"num = %d",num);
    upMove = num;
    if (upMove >= (_timeArray.count-1)) {
        upMove = (int)_timeArray.count-1;
    }
    posY = _LyricScrollView.contentOffset.y - upMove*40;
    //更新Lable显示！
    [self LableUpdateStart:NO];
}
#pragma mark--- 拖动操作！
-(void)drop
{
    huadong = YES;
    
    //获取歌词的时间 和 总时间
    int64_t lyrcitime2 = [kMusicLyricHelper dealtimeArrayTime:_timeArray[upMove]];;
    
    CGFloat currenttime = ((CGFloat)lyrcitime2 /10);
    CGFloat allttime = [kMusicPlayerHelper getTimelength];
    CGFloat time = currenttime / allttime;
    //获取时间结束
    //不根据时间来更新 进度条 和 歌词！
    lyricLbaleOk = NO;
    currentupomove = upMove;
    oldupomove = upMove;
    
    //显示LAble的位置 不用显示scrollView 的位置 但是要记录一下
    [self LableUpdateStart:YES];
    posY = _LyricScrollView.contentOffset.y - upMove*40;
    //设置一下 时间进度
    [kMusicPlayerHelper changeprogess: time ];
}

#pragma mark--- 设置滑动的进度
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    MyLog(@"结束拖拽");
    [self drop];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    MyLog(@"减速结束");
    [self drop];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    huadong = YES;
    NSLog(@"结束动画");
}
#pragma mark--- 界面即将出现 进行界面的操作！！！！！
-(void)viewWillAppear:(BOOL)animated
{
    [self changescenes:_musicModel];
}

#pragma mark--- 歌词处理 每次切换歌曲处理一次就可以！
-(void)dealLycric
{
    if (_timeArray.count != 0)
    {
        for (int i = 0; i < _wordArray.count; i++)
        {
            MyLable *label = (MyLable *)[_LyricScrollView viewWithTag:100+ i ];
            [label removeFromSuperview];
        }
        
    }
    NSMutableArray *arr =  [[MusicLyricHelper sharedMusicLyricHelper] dealLyricString:_musicModel.lyric timeArray:_timeArray wordArray:_wordArray];
    _timeArray =  arr[0];
    _wordArray = arr[1];
    
    //歌词的显示 view
    _LyricScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, _timeArray.count*40 + 300);
    _LyricScrollView.backgroundColor = [UIColor clearColor];
    
    //把Lable 添加到上面去
    for (int i = 0; i < _wordArray.count; i++)
    {
        MyLable*label1=[[MyLable alloc]init];
        label1.tag = 100+i;
        label1.text = _wordArray[i];
        label1.backgroundColor=[UIColor clearColor];
        label1.textAlignment=NSTextAlignmentCenter;
        label1.lineBreakMode=NSLineBreakByCharWrapping;
        label1.font=[UIFont systemFontOfSize:20];
        
        label1.frame = CGRectMake(0,i*40+80, [UIScreen mainScreen].bounds.size.width,40);
        
        NSString * strleng = _wordArray[i];
        label1.length = strleng.length;
        if (i == _timeArray.count -1){}
        else
        {
            label1.time = (CGFloat)([kMusicLyricHelper dealtimeArrayTime:_timeArray[i+1]] - [kMusicLyricHelper dealtimeArrayTime:_timeArray[i]])/10;
        }
        [_LyricScrollView addSubview:label1];
        
    }
    //显示一下 LABle
    [self LableUpdateStart:YES];
}

#pragma mark--- 模型改变 画面和音乐的处理！
-(void)changescenes:(MusicModel *)model
{
    _musicModel = model;
    
    static  NSString *oldnamestring ;
    static  NSString *currentnamestring ;
    currentnamestring = _musicModel.name;
    //如果是相同的model 那就不重新播放！
    if (currentnamestring == oldnamestring) {
        
    }
    else
    {
        //这里需要暂停一下！！！！
        [kMusicPlayerHelper playStop];
        //设置背景图片
        [_myimageView sd_setImageWithURL:[NSURL URLWithString: model.picUrl] placeholderImage:[UIImage imageNamed:@"image@2x.png"] ];
        //定时器开启 启动图片旋转
        [_timer setFireDate:[NSDate distantPast]];
        //清除旋转位置
        Rotationi = 0;
        self.myimageView.transform = CGAffineTransformMakeRotation(Rotationi);
        //设置标题
        self.title = model.name;
        
        //开启播放之前 显示歌词
        upMove = 0;
        currentupomove = 0;
        oldupomove = 0;
        _LyricScrollView.contentOffset = CGPointMake(0, 0);
        [self dealLycric];
        
        //开启音乐播放！！！！！
        [kMusicPlayerHelper playBackgroundMusicURLString:model.mp3Url];
        //点击一下 是暂停的状态！
        buttonstarti = 0;
        _blockbarbtn(0);//正在播放！
    }
    oldnamestring = currentnamestring;
}

#pragma mark--- 控制图片旋转
-(void)addtime
{
    Rotationi++;
    //这个是 旋转一个角度
    [UIView animateWithDuration:RotationTime animations:^
     {
         self.myimageView.transform = CGAffineTransformMakeRotation((Rotationi%360) * (M_PI /180 ));
     }];
}
#pragma mark---  暂停 或者 开始
- (IBAction)playstop:(id)sender
{
    if ( buttonstarti++ % 2 == 1)
    {
        MyLog(@"播放状态 按钮显示暂停");
        [kMusicPlayerHelper playstart];           //开启音乐播放！
        [_timer setFireDate:[NSDate distantPast]];//定时器运行！图片开启旋转！
        //按钮显示 暂停
        [_startbutton setTitle:@"暂停" forState:UIControlStateNormal];
        _blockbarbtn(0);//正在播放！
        
    }else
    {
        MyLog(@"暂停状态 按钮显示播放");
        [kMusicPlayerHelper playStop];               //音乐播放停止！
        [_timer setFireDate:[NSDate distantFuture]]; //定时器暂停！图片停止旋转！
        //按钮显示 开始
        [_startbutton setTitle:@"开始" forState:UIControlStateNormal];
        _blockbarbtn(1);//停止播放！
    }
}
#pragma mark---  上一首
- (IBAction)playprevious:(id)sender
{
    MyLog(@"上一首");
    buttonstarti = 0;
    //按钮显示 暂停
    [_startbutton setTitle:@"暂停" forState:UIControlStateNormal];
    MusicModel *model = _block(Switchsingprevious);
    [self changescenes:model];                //设置model 开启音乐播放！
}
#pragma mark---  下一首
- (IBAction)playnext:(id)sender {
    
    MyLog(@"下一首");
    buttonstarti = 0;
    //按钮显示 暂停
    [_startbutton setTitle:@"暂停" forState:UIControlStateNormal];
    
    MusicModel *model = _block(Switchsingnext);
    [self changescenes:model];                //设置model 开启音乐播放！
}
#pragma mark--- 音量改变！
- (IBAction)Volumechange:(UISlider *)sender {
    
    MyLog(@"音量：%f",sender.value);
    [kMusicPlayerHelper changeVolume:sender.value];
    _Vomulelable.text = [NSString stringWithFormat:@"%d",(int )(sender.value*100)];
}
#pragma mark--- 放歌时间改变！
- (IBAction)Timechange:(UISlider *)sender
{
    huadong = NO;
    MyLog(@"时间 = %f",sender.value);
    [kMusicPlayerHelper changeprogess:sender.value];
}

#pragma mark--- 播放进度改变
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark--- 显示进度条 和 歌词界面 根据歌曲的时间作为唯一的判断条件
-(void)changeprogessline
{
    
    __block MusicPlayViewController *pself = self;
    //显示进度条的时间 和 歌词的显示
    kMusicPlayerHelper.blocktime = ^(CGFloat time, CGFloat value)
    {
        pself.progessLable.text = [NSString stringWithFormat:@"%02d分:%02d秒",(int)time/60,(int)time%60];
        //进度条显示
        pself.progessslider.value = value;
#pragma mark--- 根据时间查找对应数组的位置
        //根据时间查找
        for (int i = 0; i < _timeArray.count; i++)
        {
            int64_t lyrcitime2;
            if (i+1 < _timeArray.count)
            {
                lyrcitime2 = [kMusicLyricHelper dealtimeArrayTime:_timeArray[i+1]];
            }else
            {
                lyrcitime2 = time*10+1;
            }
            
            int64_t lyrcitime = [kMusicLyricHelper dealtimeArrayTime:_timeArray[i]];
            int64_t currenttime = (int64_t) (time*10);
            
            if(  (currenttime >= lyrcitime)  && (currenttime < lyrcitime2))
            {
                upMove = i;
                
                //防止数组越界
                if (upMove >= (_timeArray.count-1)) {
                    upMove = (int)_timeArray.count - 1;
                }
                
                //break;
            }
            
        }
        
        //当当前的位置改变了 那么进行歌词和位置的刷新！
        currentupomove  = upMove;
        if (currentupomove != oldupomove)
        {
            [pself parseLyricCurrent];//歌词更新显示
        }
        oldupomove = currentupomove;
        
    };
    
    MusicPlayViewController *pself1 =  self;
    //结束播放下一首  这里可以选择 播放模式 各种模式！
    kMusicPlayerHelper.blocknextsing = ^()
    {
        //音乐播放到下一首
        MusicModel *model =  pself1.block(Switchsingnext);
        [pself1 changescenes:model]; //设置model 开启音乐播放！
    };
    
}
#pragma mark--- Lable更新！
-(void)LableUpdateStart:(BOOL)ok
{
    //让上一个 那个显示 [UIColor purpleColor];
    for (int i = 0; i < _wordArray.count; i++)
    {
        MyLable *label = (MyLable *)[_LyricScrollView viewWithTag:100+ i ];
        label.textColor=[UIColor blackColor];
    }
    
    MyLable *label1 = (MyLable *)[_LyricScrollView viewWithTag:100 + upMove ];
    if ((label1.text == nil) || [ label1.text  isEqualToString:@" "] )
    {
        label1.text=@"----------";
    }
    label1.textColor=[UIColor redColor];
    
    if (ok == YES)
    {
        
        if ( (label1.timer == nil) &&( huadong == YES) )
        {
            [label1 start];
        }
    }
}

#pragma mark--- + 显示歌词更新
- (void)parseLyricCurrent
{
    
    if(lyricLbaleOk)
    {
        [self LableUpdateStart:YES];
        [UIView animateWithDuration:0.5 animations:^
         {
             [_LyricScrollView setContentOffset:CGPointMake(0, upMove*40 + posY ) animated:YES];
         }];
        
    }else
    {
        lyricLbaleOk = YES;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

