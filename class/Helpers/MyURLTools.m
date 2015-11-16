//
//  DXCURLTools.m
//  MusicPlayer
//
//  Created by 王剑亮 on 15/10/15.
//  Copyright (c) 2015年 魏义涛. All rights reserved.
//

#import "MyURLTools.h"
#import <UIKit/UIKit.h>
@interface MyURLTools ()



@end


@implementation MyURLTools

static MyURLTools *tools = nil;

+(instancetype)shardMyURLTools
{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
       
        if (tools == nil) {
            
            tools = [[MyURLTools alloc] init];
        }
        
    });
    
    return tools;
}

#pragma mark ----- 请求数据 并封装成model 对象  封装就是解耦
//(NSString *)Url 网址字符串
//JsonDataType:(JsondataType)dataType   判断数据的格式！！！！
/* ExplainBlock:(void (^)(id  explainData)explain
    这是一个block 传过来的参数是 网络下载来的类数据explainData
 */
//CompleteBlock:(void (^)(void))complete 完成后调用这个blcok块 主要用于刷新界面

-(void)NetdataisNil:(id )data
{
    if (data == nil)
    {
        NSLog(@"网络连接失败！！！！");
    }
}

-(void)JsondateTools:(NSString *)Url
        JsonDataType:(JsondataType)dataType
        ExplainBlock:(void (^)(id  explainData) )explain
       CompleteBlock:(void (^)(void))complete
{
    //dispatch_get_global_queue:获得一个全局队列
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        ^{
            
            NSString *str = [Url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL * url = [NSURL URLWithString:str];
            //同步请求数据
            //先判断 字典 在判断 数组
            if (dataType == JsondataTypeArray)
            {
                id data = [NSArray arrayWithContentsOfURL:url];
                [self NetdataisNil:data];
                explain(data);
            }else
            if (dataType == JsondataTypeDictionary) {
                
                id data = [NSDictionary dictionaryWithContentsOfURL:url];
                 [self NetdataisNil:data];
                 explain(data);
            }
            else
            if (dataType == JsondataTypeData)
            {
                id data = [NSData dataWithContentsOfURL: url];
                 [self NetdataisNil:data];
                explain(data);
            }
 
            //数据下载完事 回主线成回调！！！！
            dispatch_async(dispatch_get_main_queue(), ^
            {
                complete();
            });
            

        });


}
                                                            

@end
