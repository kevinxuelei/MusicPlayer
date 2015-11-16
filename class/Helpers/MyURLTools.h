//
//  DXCURLTools.h
//  MusicPlayer
//
//  Created by 王剑亮 on 15/10/15.
//  Copyright (c) 2015年 魏义涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyURLTools : NSObject

typedef enum {
    
   JsondataTypeArray=0,
   JsondataTypeDictionary,
   JsondataTypeData,
   JsondataTypeOthers
    
} JsondataType ;

+(instancetype)shardMyURLTools;

//(NSString *)Url 网址字符串
//JsonDataType:(JsondataType)dataType   判断数据的格式！！！！
/* ExplainBlock:(void (^)(id  explainData)explain
 这是一个block 传过来的参数是 网络下载来的类数据explainData
 */
//CompleteBlock:(void (^)(void))complete 完成后调用这个blcok块 主要用于刷新界面

-(void)JsondateTools:(NSString *)Url
        JsonDataType:(JsondataType)dataType
        ExplainBlock:(  void (^)(id  explainData) )explain
       CompleteBlock:(  void (^)(void)            )complete    ;


@end
